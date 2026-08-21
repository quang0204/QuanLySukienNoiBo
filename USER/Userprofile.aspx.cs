using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace QuanLySuKien
{
    public partial class Userprofile : System.Web.UI.Page
    {
        private static readonly string ConnStr =
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

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

            if (!IsPostBack)
            {
                LoadUserInfo();
                LoadUserStats();
                BindHistory();
                BindUpcoming();
            }
        }

        // ════════════════════════════════════════════════════════════
        // LOAD USER INFO
        // ════════════════════════════════════════════════════════════

        private void LoadUserInfo()
        {
            const string sql = @"
                SELECT Ho, Ten, Email, SoDienThoai, PhongBan, ChucVu,
                       VanPhong, CapBac, NamVaoLam
                FROM dbo.Users WHERE UserID = @id;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = CurrentUserId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (!rd.Read()) return;

                    string ho = rd["Ho"].ToString();
                    string ten = rd["Ten"].ToString();
                    string fullName = (ho + " " + ten).Trim();
                    string email = rd["Email"].ToString();
                    string phone = rd["SoDienThoai"] as string ?? "";
                    string pb = rd["PhongBan"] as string ?? "";
                    string cv = rd["ChucVu"] as string ?? "";
                    string vanPhong = rd["VanPhong"] as string ?? "";
                    string capBac = rd["CapBac"] as string ?? "";
                    int? namVaoLam = rd["NamVaoLam"] as short?;

                    // Avatar (initials)
                    lblAvatarInitials.Text = GetInitials(ho, ten);
                    lblFullName.Text = fullName;
                    lblJobTitle.Text = string.IsNullOrEmpty(cv) ? "-" : cv;

                    // Tags
                    if (lblTagDept != null) lblTagDept.Text = string.IsNullOrEmpty(pb) ? "-" : pb;
                    if (lblTagLevel != null) lblTagLevel.Text = string.IsNullOrEmpty(capBac) ? "-" : capBac;
                    if (lblTagOffice != null) lblTagOffice.Text = string.IsNullOrEmpty(vanPhong) ? "-" : vanPhong;
                    if (lblTagYear != null) lblTagYear.Text = namVaoLam.HasValue
                                                                  ? "Tu " + namVaoLam.Value
                                                                  : "-";

                    // Form fields
                    txtFullName.Text = fullName;
                    txtEmail.Text = email;
                    txtPhone.Text = phone;
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // LOAD USER STATS
        // ════════════════════════════════════════════════════════════

        private void LoadUserStats()
        {
            const string sql = @"
                SELECT
                    -- Tong su kien dang ky (approved + pending, khong tinh cancelled)
                    (SELECT COUNT(*) FROM dbo.DangKy
                       WHERE UserID = @id AND TrangThai IN ('approved','pending')) AS Registered,

                    -- Tong da tham gia (diem danh)
                    (SELECT COUNT(*) FROM dbo.DangKy
                       WHERE UserID = @id AND DaDiemDanh = 1) AS Attended,

                    -- Diem TB feedback
                    (SELECT AVG(CAST(Diem AS DECIMAL(3,1))) FROM dbo.Feedback
                       WHERE UserID = @id) AS AvgRating,

                    -- Nam vao lam
                    (SELECT NamVaoLam FROM dbo.Users WHERE UserID = @id) AS NamVaoLam;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = CurrentUserId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (!rd.Read()) return;

                    int reg = rd["Registered"] == DBNull.Value ? 0 : (int)rd["Registered"];
                    int att = rd["Attended"] == DBNull.Value ? 0 : (int)rd["Attended"];
                    decimal rating = rd["AvgRating"] == DBNull.Value ? 0m : (decimal)rd["AvgRating"];
                    short? namVL = rd["NamVaoLam"] as short?;

                    int rate = reg > 0 ? (int)Math.Round(att * 100.0 / reg) : 0;
                    int years = namVL.HasValue ? DateTime.Today.Year - namVL.Value : 0;

                    lblStatTotalAtt.Text = att.ToString();
                    lblStatAttRate.Text = rate + "%";
                    lblStatRating.Text = rating == 0 ? "-" : rating.ToString("0.0");
                    lblStatYears.Text = years.ToString();
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // LỊCH SỬ SỰ KIỆN
        // ════════════════════════════════════════════════════════════

        private void BindHistory()
        {
            const string sql = @"
                SELECT TOP 20
                    s.SuKienID, s.TenSuKien, s.LoaiSuKien,
                    s.NgayBatDau, s.NgayKetThuc, s.GioKetThuc,
                    s.DiaDiem, s.BatFeedback,
                    dk.TrangThai AS DangKyStatus, dk.DaDiemDanh,
                    CASE WHEN EXISTS(SELECT 1 FROM dbo.Feedback
                                     WHERE UserID = @id AND SuKienID = s.SuKienID)
                         THEN 1 ELSE 0 END AS HasFb
                FROM dbo.DangKy dk
                INNER JOIN dbo.SuKien s ON dk.SuKienID = s.SuKienID
                WHERE dk.UserID = @id
                ORDER BY s.NgayBatDau DESC;";

            string[] monthLabels = { "TH1", "TH2", "TH3", "TH4", "TH5", "TH6", "TH7", "TH8", "TH9", "TH10", "TH11", "TH12" };
            var list = new List<HistoryItem>();

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = CurrentUserId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    DateTime today = DateTime.Today;
                    TimeSpan nowTime = DateTime.Now.TimeOfDay;
                    while (rd.Read())
                    {
                        DateTime bd = (DateTime)rd["NgayBatDau"];
                        DateTime? kt = rd["NgayKetThuc"] as DateTime?;
                        TimeSpan? gkt = rd["GioKetThuc"] as TimeSpan?;
                        string dkStatus = rd["DangKyStatus"].ToString();
                        bool daDiemDanh = (bool)rd["DaDiemDanh"];
                        bool hasFb = (int)rd["HasFb"] == 1;

                        // Check su kien da ket thuc chua
                        DateTime effKt = kt ?? bd;
                        bool eventEnded = false;
                        if (effKt < today)
                            eventEnded = true;
                        else if (effKt == today && gkt.HasValue && nowTime > gkt.Value)
                            eventEnded = true;

                        string badgeCss, statusLabel, dateCss = "";

                        if (dkStatus == "cancelled" || dkStatus == "rejected")
                        {
                            badgeCss = "badge-cancelled";
                            statusLabel = dkStatus == "cancelled" ? "DA HUY" : "BI TU CHOI";
                            dateCss = "cancelled";
                        }
                        else if (daDiemDanh)
                        {
                            badgeCss = "badge-attended";
                            statusLabel = "DA THAM GIA";
                        }
                        else if (dkStatus == "pending")
                        {
                            badgeCss = "badge-upcoming";
                            statusLabel = "CHO DUYET";
                        }
                        else if (bd >= today)
                        {
                            badgeCss = "badge-upcoming";
                            statusLabel = "SAP TOI";
                        }
                        else
                        {
                            badgeCss = "badge-cancelled";
                            statusLabel = "VANG MAT";
                        }

                        // Co the danh gia khi: da tham gia + su kien da ket thuc + admin bat feedback
                        bool batFeedback = rd["BatFeedback"] != DBNull.Value && (bool)rd["BatFeedback"];
                        bool canFeedback = daDiemDanh && eventEnded && batFeedback;

                        list.Add(new HistoryItem
                        {
                            Id = (int)rd["SuKienID"],
                            Day = bd.Day.ToString("00"),
                            MonthLabel = monthLabels[bd.Month - 1],
                            DateCss = dateCss,
                            Name = rd["TenSuKien"].ToString(),
                            Location = rd["DiaDiem"].ToString(),
                            Category = rd["LoaiSuKien"].ToString(),
                            BadgeCss = badgeCss,
                            StatusLabel = statusLabel,
                            CanFeedback = canFeedback,
                            HasFeedback = hasFb
                        });
                    }
                }
            }
            rptHistory.DataSource = list;
            rptHistory.DataBind();
        }

        // ════════════════════════════════════════════════════════════
        // SỰ KIỆN SẮP TỚI (sidebar)
        // ════════════════════════════════════════════════════════════

        private void BindUpcoming()
        {
            const string sql = @"
                SELECT TOP 5
                    s.SuKienID, s.TenSuKien, s.NgayBatDau, s.GioBatDau, s.DiaDiem
                FROM dbo.DangKy dk
                INNER JOIN dbo.SuKien s ON dk.SuKienID = s.SuKienID
                WHERE dk.UserID = @id
                  AND dk.TrangThai IN ('approved','pending')
                  AND s.NgayBatDau >= CAST(GETDATE() AS DATE)
                ORDER BY s.NgayBatDau ASC;";

            string[] monthLabels = { "TH1", "TH2", "TH3", "TH4", "TH5", "TH6", "TH7", "TH8", "TH9", "TH10", "TH11", "TH12" };
            var list = new List<UpcomingItem>();

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = CurrentUserId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        DateTime bd = (DateTime)rd["NgayBatDau"];
                        TimeSpan gbd = (TimeSpan)rd["GioBatDau"];

                        list.Add(new UpcomingItem
                        {
                            Id = (int)rd["SuKienID"],
                            Day = bd.Day.ToString("00"),
                            MonthLabel = monthLabels[bd.Month - 1],
                            Name = rd["TenSuKien"].ToString(),
                            Sub = gbd.ToString(@"hh\:mm") + " - " + rd["DiaDiem"].ToString()
                        });
                    }
                }
            }
            rptUpcoming.DataSource = list;
            rptUpcoming.DataBind();
        }

        // ════════════════════════════════════════════════════════════
        // BUTTON HANDLERS - THÔNG TIN CÁ NHÂN
        // ════════════════════════════════════════════════════════════

        protected void btnEditInfo_Click(object sender, EventArgs e)
        {
            txtFullName.ReadOnly = false;
            txtEmail.ReadOnly = false;
            txtPhone.ReadOnly = false;
            btnSaveInfo.Visible = true;
            btnEditInfo.Visible = false;
        }

        protected void btnSaveInfo_Click(object sender, EventArgs e)
        {
            try
            {
                string fullName = txtFullName.Text.Trim();
                string email = txtEmail.Text.Trim();
                string phone = txtPhone.Text.Trim();

                // Validate
                if (string.IsNullOrEmpty(fullName)) { ShowToast("Vui long nhap ho ten"); return; }
                if (string.IsNullOrEmpty(email)) { ShowToast("Vui long nhap email"); return; }
                if (!email.Contains("@")) { ShowToast("Email khong hop le"); return; }

                // Tach Ho + Ten (lay tu cuoi cung)
                var parts = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                string ho, ten;
                if (parts.Length == 1) { ho = ""; ten = parts[0]; }
                else
                {
                    ten = parts[parts.Length - 1];
                    ho = string.Join(" ", parts, 0, parts.Length - 1);
                }

                // Check email trung (khac user hien tai)
                if (IsEmailTaken(email, CurrentUserId))
                {
                    ShowToast("Email da duoc su dung boi user khac");
                    return;
                }

                UpdateUserInfo(CurrentUserId, ho, ten, email, phone);

                txtFullName.ReadOnly = true;
                txtEmail.ReadOnly = true;
                txtPhone.ReadOnly = true;
                btnSaveInfo.Visible = false;
                btnEditInfo.Visible = true;

                lblFullName.Text = fullName;
                lblAvatarInitials.Text = GetInitials(ho, ten);

                ShowToast("Da luu thong tin ca nhan!");
            }
            catch (Exception ex)
            {
                ShowToast("Loi: " + ex.Message);
            }
        }

        private bool IsEmailTaken(string email, int excludeUserId)
        {
            const string sql = "SELECT COUNT(*) FROM dbo.Users WHERE Email = @e AND UserID <> @id;";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@e", SqlDbType.NVarChar, 150).Value = email;
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = excludeUserId;
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private void UpdateUserInfo(int userId, string ho, string ten, string email, string phone)
        {
            const string sql = @"
                UPDATE dbo.Users
                   SET Ho = @ho, Ten = @ten, Email = @email, SoDienThoai = @phone,
                       NgayCapNhat = GETDATE()
                 WHERE UserID = @id;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@ho", SqlDbType.NVarChar, 50).Value = ho;
                cmd.Parameters.Add("@ten", SqlDbType.NVarChar, 50).Value = ten;
                cmd.Parameters.Add("@email", SqlDbType.NVarChar, 150).Value = email;
                cmd.Parameters.Add("@phone", SqlDbType.NVarChar, 20).Value = (object)phone ?? DBNull.Value;
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ════════════════════════════════════════════════════════════
        // BUTTON HANDLERS - ĐỔI MẬT KHẨU
        // ════════════════════════════════════════════════════════════

        protected void btnChangePw_Click(object sender, EventArgs e)
        {
            try
            {
                string current = txtCurrentPw.Text;
                string newPw = txtNewPw.Text;
                string confirm = txtConfirmPw.Text;

                if (string.IsNullOrWhiteSpace(current) ||
                    string.IsNullOrWhiteSpace(newPw) ||
                    string.IsNullOrWhiteSpace(confirm))
                { ShowToast("Vui long nhap day du cac truong"); return; }

                if (newPw.Length < 6) { ShowToast("Mat khau moi phai >= 6 ky tu"); return; }
                if (newPw != confirm) { ShowToast("Mat khau xac nhan khong khop"); return; }

                // Kiem tra mat khau hien tai
                if (!CheckCurrentPassword(CurrentUserId, current))
                {
                    ShowToast("Mat khau hien tai khong dung");
                    return;
                }

                UpdatePassword(CurrentUserId, newPw);

                txtCurrentPw.Text = txtNewPw.Text = txtConfirmPw.Text = "";
                ShowToast("Da doi mat khau thanh cong!");
            }
            catch (Exception ex)
            {
                ShowToast("Loi: " + ex.Message);
            }
        }

        private bool CheckCurrentPassword(int userId, string password)
        {
            const string sql = "SELECT COUNT(*) FROM dbo.Users WHERE UserID = @id AND MatKhau = @p;";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@p", SqlDbType.NVarChar, 255).Value = password;
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private void UpdatePassword(int userId, string newPassword)
        {
            const string sql = @"
                UPDATE dbo.Users
                   SET MatKhau = @p, NgayCapNhat = GETDATE()
                 WHERE UserID = @id;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@p", SqlDbType.NVarChar, 255).Value = newPassword;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ════════════════════════════════════════════════════════════
        // BUTTON HANDLERS - TẠM DỪNG / XÓA TÀI KHOẢN
        // ════════════════════════════════════════════════════════════

        protected void btnDeactivate_Click(object sender, EventArgs e)
        {
            try
            {
                SetUserStatus(CurrentUserId, "inactive");
                Session.Clear();
                Session.Abandon();
                Response.Redirect("~/Login_Regis.aspx");
            }
            catch (Exception ex)
            {
                ShowToast("Loi: " + ex.Message);
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login_Regis.aspx");
        }

        protected void btnDeleteAccount_Click(object sender, EventArgs e)
        {
            // Soft-delete: chuyen TrangThai sang 'inactive'
            // (Khong xoa cung vi co rang buoc FK voi DangKy, Feedback, ThongBao, SuKien)
            try
            {
                SetUserStatus(CurrentUserId, "inactive");
                Session.Clear();
                Session.Abandon();
                Response.Redirect("~/Login_Regis.aspx");
            }
            catch (Exception ex)
            {
                ShowToast("Loi: " + ex.Message);
            }
        }

        private void SetUserStatus(int userId, string status)
        {
            const string sql = @"
                UPDATE dbo.Users
                   SET TrangThai = @s, NgayCapNhat = GETDATE()
                 WHERE UserID = @id;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@s", SqlDbType.NVarChar, 20).Value = status;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ════════════════════════════════════════════════════════════
        // FEEDBACK (đánh giá sự kiện - modal trong tab History)
        // ════════════════════════════════════════════════════════════

        protected void rptHistory_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "OpenFeedback") return;
            if (!int.TryParse(e.CommandArgument?.ToString(), out int eventId)) return;

            OpenFeedbackModal(eventId);
        }

        private void OpenFeedbackModal(int eventId)
        {
            // Load thong tin su kien
            const string sql = @"
                SELECT s.TenSuKien, s.NgayBatDau,
                       fb.Diem, fb.NoiDung
                FROM dbo.SuKien s
                LEFT JOIN dbo.Feedback fb
                  ON fb.SuKienID = s.SuKienID AND fb.UserID = @uid
                WHERE s.SuKienID = @sid;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@uid", SqlDbType.Int).Value = CurrentUserId;
                cmd.Parameters.Add("@sid", SqlDbType.Int).Value = eventId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (!rd.Read()) return;

                    lblFbEventName.Text = rd["TenSuKien"].ToString();
                    DateTime bd = (DateTime)rd["NgayBatDau"];
                    lblFbEventDate.Text = bd.ToString("dd/MM/yyyy");

                    // Neu da co feedback -> prefill
                    if (rd["Diem"] != DBNull.Value)
                    {
                        hfFbScore.Value = ((byte)rd["Diem"]).ToString();
                        txtFbContent.Text = rd["NoiDung"] as string ?? "";
                    }
                    else
                    {
                        hfFbScore.Value = "0";
                        txtFbContent.Text = "";
                    }
                }
            }

            hfFbEventId.Value = eventId.ToString();
            pnlFbModal.Visible = true;
        }

        protected void btnSubmitFeedback_Click(object sender, EventArgs e)
        {
            try
            {
                if (!int.TryParse(hfFbEventId.Value, out int eventId) || eventId <= 0)
                {
                    ShowToast("Loi: khong xac dinh duoc su kien.");
                    return;
                }

                if (!int.TryParse(hfFbScore.Value, out int diem) || diem < 1 || diem > 5)
                {
                    ShowToast("Vui long chon so sao (1-5).");
                    return;
                }

                string noiDung = txtFbContent.Text?.Trim() ?? "";

                // Validate: phai tham gia + su kien da ket thuc
                if (!CanUserFeedback(eventId, CurrentUserId))
                {
                    ShowToast("Ban khong the danh gia su kien nay.");
                    return;
                }

                SaveFeedback(eventId, CurrentUserId, diem, noiDung);
                ShowToast("Cam on ban da danh gia!");

                // Reset modal va reload history
                pnlFbModal.Visible = false;
                hfFbScore.Value = "0";
                hfFbEventId.Value = "0";
                txtFbContent.Text = "";

                BindHistory();
                LoadUserStats();
            }
            catch (Exception ex)
            {
                ShowToast("Loi: " + ex.Message);
            }
        }

        private bool CanUserFeedback(int eventId, int userId)
        {
            const string sql = @"
                SELECT
                    dk.DaDiemDanh,
                    s.NgayKetThuc, s.NgayBatDau, s.GioKetThuc
                FROM dbo.DangKy dk
                INNER JOIN dbo.SuKien s ON dk.SuKienID = s.SuKienID
                WHERE dk.UserID = @u AND dk.SuKienID = @s;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@u", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@s", SqlDbType.Int).Value = eventId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (!rd.Read()) return false;
                    bool daDD = (bool)rd["DaDiemDanh"];
                    if (!daDD) return false;

                    DateTime bd = (DateTime)rd["NgayBatDau"];
                    DateTime? kt = rd["NgayKetThuc"] as DateTime?;
                    TimeSpan? gkt = rd["GioKetThuc"] as TimeSpan?;
                    DateTime effKt = kt ?? bd;

                    DateTime today = DateTime.Today;
                    TimeSpan nowTime = DateTime.Now.TimeOfDay;
                    if (effKt < today) return true;
                    if (effKt == today && gkt.HasValue && nowTime > gkt.Value) return true;
                    return false;
                }
            }
        }

        private void SaveFeedback(int eventId, int userId, int diem, string noiDung)
        {
            const string sql = @"
                IF EXISTS (SELECT 1 FROM dbo.Feedback WHERE UserID=@u AND SuKienID=@s)
                BEGIN
                    UPDATE dbo.Feedback
                       SET Diem = @d, NoiDung = @c, NgayGui = GETDATE()
                     WHERE UserID = @u AND SuKienID = @s;
                END
                ELSE
                BEGIN
                    INSERT INTO dbo.Feedback (UserID, SuKienID, Diem, NoiDung)
                    VALUES (@u, @s, @d, @c);
                END";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@u", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@s", SqlDbType.Int).Value = eventId;
                cmd.Parameters.Add("@d", SqlDbType.TinyInt).Value = (byte)diem;
                cmd.Parameters.Add("@c", SqlDbType.NVarChar).Value =
                    string.IsNullOrEmpty(noiDung) ? (object)DBNull.Value : noiDung;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ════════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════════

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
            ScriptManager.RegisterStartupScript(this, GetType(), "toast", js, true);
        }

        // ════════════════════════════════════════════════════════════
        // MODELS
        // ════════════════════════════════════════════════════════════

        public class HistoryItem
        {
            public int Id { get; set; }
            public string Day { get; set; }
            public string MonthLabel { get; set; }
            public string DateCss { get; set; }
            public string Name { get; set; }
            public string Location { get; set; }
            public string Category { get; set; }
            public string BadgeCss { get; set; }
            public string StatusLabel { get; set; }
            public bool CanFeedback { get; set; }
            public bool HasFeedback { get; set; }
        }

        public class UpcomingItem
        {
            public int Id { get; set; }
            public string Day { get; set; }
            public string MonthLabel { get; set; }
            public string Name { get; set; }
            public string Sub { get; set; }
        }
    }
}