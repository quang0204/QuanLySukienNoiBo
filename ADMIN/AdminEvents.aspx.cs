using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;

namespace QuanLySuKien
{
    public partial class AdminEvents : System.Web.UI.Page
    {
        // ════════════════════════════════════════════════════════════
        // CẤU HÌNH
        // ════════════════════════════════════════════════════════════

        private static readonly string ConnStr =
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        // Biến public để aspx render trực tiếp JSON vào JS
        public string EventsJson { get; private set; } = "[]";

        // ════════════════════════════════════════════════════════════
        // PAGE EVENTS
        // ════════════════════════════════════════════════════════════

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login_Regis.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            // LUON tu dong cap nhat trang thai theo thoi gian (chay moi request)
            AutoUpdateStatuses();

            if (!IsPostBack)
            {
                LoadStats();
                LoadEvents();
            }

            // Hidden field truyền lệnh từ JS xuống server (xóa, đổi trạng thái, đóng/mở ĐK)
            string cmd = Request.Form["hfCommand"];
            string val = Request.Form["hfCommandValue"];
            if (!string.IsNullOrEmpty(cmd))
            {
                HandleCommand(cmd, val);
                AutoUpdateStatuses(); // sau khi handle xong cap nhat lai
                LoadStats();
                LoadEvents();
            }
        }

        // ════════════════════════════════════════════════════════════
        // AUTO-UPDATE TRẠNG THÁI
        // ════════════════════════════════════════════════════════════
        // 1 cột TrangThai gộp cả 2 ý nghĩa:
        //   draft     - admin tự quản lý
        //   upcoming  - chưa tới ngày BD, còn hạn, còn chỗ
        //   open      - trong khoảng BD-KT, còn hạn, còn chỗ (đang nhận ĐK)
        //   closed    - hết hạn HOẶC hết chỗ (chưa qua KT)
        //   ended     - đã qua ngày kết thúc
        // ════════════════════════════════════════════════════════════

        private void AutoUpdateStatuses()
        {
            const string sql = @"
                UPDATE s
                   SET s.TrangThai = dbo.fn_TinhTrangThai(
                            s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                            s.SucChua, ISNULL(d.SoDuyet, 0),
                            s.GioBatDau, s.GioKetThuc
                       ),
                       s.NgayCapNhat = GETDATE()
                  FROM dbo.SuKien s
                  LEFT JOIN (
                      SELECT SuKienID, COUNT(*) AS SoDuyet
                      FROM dbo.DangKy WHERE TrangThai = 'approved'
                      GROUP BY SuKienID
                  ) d ON s.SuKienID = d.SuKienID
                 WHERE s.TrangThai <> dbo.fn_TinhTrangThai(
                            s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                            s.SucChua, ISNULL(d.SoDuyet, 0),
                            s.GioBatDau, s.GioKetThuc
                       );";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void HandleCommand(string cmd, string val)
        {
            try
            {
                switch (cmd)
                {
                    case "delete":
                        if (int.TryParse(val, out int delId)) DeleteEvent(delId);
                        break;

                    case "bulkDelete":
                        var ids = ParseIds(val);
                        foreach (var id in ids) DeleteEvent(id);
                        break;

                    case "toggleReg":
                        var parts = val.Split('|');
                        if (parts.Length == 2 && int.TryParse(parts[0], out int regId))
                        {
                            string newStatus = parts[1] == "true" ? "open" : "closed";
                            UpdateStatus(regId, newStatus);
                        }
                        break;

                    case "bulkOpen":
                        foreach (var id in ParseIds(val)) UpdateStatus(id, "open");
                        break;

                    case "bulkClose":
                        foreach (var id in ParseIds(val)) UpdateStatus(id, "closed");
                        break;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("AdminEvents command error: " + ex.Message);
            }
        }

        private List<int> ParseIds(string csv)
        {
            var result = new List<int>();
            if (string.IsNullOrWhiteSpace(csv)) return result;
            foreach (var s in csv.Split(','))
                if (int.TryParse(s.Trim(), out int id)) result.Add(id);
            return result;
        }

        // ════════════════════════════════════════════════════════════
        // LOAD STATS (4 stat cards)
        // ════════════════════════════════════════════════════════════

        private void LoadStats()
        {
            const string sql = @"
                ;WITH SK AS (
                    SELECT
                        s.SuKienID,
                        s.NgayBatDau,
                        dbo.fn_TinhTrangThai(
                            s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                            s.SucChua, ISNULL(d.SoDuyet, 0),
                            s.GioBatDau, s.GioKetThuc
                        ) AS TT
                    FROM dbo.SuKien s
                    LEFT JOIN (
                        SELECT SuKienID, COUNT(*) AS SoDuyet
                        FROM dbo.DangKy WHERE TrangThai = 'approved'
                        GROUP BY SuKienID
                    ) d ON s.SuKienID = d.SuKienID
                )
                SELECT
                    (SELECT COUNT(*) FROM SK WHERE TT NOT IN ('draft'))     AS Total,
                    (SELECT COUNT(*) FROM SK WHERE TT = 'open')                     AS OpenCnt,
                    (SELECT COUNT(*) FROM SK
                       WHERE TT IN ('open','closed')
                         AND NgayBatDau <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))) AS Upcoming,
                    (SELECT COUNT(*) FROM dbo.DangKy
                       WHERE TrangThai IN ('approved','pending'))                   AS Registrations;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        lblTotal.Text = rd["Total"].ToString();
                        lblOpen.Text = rd["OpenCnt"].ToString();
                        lblUpcoming.Text = rd["Upcoming"].ToString();
                        lblRegistrations.Text = rd["Registrations"].ToString();
                    }
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // LOAD EVENTS - Build JSON cho JS phía client
        // ════════════════════════════════════════════════════════════

        private void LoadEvents()
        {
            const string sql = @"
                SELECT
                    s.SuKienID,
                    s.TenSuKien,
                    s.LoaiSuKien,
                    s.NgayBatDau,
                    s.NgayKetThuc,
                    s.HanDangKy,
                    s.DiaDiem,
                    s.SucChua,
                    dbo.fn_TinhTrangThai(
                        s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                        s.SucChua, ISNULL(d.SoDuyet, 0),
                        s.GioBatDau, s.GioKetThuc
                    ) AS TrangThai,
                    ISNULL(d.SoDangKy, 0) AS SoDangKy,
                    ISNULL(d.SoDuyet, 0)  AS SoDuyet
                FROM dbo.SuKien s
                LEFT JOIN (
                    SELECT SuKienID,
                           COUNT(*) AS SoDangKy,
                           SUM(CASE WHEN TrangThai = 'approved' THEN 1 ELSE 0 END) AS SoDuyet
                    FROM dbo.DangKy
                    WHERE TrangThai IN ('approved','pending')
                    GROUP BY SuKienID
                ) d ON s.SuKienID = d.SuKienID
                ORDER BY s.NgayBatDau DESC;";

            var sb = new StringBuilder("[");
            bool first = true;
            DateTime today = DateTime.Today;

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        if (!first) sb.Append(",");
                        first = false;

                        int id = (int)rd["SuKienID"];
                        string name = rd["TenSuKien"].ToString();
                        string loai = rd["LoaiSuKien"].ToString();
                        DateTime ngay = (DateTime)rd["NgayBatDau"];
                        DateTime? hanDK = rd["HanDangKy"] as DateTime?;
                        string diaDiem = rd["DiaDiem"].ToString();
                        int sucChua = (int)rd["SucChua"];
                        string trangThai = rd["TrangThai"].ToString();
                        int soDangKy = (int)rd["SoDangKy"];
                        int soDuyet = (int)rd["SoDuyet"];

                        string emoji = GetEmojiByType(loai);

                        bool hetHan = hanDK.HasValue && hanDK.Value.Date < today;
                        bool hetCho = soDuyet >= sucChua;
                        bool ended = trangThai == "ended" || trangThai == "ongoing" || trangThai == "draft";
                        bool canOpen = !ended && !hetHan && !hetCho;
                        bool regOpen = (trangThai == "open");

                        string lyDo = "";
                        if (trangThai == "draft") lyDo = "Su kien dang la nhap";
                        else if (trangThai == "ongoing") lyDo = "Su kien dang dien ra";
                        else if (trangThai == "ended") lyDo = "Su kien da ket thuc";
                        else if (hetHan) lyDo = "Da het han dang ky";
                        else if (hetCho) lyDo = "Da het cho";

                        sb.Append("{");
                        sb.Append($"\"id\":{id},");
                        sb.Append($"\"name\":\"{JsEscape(name)}\",");
                        sb.Append($"\"emoji\":\"{emoji}\",");
                        sb.Append($"\"type\":\"{JsEscape(loai)}\",");
                        sb.Append($"\"date\":\"{ngay:dd/MM/yyyy}\",");
                        sb.Append($"\"month\":\"{ngay:MM}\",");
                        sb.Append($"\"loc\":\"{JsEscape(diaDiem)}\",");
                        sb.Append($"\"slots\":{sucChua},");
                        sb.Append($"\"taken\":{soDangKy},");
                        sb.Append($"\"approved\":{soDuyet},");
                        sb.Append($"\"status\":\"{trangThai}\",");
                        sb.Append($"\"regOpen\":{(regOpen ? "true" : "false")},");
                        sb.Append($"\"canOpen\":{(canOpen ? "true" : "false")},");
                        sb.Append($"\"lyDo\":\"{JsEscape(lyDo)}\"");
                        sb.Append("}");
                    }
                }
            }

            sb.Append("]");
            EventsJson = sb.ToString();
        }

        private string GetEmojiByType(string loai)
        {
            return "";
        }

        private string JsEscape(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\")
                    .Replace("\"", "\\\"")
                    .Replace("\r", "\\r")
                    .Replace("\n", "\\n")
                    .Replace("\t", "\\t");
        }

        // ════════════════════════════════════════════════════════════
        // DATA ACCESS - DELETE
        // ════════════════════════════════════════════════════════════

        private void DeleteEvent(int suKienID)
        {
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var tran = conn.BeginTransaction())
                {
                    try
                    {
                        ExecNonQuery(conn, tran,
                            "DELETE FROM dbo.Feedback    WHERE SuKienID = @id;", suKienID);
                        ExecNonQuery(conn, tran,
                            "DELETE FROM dbo.DanhSachCho WHERE SuKienID = @id;", suKienID);
                        ExecNonQuery(conn, tran,
                            "DELETE FROM dbo.ThongBao    WHERE SuKienID = @id;", suKienID);
                        ExecNonQuery(conn, tran,
                            "DELETE FROM dbo.DangKy      WHERE SuKienID = @id;", suKienID);
                        ExecNonQuery(conn, tran,
                            "DELETE FROM dbo.SuKien      WHERE SuKienID = @id;", suKienID);

                        tran.Commit();
                    }
                    catch
                    {
                        tran.Rollback();
                        throw;
                    }
                }
            }
        }

        private void ExecNonQuery(SqlConnection conn, SqlTransaction tran, string sql, int id)
        {
            using (var cmd = new SqlCommand(sql, conn, tran))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;
                cmd.ExecuteNonQuery();
            }
        }

        // ════════════════════════════════════════════════════════════
        // ADMIN TOGGLE: Mở/Đóng đăng ký thủ công
        // ════════════════════════════════════════════════════════════

        private void UpdateStatus(int suKienID, string newRegStatus)
        {
            if (newRegStatus == "open")
            {
                const string checkSql = @"
                    SELECT
                        s.TrangThai, s.SucChua, s.HanDangKy, s.NgayBatDau, s.NgayKetThuc,
                        ISNULL((SELECT COUNT(*) FROM dbo.DangKy d
                                 WHERE d.SuKienID = s.SuKienID AND d.TrangThai = 'approved'), 0) AS SoDuyet
                    FROM dbo.SuKien s
                    WHERE s.SuKienID = @id;";

                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(checkSql, conn))
                {
                    cmd.Parameters.Add("@id", SqlDbType.Int).Value = suKienID;
                    conn.Open();
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (!rd.Read()) return;

                        string trangThai = rd["TrangThai"].ToString();
                        int sucChua = (int)rd["SucChua"];
                        int soDuyet = (int)rd["SoDuyet"];
                        DateTime? hanDK = rd["HanDangKy"] as DateTime?;
                        DateTime ngayBD = (DateTime)rd["NgayBatDau"];
                        DateTime? ngayKT = rd["NgayKetThuc"] as DateTime?;
                        DateTime today = DateTime.Today;
                        DateTime ngayKt = ngayKT ?? ngayBD;

                        if (trangThai == "ended" || trangThai == "ongoing" || trangThai == "draft") return;
                        if (ngayKt.Date < today) return;
                        if (ngayBD.Date <= today) return;
                        if (soDuyet >= sucChua) return;
                        if (hanDK.HasValue && hanDK.Value.Date < today) return;
                    }
                }
            }

            const string sql = @"
                UPDATE dbo.SuKien
                   SET TrangThai = @status, NgayCapNhat = GETDATE()
                 WHERE SuKienID = @id;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = suKienID;
                cmd.Parameters.Add("@status", SqlDbType.NVarChar, 20).Value = newRegStatus;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ════════════════════════════════════════════════════════════
        // BUTTON HANDLERS
        // ════════════════════════════════════════════════════════════

        protected void Filter_Changed(object sender, EventArgs e) { /* JS xử lý */ }
        protected void btnFilter_Click(object sender, EventArgs e) { /* JS xử lý */ }
        protected void btnSearch_Click(object sender, EventArgs e) { /* JS xử lý */ }
        protected void btnBulkDel_Click(object sender, EventArgs e) { /* JS xử lý */ }

        protected void gvEvents_PageIndexChanging(object sender, GridViewPageEventArgs e) { }

        protected void gvEvents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string id = e.CommandArgument.ToString();
            if (e.CommandName == "EditEv")
                Response.Redirect("AdminEventForm.aspx?id=" + id);
            else if (e.CommandName == "DeleteEv" && int.TryParse(id, out int delId))
                DeleteEvent(delId);
        }
    }
}