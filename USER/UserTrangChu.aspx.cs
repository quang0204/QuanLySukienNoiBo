using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;

namespace QuanLySuKien
{
    public partial class UserTrangChu : System.Web.UI.Page
    {
        private static readonly string ConnStr =
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        // Tháng đang hiển thị trên mini calendar
        private DateTime CalendarMonth
        {
            get
            {
                if (ViewState["CalMonth"] is DateTime d) return d;
                return new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            }
            set { ViewState["CalMonth"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Chua dang nhap -> redirect
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login_Regis.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Admin -> redirect ve AdminDashboard
            string vaiTro = Session["VaiTro"]?.ToString() ?? "";
            if (vaiTro == "admin")
            {
                Response.Redirect("~/Admin/AdminDashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadUserInfo();
                LoadUserStats();
                LoadAnnounceBanner();
                BindHomeEvents();
                BindRegisteredEvents();
                BindMyEvents();
                RenderMiniCalendar();
            }
        }

        // ════════════════════════════════════════════════════════════
        // ANNOUNCE BANNER (top) - lấy sự kiện mới nhất chưa diễn ra
        // ════════════════════════════════════════════════════════════

        private void LoadAnnounceBanner()
        {
            const string sql = @"
                SELECT TOP 1
                    s.SuKienID, s.TenSuKien, s.NgayBatDau, s.HanDangKy, s.DiaDiem
                FROM dbo.SuKien s
                WHERE s.TrangThai NOT IN ('draft','ended')
                  AND s.NgayBatDau >= CAST(GETDATE() AS DATE)
                ORDER BY s.NgayTao DESC;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        int id = (int)rd["SuKienID"];
                        string ten = rd["TenSuKien"].ToString();
                        string diaDiem = rd["DiaDiem"].ToString();
                        DateTime? hanDK = rd["HanDangKy"] as DateTime?;

                        string text = ten + " tai " + diaDiem;
                        if (hanDK.HasValue)
                            text += " - Dang ky truoc " + hanDK.Value.ToString("dd/MM");

                        lblAnnounceText.Text = text;
                        lnkAnnounce.NavigateUrl = "EventDetail.aspx?id=" + id;
                        pnlAnnounce.Visible = true;
                    }
                    else
                    {
                        // Khong co su kien sap toi -> an banner
                        pnlAnnounce.Visible = false;
                    }
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // USER INFO + STATS
        // ════════════════════════════════════════════════════════════

        private int CurrentUserId =>
            Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int uid) ? uid : 0;

        private void LoadUserInfo()
        {
            const string sql = @"
                SELECT u.Ho, u.Ten, u.PhongBan, u.ChucVu
                FROM dbo.Users u WHERE u.UserID = @id;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = CurrentUserId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        string ho = rd["Ho"].ToString();
                        string ten = rd["Ten"].ToString();
                        string fullName = (ho + " " + ten).Trim();
                        string role = (rd["ChucVu"] as string) ?? "";
                        string pb = (rd["PhongBan"] as string) ?? "";
                        string roleText = string.IsNullOrEmpty(role) ? pb
                                       : (string.IsNullOrEmpty(pb) ? role : role + " · " + pb);

                        lblHeroName.Text = fullName;
                        lblHeroRole.Text = roleText;
                        lblSideName.Text = fullName;
                        lblSideRole.Text = roleText;
                        lblSideInitials.Text = GetInitials(ho, ten);
                    }
                }
            }
        }

        private void LoadUserStats()
        {
            const string sql = @"
                SELECT
                    (SELECT COUNT(*) FROM dbo.DangKy
                       WHERE UserID = @id AND TrangThai IN ('approved','pending')) AS Registered,
                    (SELECT COUNT(*) FROM dbo.DangKy
                       WHERE UserID = @id AND DaDiemDanh = 1)                       AS Attended,
                    (SELECT AVG(CAST(Diem AS DECIMAL(3,1))) FROM dbo.Feedback
                       WHERE UserID = @id)                                          AS AvgRating;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = CurrentUserId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        int reg = rd["Registered"] == DBNull.Value ? 0 : (int)rd["Registered"];
                        int att = rd["Attended"] == DBNull.Value ? 0 : (int)rd["Attended"];
                        decimal rating = rd["AvgRating"] == DBNull.Value ? 0m : (decimal)rd["AvgRating"];
                        int rate = reg > 0 ? (int)Math.Round(att * 100.0 / reg) : 0;

                        lblStatRegistered.Text = reg.ToString();
                        lblStatAttended.Text = att.ToString();
                        lblStatRating.Text = rating == 0 ? "-" : rating.ToString("0.0") + "/5";

                        lblPwAttended.Text = att.ToString();
                        lblPwRate.Text = rate + "%";
                        lblPwRating.Text = rating == 0 ? "-" : rating.ToString("0.0");
                    }
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // SỰ KIỆN TRANG CHỦ (4 sự kiện sắp tới)
        // ════════════════════════════════════════════════════════════

        private void BindHomeEvents()
        {
            const string sql = @"
                SELECT TOP 4
                    s.SuKienID, s.TenSuKien, s.LoaiSuKien, s.NgayBatDau, s.NgayKetThuc,
                    s.DiaDiem, s.SucChua, s.AnhBia, s.HanDangKy, s.ChoPhepHuy,
                    dbo.fn_TinhTrangThai(s.TrangThai, s.NgayBatDau, s.NgayKetThuc,
                        s.HanDangKy, s.SucChua, ISNULL(d.SoDuyet,0), s.GioBatDau, s.GioKetThuc) AS TrangThai,
                    ISNULL(d.SoDangKy, 0) AS SoDangKy,
                    ISNULL(d.SoDuyet, 0)  AS SoDuyet,
                    CASE WHEN EXISTS(SELECT 1 FROM dbo.DangKy
                          WHERE UserID = @uid AND SuKienID = s.SuKienID
                            AND TrangThai IN ('approved','pending'))
                         THEN 1 ELSE 0 END AS IsMine
                FROM dbo.SuKien s
                LEFT JOIN (
                    SELECT SuKienID,
                           COUNT(*) AS SoDangKy,
                           SUM(CASE WHEN TrangThai = 'approved' THEN 1 ELSE 0 END) AS SoDuyet
                    FROM dbo.DangKy WHERE TrangThai IN ('approved','pending')
                    GROUP BY SuKienID
                ) d ON s.SuKienID = d.SuKienID
                WHERE s.TrangThai NOT IN ('draft','ended')
                  AND (s.NgayKetThuc IS NULL OR s.NgayKetThuc >= CAST(GETDATE() AS DATE))
                ORDER BY s.NgayBatDau ASC;";

            rptHomeEvents.DataSource = QueryEventList(sql);
            rptHomeEvents.DataBind();
        }

        // ════════════════════════════════════════════════════════════
        // SỰ KIỆN ĐÃ ĐĂNG KÝ (main column)
        // ════════════════════════════════════════════════════════════

        private void BindRegisteredEvents()
        {
            const string sql = @"
                SELECT TOP 6
                    s.SuKienID, s.TenSuKien, s.LoaiSuKien, s.NgayBatDau, s.NgayKetThuc,
                    s.DiaDiem, s.AnhBia,
                    dbo.fn_TinhTrangThai(s.TrangThai, s.NgayBatDau, s.NgayKetThuc,
                        s.HanDangKy, s.SucChua,
                        ISNULL((SELECT COUNT(*) FROM dbo.DangKy
                                WHERE SuKienID = s.SuKienID AND TrangThai = 'approved'), 0), s.GioBatDau, s.GioKetThuc) AS TrangThai,
                    dk.TrangThai AS DangKyStatus,
                    dk.DaDiemDanh
                FROM dbo.DangKy dk
                INNER JOIN dbo.SuKien s ON dk.SuKienID = s.SuKienID
                WHERE dk.UserID = @uid
                  AND dk.TrangThai IN ('approved','pending')
                ORDER BY s.NgayBatDau ASC;";

            var list = new List<RegisteredEventItem>();
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@uid", SqlDbType.Int).Value = CurrentUserId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        string trangThai = rd["TrangThai"].ToString();
                        string dkStatus = rd["DangKyStatus"].ToString();
                        bool daDiemDanh = (bool)rd["DaDiemDanh"];

                        // Label trang thai DK + diem danh
                        string dkLabel;
                        if (daDiemDanh) dkLabel = "Đã tham gia";
                        else if (dkStatus == "pending") dkLabel = "Chờ duyệt";
                        else dkLabel = "Đã duyệt";

                        // Co the huy khong?
                        // - Da diem danh -> KHONG (da tham gia)
                        // - Su kien da ket thuc -> KHONG (qua roi)
                        // - Dang dien ra -> KHONG (dang ay)
                        bool canCancel = !daDiemDanh
                                          && trangThai != "ended"
                                          && trangThai != "ongoing";

                        list.Add(new RegisteredEventItem
                        {
                            Id = (int)rd["SuKienID"],
                            Name = rd["TenSuKien"].ToString(),
                            Tag = (rd["LoaiSuKien"] as string ?? "").ToUpper(),
                            AnhBia = rd["AnhBia"] as string ?? "",
                            Date = FormatDate((DateTime)rd["NgayBatDau"], rd["NgayKetThuc"] as DateTime?),
                            Location = rd["DiaDiem"].ToString(),
                            StatusCss = StatusToCss(trangThai),
                            StatusLabel = StatusToLabel(trangThai),
                            DkStatusLabel = dkLabel,
                            CanCancel = canCancel
                        });
                    }
                }
            }

            rptRegisteredEvents.DataSource = list;
            rptRegisteredEvents.DataBind();
            pnlNoRegistered.Visible = list.Count == 0;
        }

        // ════════════════════════════════════════════════════════════
        // SỰ KIỆN CỦA TÔI
        // ════════════════════════════════════════════════════════════

        private void BindMyEvents()
        {
            const string sql = @"
                SELECT TOP 5
                    s.SuKienID, s.TenSuKien, s.LoaiSuKien, s.NgayBatDau, s.NgayKetThuc,
                    s.DiaDiem,
                    dk.TrangThai AS DangKyStatus,
                    dk.DaDiemDanh
                FROM dbo.DangKy dk
                INNER JOIN dbo.SuKien s ON dk.SuKienID = s.SuKienID
                WHERE dk.UserID = @uid AND dk.TrangThai <> 'cancelled'
                ORDER BY s.NgayBatDau DESC;";

            var list = new List<MyEventItem>();
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@uid", SqlDbType.Int).Value = CurrentUserId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    DateTime today = DateTime.Today;
                    while (rd.Read())
                    {
                        DateTime bd = (DateTime)rd["NgayBatDau"];
                        DateTime kt = (rd["NgayKetThuc"] as DateTime?) ?? bd;
                        string dkStatus = rd["DangKyStatus"].ToString();
                        bool daDiemDanh = (bool)rd["DaDiemDanh"];

                        string css, label;
                        if (daDiemDanh) { css = "mev-attended"; label = "DA DU"; }
                        else if (dkStatus == "pending") { css = "mev-pending"; label = "CHO DUYET"; }
                        else if (kt < today) { css = "mev-attended"; label = "DA QUA"; }
                        else { css = "mev-upcoming"; label = "SAP TOI"; }

                        list.Add(new MyEventItem
                        {
                            Id = (int)rd["SuKienID"],
                            Emoji = "",
                            Name = rd["TenSuKien"].ToString(),
                            DateShort = bd.ToString("dd/MM"),
                            Location = rd["DiaDiem"].ToString(),
                            StatusCss = css,
                            StatusLabel = label
                        });
                    }
                }
            }
            rptMyEvents.DataSource = list;
            rptMyEvents.DataBind();
        }

        // ════════════════════════════════════════════════════════════
        // MINI CALENDAR
        // ════════════════════════════════════════════════════════════

        protected void btnCalPrev_Click(object sender, EventArgs e)
        {
            CalendarMonth = CalendarMonth.AddMonths(-1);
            RenderMiniCalendar();
        }

        protected void btnCalNext_Click(object sender, EventArgs e)
        {
            CalendarMonth = CalendarMonth.AddMonths(1);
            RenderMiniCalendar();
        }

        private void RenderMiniCalendar()
        {
            DateTime month = CalendarMonth;
            lblCalMonth.Text = month.ToString("MM/yyyy");

            // Chi lay cac ngay co su kien MA USER DA DANG KY
            // (bao gom approved & pending, khong tinh cancelled)
            // Lay ca khoang NgayBatDau -> NgayKetThuc (su kien nhieu ngay)
            var eventDays = new HashSet<int>();
            const string sql = @"
                SELECT s.NgayBatDau, s.NgayKetThuc
                  FROM dbo.DangKy dk
                  INNER JOIN dbo.SuKien s ON dk.SuKienID = s.SuKienID
                 WHERE dk.UserID = @uid
                   AND dk.TrangThai IN ('approved','pending')
                   AND (
                        (YEAR(s.NgayBatDau) = @y AND MONTH(s.NgayBatDau) = @m)
                     OR (s.NgayKetThuc IS NOT NULL
                         AND YEAR(s.NgayKetThuc) = @y AND MONTH(s.NgayKetThuc) = @m)
                     OR (s.NgayKetThuc IS NOT NULL
                         AND s.NgayBatDau <= @lastDay
                         AND s.NgayKetThuc >= @firstDay)
                   );";

            DateTime firstDay = new DateTime(month.Year, month.Month, 1);
            DateTime lastDay = firstDay.AddMonths(1).AddDays(-1);

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@uid", SqlDbType.Int).Value = CurrentUserId;
                cmd.Parameters.Add("@y", SqlDbType.Int).Value = month.Year;
                cmd.Parameters.Add("@m", SqlDbType.Int).Value = month.Month;
                cmd.Parameters.Add("@firstDay", SqlDbType.Date).Value = firstDay;
                cmd.Parameters.Add("@lastDay", SqlDbType.Date).Value = lastDay;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        DateTime bd = (DateTime)rd["NgayBatDau"];
                        DateTime kt = (rd["NgayKetThuc"] as DateTime?) ?? bd;

                        // Highlight tat ca ngay trong khoang [bd, kt] thuoc thang dang xem
                        DateTime start = bd > firstDay ? bd : firstDay;
                        DateTime end = kt < lastDay ? kt : lastDay;
                        for (DateTime d = start; d <= end; d = d.AddDays(1))
                            if (d.Year == month.Year && d.Month == month.Month)
                                eventDays.Add(d.Day);
                    }
                }
            }

            DateTime today = DateTime.Today;
            DateTime first = firstDay;
            DateTime prevLast = first.AddDays(-1);
            int daysInMonth = DateTime.DaysInMonth(month.Year, month.Month);

            // T2=1, T3=2, ..., CN=7
            int firstDayIdx = ((int)first.DayOfWeek + 6) % 7;

            var sb = new StringBuilder();
            // Padding tu thang truoc
            for (int i = firstDayIdx - 1; i >= 0; i--)
                sb.Append($"<div class=\"mc-day other\">{prevLast.Day - i}</div>");

            // Cac ngay trong thang
            for (int d = 1; d <= daysInMonth; d++)
            {
                bool hasEvent = eventDays.Contains(d);
                bool isToday = (today.Year == month.Year && today.Month == month.Month && today.Day == d);
                string css = "mc-day"
                    + (isToday ? " today" : "")
                    + (hasEvent ? " has-event" : "");
                sb.Append($"<div class=\"{css}\">{d}</div>");
            }

            // Padding sang thang sau cho du 6 hang
            int total = firstDayIdx + daysInMonth;
            int rows = (int)Math.Ceiling(total / 7.0);
            int padEnd = rows * 7 - total;
            for (int i = 1; i <= padEnd; i++)
                sb.Append($"<div class=\"mc-day other\">{i}</div>");

            miniCalDays.InnerHtml = sb.ToString();
        }

        // ════════════════════════════════════════════════════════════
        // REGISTER BUTTON (từ trang chủ)
        // ════════════════════════════════════════════════════════════

        protected void btnRegister_Command(object sender, CommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int eventId)) return;
            try
            {
                // Check da diem danh - khong cho huy
                if (HasAttended(eventId, CurrentUserId))
                {
                    ShowToast("Ban da tham gia su kien nay, khong the huy.");
                    return;
                }

                string currentStatus = GetMyRegistrationStatus(eventId);

                // Neu dang DK roi va huy -> kiem tra ChoPhepHuy cua su kien
                if (currentStatus == "approved" || currentStatus == "pending")
                {
                    if (!IsCancelAllowed(eventId))
                    {
                        ShowToast("Su kien nay khong cho phep huy dang ky.");
                        return;
                    }
                    CancelRegistration(eventId, CurrentUserId);
                    ShowToast("Da huy dang ky.");
                }
                else
                {
                    // Dang ky moi -> check het han DK
                    if (IsRegistrationExpired(eventId))
                    {
                        ShowToast("Su kien da het han dang ky.");
                        return;
                    }
                    RegisterEvent(eventId, CurrentUserId);
                    ShowToast("Da dang ky thanh cong!");
                }
                BindHomeEvents();
                BindRegisteredEvents();
                BindMyEvents();
                LoadUserStats();
                RenderMiniCalendar();
            }
            catch (Exception ex)
            {
                ShowToast("Loi: " + ex.Message);
            }
        }

        private bool IsRegistrationExpired(int eventId)
        {
            const string sql = @"SELECT HanDangKy FROM dbo.SuKien WHERE SuKienID = @id;";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = eventId;
                conn.Open();
                var v = cmd.ExecuteScalar();
                if (v == null || v == DBNull.Value) return false;
                return ((DateTime)v).Date < DateTime.Today;
            }
        }

        /// <summary>Check su kien co cho phep huy dang ky khong (cot ChoPhepHuy)</summary>
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
                return cmd.ExecuteScalar()?.ToString();
            }
        }

        private void CancelRegistration(int suKienID, int userID)
        {
            const string sql = @"
                UPDATE dbo.DangKy
                   SET TrangThai = 'cancelled', NgayCapNhat = GETDATE()
                 WHERE UserID = @u AND SuKienID = @s
                   AND TrangThai IN ('approved','pending');";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@u", SqlDbType.Int).Value = userID;
                cmd.Parameters.Add("@s", SqlDbType.Int).Value = suKienID;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>Insert DangKy hoac update trang thai neu da huy truoc do</summary>
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

        // ════════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════════

        /// <summary>Build danh sach event chung cho repeater</summary>
        private List<EventItem> QueryEventList(string sql)
        {
            var list = new List<EventItem>();
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@uid", SqlDbType.Int).Value = CurrentUserId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    DateTime today = DateTime.Today;
                    while (rd.Read())
                    {
                        int sucChua = (int)rd["SucChua"];
                        int soDuyet = HasColumn(rd, "SoDuyet")
                                      ? (int)rd["SoDuyet"]
                                      : (int)rd["SoDangKy"];
                        int pct = sucChua > 0 ? (int)Math.Round(soDuyet * 100.0 / sucChua) : 0;
                        string trangThai = rd["TrangThai"].ToString();

                        // Het han DK: HanDangKy < today (chi check neu co cot HanDangKy)
                        bool isExpired = false;
                        if (HasColumn(rd, "HanDangKy"))
                        {
                            DateTime? hanDK = rd["HanDangKy"] as DateTime?;
                            if (hanDK.HasValue && hanDK.Value.Date < today)
                                isExpired = true;
                        }

                        // Co cho phep huy DK khong?
                        bool canCancel = !HasColumn(rd, "ChoPhepHuy") || (bool)rd["ChoPhepHuy"];

                        list.Add(new EventItem
                        {
                            Id = (int)rd["SuKienID"],
                            Name = rd["TenSuKien"].ToString(),
                            Tag = (rd["LoaiSuKien"] as string ?? "").ToUpper(),
                            Type = LoaiToType(rd["LoaiSuKien"].ToString()),
                            Emoji = "",
                            AnhBia = rd["AnhBia"] as string ?? "",
                            Date = FormatDate((DateTime)rd["NgayBatDau"], rd["NgayKetThuc"] as DateTime?),
                            Location = rd["DiaDiem"].ToString(),
                            Slots = sucChua,
                            Taken = soDuyet,
                            IsMine = (int)rd["IsMine"] == 1,
                            IsFull = soDuyet >= sucChua,
                            IsExpired = isExpired,
                            CanCancel = canCancel,
                            StatusCss = StatusToCss(trangThai),
                            StatusLabel = StatusToLabel(trangThai),
                            FillCss = pct >= 100 ? "dang" : (pct >= 80 ? "warn" : ""),
                            FillPct = Math.Min(pct, 100)
                        });
                    }
                }
            }
            return list;
        }

        private static bool HasColumn(System.Data.IDataReader rd, string name)
        {
            for (int i = 0; i < rd.FieldCount; i++)
                if (rd.GetName(i).Equals(name, StringComparison.OrdinalIgnoreCase)) return true;
            return false;
        }

        private static string StatusToCss(string s)
        {
            switch (s)
            {
                case "open": return "s-open";
                case "closed": return "s-full";
                case "ongoing": return "s-ongoing";
                case "ended": return "s-ended";
                default: return "s-open";
            }
        }
        private static string StatusToLabel(string s)
        {
            switch (s)
            {
                case "open": return "Dang mo";
                case "closed": return "Da dong";
                case "ongoing": return "Dang dien ra";
                case "ended": return "Da ket thuc";
                default: return "Nhap";
            }
        }
        private static string LoaiToType(string loai)
        {
            switch (loai)
            {
                case "Team Building": return "tb";
                case "Workshop": return "workshop";
                case "Dao tao": return "training";
                case "Hoi thao": return "seminar";
                default: return "other";
            }
        }

        private string FormatDate(DateTime bd, DateTime? kt)
        {
            if (!kt.HasValue || kt.Value.Date == bd.Date) return bd.ToString("dd/MM/yyyy");
            if (bd.Month == kt.Value.Month && bd.Year == kt.Value.Year)
                return bd.ToString("dd") + "-" + kt.Value.ToString("dd/MM/yyyy");
            return bd.ToString("dd/MM") + " - " + kt.Value.ToString("dd/MM/yyyy");
        }

        private string GetInitials(string ho, string ten)
        {
            string a = !string.IsNullOrEmpty(ho) ? ho.Substring(0, 1) : "";
            string b = !string.IsNullOrEmpty(ten) ? ten.Substring(0, 1) : "";
            return (a + b).ToUpper();
        }

        private void ShowToast(string msg)
        {
            string safe = msg.Replace("'", "\\'");
            string js = $"if(window.showToast)showToast('{safe}');";
            ClientScript.RegisterStartupScript(GetType(), "toast", js, true);
        }

        // ════════════════════════════════════════════════════════════
        // MODELS
        // ════════════════════════════════════════════════════════════

        public class EventItem
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public string Type { get; set; }
            public string Tag { get; set; }
            public string Emoji { get; set; }
            public string AnhBia { get; set; }
            public string Date { get; set; }
            public string Location { get; set; }
            public int Slots { get; set; }
            public int Taken { get; set; }
            public bool IsMine { get; set; }
            public bool IsFull { get; set; }
            public bool IsExpired { get; set; }
            public bool CanCancel { get; set; }
            public string StatusCss { get; set; }
            public string StatusLabel { get; set; }
            public string FillCss { get; set; }
            public int FillPct { get; set; }
        }

        public class RegisteredEventItem
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public string Tag { get; set; }
            public string AnhBia { get; set; }
            public string Date { get; set; }
            public string Location { get; set; }
            public string StatusCss { get; set; }
            public string StatusLabel { get; set; }
            public string DkStatusLabel { get; set; }
            public bool CanCancel { get; set; }
        }

        public class MyEventItem
        {
            public int Id { get; set; }
            public string Emoji { get; set; }
            public string Name { get; set; }
            public string DateShort { get; set; }
            public string Location { get; set; }
            public string StatusCss { get; set; }
            public string StatusLabel { get; set; }
        }
    }
}