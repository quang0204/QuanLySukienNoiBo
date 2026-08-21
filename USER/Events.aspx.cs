using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;

namespace QuanLySuKien
{
    public partial class Events : System.Web.UI.Page
    {
        private static readonly string ConnStr =
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        private int CurrentUserId =>
            Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int uid) ? uid : 0;

        // Filter dang chon
        private string CurrentFilter
        {
            get => ViewState["Filter"]?.ToString() ?? "all";
            set => ViewState["Filter"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login_Regis.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadStats();
                UpdateFilterChips();
                BindEvents();

            }
        }

        // ════════════════════════════════════════════════════════════
        // STATS HEADER
        // ════════════════════════════════════════════════════════════

        private void LoadStats()
        {
            const string sql = @"
                SELECT
                    -- Tong su kien dang mo DK
                    (SELECT COUNT(*) FROM dbo.SuKien s
                     WHERE dbo.fn_TinhTrangThai(s.TrangThai, s.NgayBatDau, s.NgayKetThuc,
                                s.HanDangKy, s.SucChua,
                                ISNULL((SELECT COUNT(*) FROM dbo.DangKy
                                          WHERE SuKienID=s.SuKienID AND TrangThai='approved'),0), s.GioBatDau, s.GioKetThuc) = 'open') AS OpenCnt,

                    -- Toi da dang ky
                    (SELECT COUNT(*) FROM dbo.DangKy
                     WHERE UserID=@uid AND TrangThai IN ('approved','pending')) AS MyReg,

                    -- Toi da tham gia
                    (SELECT COUNT(*) FROM dbo.DangKy
                     WHERE UserID=@uid AND DaDiemDanh=1) AS MyAtt;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@uid", SqlDbType.Int).Value = CurrentUserId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        lblStatOpen.Text = rd["OpenCnt"].ToString();
                        lblStatMyReg.Text = rd["MyReg"].ToString();
                        lblStatMyAtt.Text = rd["MyAtt"].ToString();
                    }
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // FILTER CHIPS
        // ════════════════════════════════════════════════════════════

        protected void FilterChip_Command(object sender, CommandEventArgs e)
        {
            CurrentFilter = e.CommandArgument.ToString();
            UpdateFilterChips();
            BindEvents();
        }

        private void UpdateFilterChips()
        {
            string f = CurrentFilter;
            btnFilterAll.CssClass = f == "all" ? "filter-chip active" : "filter-chip";
            btnFilterTB.CssClass = f == "tb" ? "filter-chip active" : "filter-chip";
            btnFilterWorkshop.CssClass = f == "workshop" ? "filter-chip active" : "filter-chip";
            btnFilterTraining.CssClass = f == "training" ? "filter-chip active" : "filter-chip";
            btnFilterSeminar.CssClass = f == "seminar" ? "filter-chip active" : "filter-chip";
            btnFilterMine.CssClass = f == "mine" ? "filter-chip active" : "filter-chip";
            if (btnFilterEnded != null)
                btnFilterEnded.CssClass = f == "ended" ? "filter-chip active" : "filter-chip";
        }

        // ════════════════════════════════════════════════════════════
        // SEARCH
        // ════════════════════════════════════════════════════════════

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindEvents();
        }

        // ════════════════════════════════════════════════════════════
        // REGISTER
        // ════════════════════════════════════════════════════════════

        protected void btnRegister_Command(object sender, CommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int eventId)) return;
            try
            {
                if (HasAttended(eventId, CurrentUserId))
                {
                    ShowToast("Ban da tham gia su kien nay, khong the huy.");
                    return;
                }

                string currentStatus = GetMyRegistrationStatus(eventId);
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
                    // Dang ky moi -> check het han
                    if (IsRegistrationExpired(eventId))
                    {
                        ShowToast("Su kien da het han dang ky.");
                        return;
                    }
                    RegisterEvent(eventId, CurrentUserId);
                    ShowToast("Da dang ky thanh cong!");
                }
                LoadStats();
                BindEvents();

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
                var r = cmd.ExecuteScalar();
                return r?.ToString();
            }
        }

        protected void btnCancel_Command(object sender, CommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int eventId)) return;
            try
            {
                CancelRegistration(eventId, CurrentUserId);
                ShowToast("Da huy dang ky.");
                LoadStats();
                BindEvents();

            }
            catch (Exception ex)
            {
                ShowToast("Loi: " + ex.Message);
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
        // BIND EVENTS (main grid)
        // ════════════════════════════════════════════════════════════

        private void BindEvents()
        {
            string filter = CurrentFilter;
            string keyword = txtSearch.Text?.Trim() ?? "";

            var sb = new StringBuilder(@"
                SELECT
                    s.SuKienID, s.TenSuKien, s.LoaiSuKien, s.NgayBatDau, s.NgayKetThuc,
                    s.DiaDiem, s.SucChua, s.AnhBia, s.HanDangKy, s.ChoPhepHuy,
                    dbo.fn_TinhTrangThai(s.TrangThai, s.NgayBatDau, s.NgayKetThuc,
                        s.HanDangKy, s.SucChua, ISNULL(d.SoDuyet,0), s.GioBatDau, s.GioKetThuc) AS TrangThai,
                    ISNULL(d.SoDangKy, 0) AS SoDangKy,
                    ISNULL(d.SoDuyet, 0)  AS SoDuyet,
                    CASE WHEN EXISTS(SELECT 1 FROM dbo.DangKy
                          WHERE UserID = @uid AND SuKienID = s.SuKienID
                            AND TrangThai IN ('approved','pending'))
                         THEN 1 ELSE 0 END AS IsMine,
                    CASE WHEN EXISTS(SELECT 1 FROM dbo.DangKy
                          WHERE UserID = @uid AND SuKienID = s.SuKienID
                            AND DaDiemDanh = 1)
                         THEN 1 ELSE 0 END AS IsAttended
                FROM dbo.SuKien s
                LEFT JOIN (
                    SELECT SuKienID,
                           COUNT(*) AS SoDangKy,
                           SUM(CASE WHEN TrangThai = 'approved' THEN 1 ELSE 0 END) AS SoDuyet
                    FROM dbo.DangKy WHERE TrangThai IN ('approved','pending')
                    GROUP BY SuKienID
                ) d ON s.SuKienID = d.SuKienID
                WHERE s.TrangThai <> 'draft' ");

            // Filter loai
            if (filter == "tb") sb.Append(" AND s.LoaiSuKien = 'Team Building' ");
            else if (filter == "workshop") sb.Append(" AND s.LoaiSuKien = 'Workshop' ");
            else if (filter == "training") sb.Append(" AND s.LoaiSuKien = 'Dao tao' ");
            else if (filter == "seminar") sb.Append(" AND s.LoaiSuKien = 'Hoi thao' ");
            else if (filter == "mine")
            {
                sb.Append(@" AND EXISTS(SELECT 1 FROM dbo.DangKy
                                    WHERE UserID = @uid AND SuKienID = s.SuKienID
                                      AND TrangThai IN ('approved','pending')) ");
            }
            else if (filter == "ended")
            {
                // Chi hien thi su kien da ket thuc
                sb.Append(@" AND (s.NgayKetThuc < CAST(GETDATE() AS DATE)
                              OR (s.NgayKetThuc IS NULL AND s.NgayBatDau < CAST(GETDATE() AS DATE))) ");
            }
            else if (filter == "all")
            {
                // 'all' mac dinh chi hien thi chua ket thuc
                sb.Append(@" AND (s.NgayKetThuc >= CAST(GETDATE() AS DATE)
                              OR (s.NgayKetThuc IS NULL AND s.NgayBatDau >= CAST(GETDATE() AS DATE))) ");
            }
            // Cac filter loai (tb/workshop/training/seminar) khong han che ngay -> co the thay ca ket thuc neu cung loai

            // Search
            if (!string.IsNullOrEmpty(keyword))
                sb.Append(" AND (s.TenSuKien LIKE @kw OR s.DiaDiem LIKE @kw) ");

            sb.Append(" ORDER BY s.NgayBatDau DESC;");

            var list = new List<EventItem>();
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sb.ToString(), conn))
            {
                cmd.Parameters.Add("@uid", SqlDbType.Int).Value = CurrentUserId;
                if (!string.IsNullOrEmpty(keyword))
                    cmd.Parameters.Add("@kw", SqlDbType.NVarChar, 200).Value = "%" + keyword + "%";

                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        int sucChua = (int)rd["SucChua"];
                        // Dem chi approved
                        int soDuyet = (int)rd["SoDuyet"];
                        int pct = sucChua > 0 ? (int)Math.Round(soDuyet * 100.0 / sucChua) : 0;
                        string trangThai = rd["TrangThai"].ToString();
                        bool full = soDuyet >= sucChua;

                        // Het han DK
                        bool isExpired = false;
                        DateTime? hanDK = rd["HanDangKy"] as DateTime?;
                        if (hanDK.HasValue && hanDK.Value.Date < DateTime.Today)
                            isExpired = true;

                        // Co cho phep huy?
                        bool canCancel = (bool)rd["ChoPhepHuy"];

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
                            IsAttended = (int)rd["IsAttended"] == 1,
                            IsFull = full,
                            IsExpired = isExpired,
                            CanCancel = canCancel,
                            StatusCss = StatusToCss(trangThai, full),
                            StatusLabel = StatusToLabel(trangThai, full),
                            FillCss = pct >= 100 ? "dang" : (pct >= 80 ? "warn" : ""),
                            FillPct = Math.Min(pct, 100)
                        });
                    }
                }
            }

            rptEvents.DataSource = list;
            rptEvents.DataBind();
            lblEventsCount.Text = $"{list.Count} su kien";
        }

        // ════════════════════════════════════════════════════════════
        // SIDE: SỰ KIỆN CỦA TÔI
        // ════════════════════════════════════════════════════════════

        // ════════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════════

        private static string StatusToCss(string s, bool full)
        {
            // ENDED uu tien hon FULL (vi su kien da ket thuc thi khong quan tam day hay khong)
            if (s == "ended") return "s-ended";
            if (s == "ongoing") return "s-ongoing";
            if (full) return "s-full";
            switch (s)
            {
                case "open": return "s-open";
                case "closed": return "s-full";
                default: return "s-open";
            }
        }
        private static string StatusToLabel(string s, bool full)
        {
            if (s == "ended") return "Da ket thuc";
            if (s == "ongoing") return "Dang dien ra";
            if (full) return "Da day";
            switch (s)
            {
                case "open": return "Dang mo";
                case "closed": return "Da dong";
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
            public bool IsAttended { get; set; }
            public bool IsFull { get; set; }
            public bool IsExpired { get; set; }
            public bool CanCancel { get; set; }
            public string StatusCss { get; set; }
            public string StatusLabel { get; set; }
            public string FillCss { get; set; }
            public int FillPct { get; set; }
        }

    }
}