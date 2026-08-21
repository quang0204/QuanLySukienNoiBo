using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace QuanLySuKien
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        // ─────────────────────────────────────────────────────────────
        //  CONNECTION STRING  (lấy từ Web.config key="EventHub")
        // ─────────────────────────────────────────────────────────────
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        // ─────────────────────────────────────────────────────────────
        //  PAGE LOAD
        // ─────────────────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            // ✅ Bảo vệ trang – chưa đăng nhập → Login
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login_Regis.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // ✅ Không phải admin → trang user
            string vaiTro = Session["VaiTro"]?.ToString() ?? "";
            if (vaiTro != "admin")
            {
                Response.Redirect("~/User/UserTrangChu.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Hiển thị tên admin trên topbar (nếu có label)
            // lblAdminName.Text = Session["HoTen"]?.ToString();

            if (!IsPostBack)
            {
                LoadStats();
                LoadChartData();
                LoadRecentEvents();
            }
        }

        // ─────────────────────────────────────────────────────────────
        //  1. LOAD STATS  (4 thẻ tổng quan)
        // ─────────────────────────────────────────────────────────────
        private void LoadStats()
        {
            const string sql = @"
                -- Tổng sự kiện
                SELECT COUNT(*) FROM dbo.SuKien;

                -- Tổng người đăng ký đã approved
                SELECT COUNT(*) FROM dbo.DangKy WHERE TrangThai = 'approved';

                -- Tỉ lệ tham dự (điểm danh / approved * 100)
                SELECT
                    CASE WHEN COUNT(*) = 0 THEN 0
                         ELSE CAST(SUM(CASE WHEN DaDiemDanh = 1 THEN 1 ELSE 0 END) * 100.0
                                   / COUNT(*) AS INT)
                    END
                FROM dbo.DangKy WHERE TrangThai = 'approved';

                -- Sự kiện trong tháng hiện tại
                SELECT COUNT(*) FROM dbo.SuKien
                WHERE MONTH(NgayBatDau) = MONTH(GETDATE())
                  AND YEAR(NgayBatDau)  = YEAR(GETDATE());

                -- % thay đổi sự kiện so với tháng trước
                DECLARE @thangNay INT = (SELECT COUNT(*) FROM dbo.SuKien
                    WHERE MONTH(NgayBatDau)=MONTH(GETDATE()) AND YEAR(NgayBatDau)=YEAR(GETDATE()));
                DECLARE @thangTruoc INT = (SELECT COUNT(*) FROM dbo.SuKien
                    WHERE MONTH(NgayBatDau)=MONTH(DATEADD(MONTH,-1,GETDATE()))
                      AND YEAR(NgayBatDau)=YEAR(DATEADD(MONTH,-1,GETDATE())));
                SELECT @thangNay - @thangTruoc;

                -- % thay đổi người tham gia
                DECLARE @nguoiNay INT = (SELECT COUNT(*) FROM dbo.DangKy dk
                    INNER JOIN dbo.SuKien sk ON dk.SuKienID = sk.SuKienID
                    WHERE dk.TrangThai='approved'
                      AND MONTH(sk.NgayBatDau)=MONTH(GETDATE())
                      AND YEAR(sk.NgayBatDau)=YEAR(GETDATE()));
                DECLARE @nguoiTruoc INT = (SELECT COUNT(*) FROM dbo.DangKy dk
                    INNER JOIN dbo.SuKien sk ON dk.SuKienID = sk.SuKienID
                    WHERE dk.TrangThai='approved'
                      AND MONTH(sk.NgayBatDau)=MONTH(DATEADD(MONTH,-1,GETDATE()))
                      AND YEAR(sk.NgayBatDau)=YEAR(DATEADD(MONTH,-1,GETDATE())));
                SELECT CASE WHEN @nguoiTruoc=0 THEN 0
                            ELSE CAST((@nguoiNay-@nguoiTruoc)*100.0/@nguoiTruoc AS INT) END;
            ";

            using (var con = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, con))
            {
                con.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    // Result 1: Tổng sự kiện
                    if (rd.Read()) lblTotalEvents.Text = rd.GetInt32(0).ToString("N0");

                    // Result 2: Tổng người tham gia
                    if (rd.NextResult() && rd.Read())
                        lblTotalParticipants.Text = rd.GetInt32(0).ToString("N0");

                    // Result 3: Tỉ lệ tham dự
                    if (rd.NextResult() && rd.Read())
                        lblAttendRate.Text = rd.GetInt32(0) + "%";

                    // Result 4: Sự kiện tháng này
                    if (rd.NextResult() && rd.Read())
                        lblThisMonth.Text = rd.GetInt32(0).ToString();

                    // Result 5: Delta sự kiện
                    if (rd.NextResult() && rd.Read())
                    {
                        int delta = rd.GetInt32(0);
                        lblEventDelta.Text = (delta >= 0 ? "+" : "") + delta + " sự kiện mới";
                        lblEventDelta.CssClass = delta >= 0 ? "change-up" : "change-down";
                    }

                    // Result 6: % delta người tham gia
                    if (rd.NextResult() && rd.Read())
                    {
                        int pct = rd.GetInt32(0);
                        lblParticipantDelta.Text = (pct >= 0 ? "↑ " : "↓ ") + Math.Abs(pct) + "%";
                        lblParticipantDelta.CssClass = pct >= 0 ? "change-up" : "change-down";
                    }
                }
            }
        }

        // ─────────────────────────────────────────────────────────────
        //  2. LOAD CHART DATA  (biểu đồ cột + donut – truyền JSON sang JS)
        // ─────────────────────────────────────────────────────────────
        private void LoadChartData()
        {
            // Biểu đồ cột: T1 → T12 của năm hiện tại, trả về đủ 12 hàng kể cả tháng = 0
            const string sqlBar = @"
                ;WITH months(Thang, SoThang) AS (
                    SELECT 1,1 UNION ALL SELECT 2,2 UNION ALL SELECT 3,3
                    UNION ALL SELECT 4,4  UNION ALL SELECT 5,5  UNION ALL SELECT 6,6
                    UNION ALL SELECT 7,7  UNION ALL SELECT 8,8  UNION ALL SELECT 9,9
                    UNION ALL SELECT 10,10 UNION ALL SELECT 11,11 UNION ALL SELECT 12,12
                )
                SELECT
                    m.SoThang AS SoThang,
                    'T' + CAST(m.SoThang AS NVARCHAR) AS NhanThang,
                    ISNULL(SUM(CASE WHEN dk.TrangThai='approved' THEN 1 ELSE 0 END),0) AS SoDangKy,
                    ISNULL(SUM(CASE WHEN dk.DaDiemDanh=1         THEN 1 ELSE 0 END),0) AS SoThamDu
                FROM months m
                LEFT JOIN dbo.SuKien sk
                    ON MONTH(sk.NgayBatDau) = m.SoThang
                   AND YEAR(sk.NgayBatDau)  = YEAR(GETDATE())
                LEFT JOIN dbo.DangKy dk ON dk.SuKienID = sk.SuKienID
                GROUP BY m.SoThang
                ORDER BY m.SoThang;
            ";

            // Biểu đồ donut: phân loại sự kiện
            const string sqlDonut = @"
                SELECT LoaiSuKien,
                       COUNT(*) AS SoLuong,
                       CAST(COUNT(*)*100.0/SUM(COUNT(*)) OVER() AS INT) AS PhanTram
                FROM dbo.SuKien
                GROUP BY LoaiSuKien
                ORDER BY SoLuong DESC;
            ";

            var regData = new List<string>();
            var attData = new List<string>();
            var labels = new List<string>();

            using (var con = new SqlConnection(ConnStr))
            {
                con.Open();
                using (var cmd = new SqlCommand(sqlBar, con))
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        labels.Add('"' + rd["NhanThang"].ToString() + '"');
                        regData.Add(rd["SoDangKy"].ToString());
                        attData.Add(rd["SoThamDu"].ToString());
                    }
                }

                // Donut data
                var donutLabels = new List<string>();
                var donutVals = new List<string>();
                using (var cmd2 = new SqlCommand(sqlDonut, con))
                using (var rd2 = cmd2.ExecuteReader())
                {
                    while (rd2.Read())
                    {
                        donutLabels.Add('"' + rd2["LoaiSuKien"].ToString() + '"');
                        donutVals.Add(rd2["PhanTram"].ToString());
                    }
                }

                // Đặt vào hidden fields để JS đọc
                hfBarLabels.Value = "[" + string.Join(",", labels) + "]";
                hfBarReg.Value = "[" + string.Join(",", regData) + "]";
                hfBarAtt.Value = "[" + string.Join(",", attData) + "]";
                hfDonutLabels.Value = "[" + string.Join(",", donutLabels) + "]";
                hfDonutVals.Value = "[" + string.Join(",", donutVals) + "]";
            }
        }

        // ─────────────────────────────────────────────────────────────
        //  3. LOAD RECENT EVENTS  (GridView 10 sự kiện gần nhất)
        // ─────────────────────────────────────────────────────────────
        // Map TrangThai -> CSS class (ASCII only, không tiếng Việt)
        private static string GetTrangThaiClass(string tt)
        {
            switch (tt)
            {
                case "open": case "ongoing": return "open";
                case "closed": case "ended": return "closed";
                default: return "soon";
            }
        }

        // Map TrangThai -> Label hiển thị, dùng HTML entities thay tiếng Việt trực tiếp
        private static string GetTrangThaiText(string tt)
        {
            switch (tt)
            {
                case "open": return "M&#7903; &#273;&#259;ng k&#253;";   // Mở đăng ký
                case "upcoming": return "S&#7855;p di&#7877;n ra";           // Sắp diễn ra
                case "draft": return "Nh&#225;p";                         // Nháp
                case "closed": return "&#272;&#227; &#273;&#243;ng";       // Đã đóng
                case "ended": return "&#272;&#227; k&#7871;t th&#250;c";  // Đã kết thúc
                case "ongoing": return "&#272;ang di&#7877;n ra";           // Đang diễn ra
                default: return tt;
            }
        }

        private void LoadRecentEvents()
        {
            const string sql = @"
                SELECT TOP 10
                    sk.SuKienID   AS MaSuKien,
                    sk.TenSuKien,
                    sk.NgayBatDau AS NgayToChuc,
                    sk.LoaiSuKien,
                    sk.SucChua,
                    ISNULL(d.SoDangKy, 0) AS SoDangKy,
                    CASE WHEN sk.SucChua = 0 THEN 0
                         ELSE CAST(ISNULL(d.SoDangKy,0)*100/sk.SucChua AS INT)
                    END AS PhanTram,
                    sk.TrangThai
                FROM dbo.SuKien sk
                LEFT JOIN (
                    SELECT SuKienID, COUNT(*) AS SoDangKy
                    FROM dbo.DangKy WHERE TrangThai = 'approved'
                    GROUP BY SuKienID
                ) d ON sk.SuKienID = d.SuKienID
                ORDER BY sk.NgayTao DESC;
            ";

            using (var con = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, con))
            {
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);

                // Thêm 2 cột tính toán trong C# — không để tiếng Việt trong SQL
                dt.Columns.Add("TrangThaiClass", typeof(string));
                dt.Columns.Add("TrangThaiText", typeof(string));

                foreach (DataRow row in dt.Rows)
                {
                    string tt = row["TrangThai"].ToString();
                    row["TrangThaiClass"] = GetTrangThaiClass(tt);
                    row["TrangThaiText"] = GetTrangThaiText(tt);
                }

                gvRecent.DataSource = dt;
                gvRecent.DataBind();
            }
        }

        // ─────────────────────────────────────────────────────────────
        //  EVENTS
        // ─────────────────────────────────────────────────────────────
        protected void btnCreateEvent_Click(object sender, EventArgs e)
        {
            Response.Redirect("AdminEventForm.aspx");
        }

        protected void gvRecent_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string id = e.CommandArgument.ToString();
            if (e.CommandName == "EditEv")
                Response.Redirect("AdminEventForm.aspx?id=" + id);
            else if (e.CommandName == "ViewEv")
                Response.Redirect("AdminEvents.aspx?id=" + id);
        }
    }
}