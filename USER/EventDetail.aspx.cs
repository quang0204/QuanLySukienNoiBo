using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace QuanLySuKien
{
    public partial class EventDetail : System.Web.UI.Page
    {
        private static readonly string ConnStr =
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        public int FillPct { get; private set; } = 0;
        private int _eventId = 0;

        private int CurrentUserId =>
            Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int uid) ? uid : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login_Regis.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            int.TryParse(Request.QueryString["id"], out _eventId);
            if (_eventId <= 0)
            {
                Response.Redirect("Events.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadEventDetails(_eventId);
                BindAttendees(_eventId);
                BindEventInfo();
                BindLocationGrid();
                BindSimilarEvents(_eventId);
                UpdateRegisterButton(_eventId);
            }
        }

        // ════════════════════════════════════════════════════════════
        // LOAD MAIN DETAILS
        // ════════════════════════════════════════════════════════════

        private void LoadEventDetails(int id)
        {
            const string sql = @"
                SELECT
                    s.SuKienID, s.TenSuKien, s.MoTa, s.LoaiSuKien,
                    s.NgayBatDau, s.NgayKetThuc, s.GioBatDau, s.GioKetThuc,
                    s.DiaDiem, s.LinkBanDo, s.SucChua, s.HanDangKy, s.AnhBia,
                    dbo.fn_TinhTrangThai(s.TrangThai, s.NgayBatDau, s.NgayKetThuc,
                        s.HanDangKy, s.SucChua, ISNULL(d.SoDuyet,0), s.GioBatDau, s.GioKetThuc) AS TrangThai,
                    ISNULL(d.SoDangKy, 0) AS SoDangKy
                FROM dbo.SuKien s
                LEFT JOIN (
                    SELECT SuKienID,
                           COUNT(*) AS SoDangKy,
                           SUM(CASE WHEN TrangThai = 'approved' THEN 1 ELSE 0 END) AS SoDuyet
                    FROM dbo.DangKy WHERE TrangThai IN ('approved','pending')
                    GROUP BY SuKienID
                ) d ON s.SuKienID = d.SuKienID
                WHERE s.SuKienID = @id;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (!rd.Read())
                    {
                        Response.Redirect("Events.aspx", false);
                        return;
                    }

                    string ten = rd["TenSuKien"].ToString();
                    string moTa = rd["MoTa"] as string ?? "";
                    string loai = rd["LoaiSuKien"].ToString();
                    DateTime ngayBD = (DateTime)rd["NgayBatDau"];
                    DateTime? ngayKT = rd["NgayKetThuc"] as DateTime?;
                    TimeSpan gioBD = (TimeSpan)rd["GioBatDau"];
                    TimeSpan? gioKT = rd["GioKetThuc"] as TimeSpan?;
                    string diaDiem = rd["DiaDiem"].ToString();
                    int sucChua = (int)rd["SucChua"];
                    DateTime? hanDK = rd["HanDangKy"] as DateTime?;
                    string trangThai = rd["TrangThai"].ToString();
                    int soDK = (int)rd["SoDangKy"];

                    int pct = sucChua > 0 ? (int)Math.Round(soDK * 100.0 / sucChua) : 0;
                    FillPct = Math.Min(pct, 100);
                    int conLai = Math.Max(0, sucChua - soDK);

                    // Header / breadcrumb
                    lblBreadcrumb.Text = ten;
                    lblEventTitle.Text = ten;
                    lblEventSubtitle.Text = moTa;

                    if (lblStatusBadge != null) lblStatusBadge.Text = StatusLabel(trangThai);
                    if (lblCategoryBadge != null) lblCategoryBadge.Text = loai;

                    // Hero summary
                    lblHsDayOfWeek.Text = FormatDayOfWeek(ngayBD);
                    lblHsDate.Text = FormatDateRange(ngayBD, ngayKT);
                    lblHsTime.Text = FormatTimeRange(gioBD, gioKT);
                    lblHsLocation.Text = diaDiem;

                    // Sidebar - đăng ký
                    lblRegCount.Text = soDK.ToString();
                    lblTotalSlots.Text = sucChua.ToString();
                    lblFillPct.Text = pct + "% da lap day - Con " + conLai + " cho";
                    lblDeadline.Text = hanDK.HasValue ? hanDK.Value.ToString("dd/MM/yyyy") : "-";
                    lblAttCount.Text = soDK.ToString();
                    lblMoreAttendees.Text = Math.Max(0, soDK - 4).ToString();

                    // Modal
                    if (lblModalEventName != null) lblModalEventName.Text = ten;
                    if (lblModalDate != null) lblModalDate.Text = FormatDayOfWeek(ngayBD) + ", " + ngayBD.ToString("dd/MM/yyyy");
                    if (lblModalTime != null) lblModalTime.Text = FormatTimeRange(gioBD, gioKT);
                    if (lblModalLoc != null) lblModalLoc.Text = diaDiem;

                    // Description
                    litDescription.Text = string.IsNullOrEmpty(moTa)
                        ? "<p>(Su kien nay chua co mo ta chi tiet)</p>"
                        : "<p>" + Server.HtmlEncode(moTa).Replace("\n", "</p><p>") + "</p>";

                    // Map pin (neu co LinkBanDo)
                    string linkBanDo = rd["LinkBanDo"] as string;
                    if (lblMapPin != null) lblMapPin.Text = string.IsNullOrEmpty(linkBanDo) ? diaDiem : diaDiem;
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // ATTENDEES (4 người đầu)
        // ════════════════════════════════════════════════════════════

        private void BindAttendees(int eventId)
        {
            const string sql = @"
                SELECT TOP 4
                    u.UserID, u.Ho, u.Ten, u.PhongBan
                FROM dbo.DangKy dk
                INNER JOIN dbo.Users u ON dk.UserID = u.UserID
                WHERE dk.SuKienID = @id AND dk.TrangThai = 'approved'
                ORDER BY dk.NgayDangKy ASC;";

            var list = new List<AttendeeItem>();
            string[] avaColors = { "#1a1a1a", "#404040", "#737373", "#2d2d2d" };
            int idx = 0;
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = eventId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        string ho = rd["Ho"].ToString();
                        string ten = rd["Ten"].ToString();
                        list.Add(new AttendeeItem
                        {
                            Initials = (LeftLetter(ho) + LeftLetter(ten)).ToUpper(),
                            Name = (ho + " " + ten).Trim(),
                            Dept = rd["PhongBan"] as string ?? "-",
                            AvaColor = avaColors[idx % avaColors.Length]
                        });
                        idx++;
                    }
                }
            }
            rptAttendees.DataSource = list;
            rptAttendees.DataBind();
        }

        // ════════════════════════════════════════════════════════════
        // EVENT INFO / LOCATION GRID (rút từ DB)
        // ════════════════════════════════════════════════════════════

        private void BindEventInfo()
        {
            const string sql = @"
                SELECT TenSuKien, LoaiSuKien, NgayBatDau, NgayKetThuc,
                       GioBatDau, GioKetThuc, DiaDiem, SucChua
                FROM dbo.SuKien WHERE SuKienID = @id;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = _eventId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (!rd.Read()) return;

                    DateTime bd = (DateTime)rd["NgayBatDau"];
                    DateTime? kt = rd["NgayKetThuc"] as DateTime?;
                    TimeSpan gbd = (TimeSpan)rd["GioBatDau"];
                    TimeSpan? gkt = rd["GioKetThuc"] as TimeSpan?;
                    string diaDiem = rd["DiaDiem"].ToString();
                    string loai = rd["LoaiSuKien"].ToString();
                    int sucChua = (int)rd["SucChua"];

                    rptEventInfo.DataSource = new[]
                    {
                        new { Label = "Ngay",      Value = FormatDayOfWeek(bd) + ", " + FormatDateRange(bd, kt), Style = "" },
                        new { Label = "Gio",       Value = FormatTimeRange(gbd, gkt), Style = "" },
                        new { Label = "Dia diem",  Value = diaDiem, Style = "" },
                        new { Label = "Loai",      Value = loai, Style = "" },
                        new { Label = "Suc chua",  Value = sucChua + " nguoi", Style = "" }
                    };
                    rptEventInfo.DataBind();
                }
            }
        }

        private void BindLocationGrid()
        {
            const string sql = "SELECT DiaDiem, LinkBanDo, SucChua FROM dbo.SuKien WHERE SuKienID = @id;";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = _eventId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (!rd.Read()) return;

                    string diaDiem = rd["DiaDiem"].ToString();
                    string linkBD = rd["LinkBanDo"] as string ?? "-";
                    int sucChua = (int)rd["SucChua"];

                    rptLocationGrid.DataSource = new[]
                    {
                        new { Label = "Dia diem",   Value = diaDiem },
                        new { Label = "Ban do",     Value = string.IsNullOrEmpty(linkBD) || linkBD == "-" ? "-"
                                                          : "<a href=\"" + Server.HtmlEncode(linkBD) + "\" target=\"_blank\" style=\"color:inherit;text-decoration:underline\">Xem ban do</a>" },
                        new { Label = "Suc chua",   Value = sucChua + " nguoi" }
                    };
                    rptLocationGrid.DataBind();
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // SIMILAR EVENTS (cùng LoaiSuKien, khác ID)
        // ════════════════════════════════════════════════════════════

        private void BindSimilarEvents(int currentId)
        {
            const string sql = @"
                SELECT TOP 3
                    s.SuKienID, s.TenSuKien, s.NgayBatDau, s.GioBatDau, s.DiaDiem,
                    s.SucChua, ISNULL(d.SoDangKy, 0) AS SoDangKy
                FROM dbo.SuKien s
                LEFT JOIN (
                    SELECT SuKienID, COUNT(*) AS SoDangKy
                    FROM dbo.DangKy WHERE TrangThai IN ('approved','pending')
                    GROUP BY SuKienID
                ) d ON s.SuKienID = d.SuKienID
                WHERE s.SuKienID <> @currentId
                  AND s.TrangThai NOT IN ('draft','ended')
                  AND s.LoaiSuKien = (SELECT LoaiSuKien FROM dbo.SuKien WHERE SuKienID = @currentId)
                ORDER BY s.NgayBatDau ASC;";

            string[] monthLabels = { "TH1", "TH2", "TH3", "TH4", "TH5", "TH6", "TH7", "TH8", "TH9", "TH10", "TH11", "TH12" };
            var list = new List<SimilarEventItem>();

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@currentId", SqlDbType.Int).Value = currentId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        DateTime bd = (DateTime)rd["NgayBatDau"];
                        TimeSpan gbd = (TimeSpan)rd["GioBatDau"];
                        int sucChua = (int)rd["SucChua"];
                        int soDK = (int)rd["SoDangKy"];

                        list.Add(new SimilarEventItem
                        {
                            Id = (int)rd["SuKienID"],
                            Day = bd.Day.ToString("00"),
                            MonthLabel = monthLabels[bd.Month - 1],
                            Title = rd["TenSuKien"].ToString(),
                            Sub = string.Format("{0} - {1} - {2}/{3}",
                                gbd.ToString(@"hh\:mm"),
                                rd["DiaDiem"].ToString(),
                                soDK, sucChua)
                        });
                    }
                }
            }
            rptSimilarEvents.DataSource = list;
            rptSimilarEvents.DataBind();
        }

        // ════════════════════════════════════════════════════════════
        // REGISTER / CANCEL
        // ════════════════════════════════════════════════════════════

        private void UpdateRegisterButton(int eventId)
        {
            // 1. Check trang thai SU KIEN truoc (uu tien cao nhat)
            string eventStatus = GetEventStatus(eventId);

            if (eventStatus == "ended")
            {
                btnRegister.Text = "Da ket thuc";
                btnRegister.CssClass = "btn-register registered";
                btnRegister.Enabled = false;
                btnCancelReg.Visible = false;
                return;
            }

            if (eventStatus == "ongoing")
            {
                btnRegister.Text = "Dang dien ra";
                btnRegister.CssClass = "btn-register registered";
                btnRegister.Enabled = false;
                btnCancelReg.Visible = false;
                return;
            }

            // 2. Check da diem danh
            bool daDiemDanh = HasAttended(eventId, CurrentUserId);
            if (daDiemDanh)
            {
                btnRegister.Text = "Da tham gia";
                btnRegister.CssClass = "btn-register registered";
                btnRegister.Enabled = false;
                btnCancelReg.Visible = false;
                return;
            }

            // 3. Check trang thai DK cua user
            string status = GetMyRegistrationStatus(eventId);
            if (status == "approved" || status == "pending")
            {
                btnRegister.Text = status == "pending" ? "Cho duyet" : "Da dang ky";
                btnRegister.CssClass = "btn-register registered";
                btnRegister.Enabled = false;

                // Chi hien nut huy neu su kien cho phep
                if (IsCancelAllowed(eventId))
                {
                    btnCancelReg.Visible = true;
                    btnCancelReg.Text = "Huy dang ky";
                    btnCancelReg.Enabled = true;
                }
                else
                {
                    btnCancelReg.Visible = true;
                    btnCancelReg.Text = "Khong the huy";
                    btnCancelReg.Enabled = false;
                }
                return;
            }

            // 4. Su kien dong dang ky (closed)
            if (eventStatus == "closed")
            {
                btnRegister.Text = "Da dong dang ky";
                btnRegister.CssClass = "btn-register registered";
                btnRegister.Enabled = false;
                btnCancelReg.Visible = false;
                return;
            }

            // 5. Mac dinh: dang mo dang ky
            btnRegister.Text = "Dang ky tham gia";
            btnRegister.CssClass = "btn-register";
            btnRegister.Enabled = true;
            btnCancelReg.Visible = false;
        }

        /// <summary>Lay trang thai dong hoc cua su kien (real-time, co tinh gio)</summary>
        private string GetEventStatus(int eventId)
        {
            const string sql = @"
                SELECT dbo.fn_TinhTrangThai(
                    s.TrangThai, s.NgayBatDau, s.NgayKetThuc,
                    s.HanDangKy, s.SucChua,
                    ISNULL((SELECT COUNT(*) FROM dbo.DangKy
                            WHERE SuKienID = s.SuKienID AND TrangThai = 'approved'), 0),
                    s.GioBatDau, s.GioKetThuc)
                FROM dbo.SuKien s
                WHERE s.SuKienID = @id;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = eventId;
                conn.Open();
                var r = cmd.ExecuteScalar();
                return r?.ToString() ?? "open";
            }
        }

        private bool HasAttended(int eventId, int userId)
        {
            const string sql = @"SELECT COUNT(*) FROM dbo.DangKy
                                 WHERE UserID = @u AND SuKienID = @s AND DaDiemDanh = 1;";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@u", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@s", SqlDbType.Int).Value = eventId;
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        /// <summary>Check su kien co cho phep huy DK khong (ChoPhepHuy)</summary>
        private bool IsCancelAllowed(int eventId)
        {
            const string sql = @"SELECT ChoPhepHuy FROM dbo.SuKien WHERE SuKienID = @id;";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = eventId;
                conn.Open();
                var v = cmd.ExecuteScalar();
                if (v == null || v == DBNull.Value) return true;
                return (bool)v;
            }
        }

        private string GetMyRegistrationStatus(int eventId)
        {
            const string sql = @"
                SELECT TrangThai FROM dbo.DangKy
                WHERE UserID = @u AND SuKienID = @s AND TrangThai <> 'cancelled';";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@u", SqlDbType.Int).Value = CurrentUserId;
                cmd.Parameters.Add("@s", SqlDbType.Int).Value = eventId;
                conn.Open();
                var r = cmd.ExecuteScalar();
                return r?.ToString();
            }
        }

        protected void btnConfirmRegister_Click(object sender, EventArgs e)
        {
            try
            {
                // Check trang thai su kien - khong cho dang ky neu da ket thuc / dang dien ra / dong DK
                string eventStatus = GetEventStatus(_eventId);
                if (eventStatus == "ended")
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                        "if(window.showToast)showToast('Su kien da ket thuc, khong the dang ky.');", true);
                    UpdateRegisterButton(_eventId);
                    return;
                }
                if (eventStatus == "ongoing")
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                        "if(window.showToast)showToast('Su kien dang dien ra, khong the dang ky.');", true);
                    UpdateRegisterButton(_eventId);
                    return;
                }
                if (eventStatus == "closed")
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                        "if(window.showToast)showToast('Su kien da dong dang ky.');", true);
                    UpdateRegisterButton(_eventId);
                    return;
                }

                RegisterEvent(_eventId, CurrentUserId);
                LoadEventDetails(_eventId);
                BindAttendees(_eventId);
                UpdateRegisterButton(_eventId);
                ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                    "if(window.showToast)showToast('Dang ky thanh cong!');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                    "if(window.showToast)showToast('Loi: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
        }

        protected void btnCancelReg_Click(object sender, EventArgs e)
        {
            try
            {
                if (HasAttended(_eventId, CurrentUserId))
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                        "if(window.showToast)showToast('Ban da tham gia, khong the huy.');", true);
                    UpdateRegisterButton(_eventId);
                    return;
                }

                // Check su kien co cho phep huy DK khong
                if (!IsCancelAllowed(_eventId))
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                        "if(window.showToast)showToast('Su kien nay khong cho phep huy dang ky.');", true);
                    UpdateRegisterButton(_eventId);
                    return;
                }

                // Check trang thai su kien - khong cho huy neu da ket thuc / dang dien ra
                string eventStatus = GetEventStatus(_eventId);
                if (eventStatus == "ended" || eventStatus == "ongoing")
                {
                    string msg = eventStatus == "ended"
                        ? "Su kien da ket thuc, khong the huy."
                        : "Su kien dang dien ra, khong the huy.";
                    ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                        "if(window.showToast)showToast('" + msg + "');", true);
                    UpdateRegisterButton(_eventId);
                    return;
                }

                CancelRegistration(_eventId, CurrentUserId);
                LoadEventDetails(_eventId);
                BindAttendees(_eventId);
                UpdateRegisterButton(_eventId);
                ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                    "if(window.showToast)showToast('Da huy dang ky.');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                    "if(window.showToast)showToast('Loi: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
        }

        private void RegisterEvent(int suKienID, int userID)
        {
            const string sql = @"
                IF EXISTS (SELECT 1 FROM dbo.DangKy WHERE UserID=@u AND SuKienID=@s)
                BEGIN
                    UPDATE dbo.DangKy
                       SET TrangThai = CASE WHEN (SELECT YeuCauDuyet FROM dbo.SuKien WHERE SuKienID=@s) = 1
                                            THEN 'pending' ELSE 'approved' END,
                           NgayCapNhat = GETDATE()
                     WHERE UserID=@u AND SuKienID=@s;
                END
                ELSE
                BEGIN
                    INSERT INTO dbo.DangKy (UserID, SuKienID, TrangThai)
                    VALUES (@u, @s,
                            CASE WHEN (SELECT YeuCauDuyet FROM dbo.SuKien WHERE SuKienID=@s) = 1
                                 THEN 'pending' ELSE 'approved' END);
                END";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@u", SqlDbType.Int).Value = userID;
                cmd.Parameters.Add("@s", SqlDbType.Int).Value = suKienID;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void CancelRegistration(int suKienID, int userID)
        {
            const string sql = @"
                UPDATE dbo.DangKy
                   SET TrangThai = 'cancelled', NgayCapNhat = GETDATE()
                 WHERE UserID = @u AND SuKienID = @s;";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@u", SqlDbType.Int).Value = userID;
                cmd.Parameters.Add("@s", SqlDbType.Int).Value = suKienID;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ════════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════════

        private static string LeftLetter(string s) => string.IsNullOrEmpty(s) ? "" : s.Substring(0, 1);

        private static string FormatDayOfWeek(DateTime d)
        {
            switch (d.DayOfWeek)
            {
                case DayOfWeek.Monday: return "Thu Hai";
                case DayOfWeek.Tuesday: return "Thu Ba";
                case DayOfWeek.Wednesday: return "Thu Tu";
                case DayOfWeek.Thursday: return "Thu Nam";
                case DayOfWeek.Friday: return "Thu Sau";
                case DayOfWeek.Saturday: return "Thu Bay";
                default: return "Chu Nhat";
            }
        }

        private static string FormatDateRange(DateTime bd, DateTime? kt)
        {
            if (!kt.HasValue || kt.Value.Date == bd.Date) return bd.ToString("dd/MM/yyyy");
            if (bd.Month == kt.Value.Month && bd.Year == kt.Value.Year)
                return bd.ToString("dd") + "-" + kt.Value.ToString("dd/MM/yyyy");
            return bd.ToString("dd/MM") + " - " + kt.Value.ToString("dd/MM/yyyy");
        }

        private static string FormatTimeRange(TimeSpan bd, TimeSpan? kt)
        {
            string s = bd.ToString(@"hh\:mm");
            if (kt.HasValue) s += " - " + kt.Value.ToString(@"hh\:mm");
            return s;
        }

        private static string StatusLabel(string s)
        {
            switch (s)
            {
                case "open": return "Dang mo dang ky";
                case "closed": return "Da dong dang ky";
                case "ongoing": return "Dang dien ra";
                case "ended": return "Da ket thuc";
                default: return "Nhap";
            }
        }

        // ════════════════════════════════════════════════════════════
        // MODELS
        // ════════════════════════════════════════════════════════════

        public class AttendeeItem
        {
            public string Initials { get; set; }
            public string Name { get; set; }
            public string Dept { get; set; }
            public string AvaColor { get; set; }
        }

        public class SimilarEventItem
        {
            public int Id { get; set; }
            public string Day { get; set; }
            public string MonthLabel { get; set; }
            public string Title { get; set; }
            public string Sub { get; set; }
        }
    }
}