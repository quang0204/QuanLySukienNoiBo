using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Configuration;
using System.Text.RegularExpressions;

namespace QuanLySuKien
{
    public partial class Login_Regis : System.Web.UI.Page
    {
        private const string URL_ADMIN = "~/Admin/AdminDashboard.aspx";
        private const string URL_USER = "~/User/UserTrangChu.aspx";

        // Captcha: DUNG 3 chu HOA + DUNG 2 chu so + ket thuc @
        private static readonly Regex CaptchaRegex =
            new Regex(@"^(?=(?:[^A-Z]*[A-Z]){3}[^A-Z]*$)(?=(?:[^0-9]*[0-9]){2}[^0-9]*$)[A-Z0-9]{5}@$");

        private string Conn =>
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        // ════════════════════════════════
        //  DANH SACH MA NHAP (luu o DATABASE)
        // ════════════════════════════════

        /// <summary>Lay session id de track user chua login</summary>
        private string CurrentSessionId => Session.SessionID;

        /// <summary>Lay UserID (neu da login) hoac NULL</summary>
        private object CurrentUserIdOrNull
        {
            get
            {
                if (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int uid))
                    return uid;
                return DBNull.Value;
            }
        }

        /// <summary>Them ma vao DB</summary>
        private void SaveCaptchaToDb(string maCaptcha, string ketQua)
        {
            const string sql = @"
                INSERT INTO dbo.CaptchaLog (UserID, SessionID, MaCaptcha, KetQua, NgayNhap, Hidden)
                VALUES (@uid, @sid, @ma, @kq, GETDATE(), 0);";

            try
            {
                using (var cn = new SqlConnection(Conn))
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@uid", CurrentUserIdOrNull);
                    cmd.Parameters.AddWithValue("@sid", CurrentSessionId);
                    cmd.Parameters.AddWithValue("@ma", maCaptcha);
                    cmd.Parameters.AddWithValue("@kq", ketQua);
                    cn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* khong block flow login neu DB loi */ }
        }

        /// <summary>Load danh sach ma da nhap (chua bi an) tu DB</summary>
        private List<CaptchaItem> LoadCaptchaListFromDb()
        {
            var list = new List<CaptchaItem>();

            // Neu da login: load theo UserID
            // Neu chua login: load theo SessionID
            string sql = (CurrentUserIdOrNull is int)
                ? @"SELECT CaptchaLogID, MaCaptcha, KetQua, NgayNhap
                    FROM dbo.CaptchaLog
                    WHERE UserID = @uid AND Hidden = 0
                    ORDER BY NgayNhap DESC;"
                : @"SELECT CaptchaLogID, MaCaptcha, KetQua, NgayNhap
                    FROM dbo.CaptchaLog
                    WHERE SessionID = @sid AND UserID IS NULL AND Hidden = 0
                    ORDER BY NgayNhap DESC;";

            try
            {
                using (var cn = new SqlConnection(Conn))
                using (var cmd = new SqlCommand(sql, cn))
                {
                    if (CurrentUserIdOrNull is int)
                        cmd.Parameters.AddWithValue("@uid", CurrentUserIdOrNull);
                    else
                        cmd.Parameters.AddWithValue("@sid", CurrentSessionId);

                    cn.Open();
                    using (var rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            list.Add(new CaptchaItem
                            {
                                Id = (int)rd["CaptchaLogID"],
                                MaCaptcha = rd["MaCaptcha"].ToString(),
                                KetQua = rd["KetQua"].ToString(),
                                NgayNhap = ((DateTime)rd["NgayNhap"]).ToString("dd/MM HH:mm:ss")
                            });
                        }
                    }
                }
            }
            catch { /* return list rong */ }

            return list;
        }

        /// <summary>An 1 muc (soft delete - set Hidden=1)</summary>
        private void HideCaptchaInDb(int logId)
        {
            const string sql = @"UPDATE dbo.CaptchaLog SET Hidden = 1 WHERE CaptchaLogID = @id;";
            try
            {
                using (var cn = new SqlConnection(Conn))
                using (var cmd = new SqlCommand(sql, cn))
                {
                    cmd.Parameters.AddWithValue("@id", logId);
                    cn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private void BindCaptchaList()
        {
            var list = LoadCaptchaListFromDb();
            lblListCount.Text = list.Count.ToString();

            if (list.Count == 0)
            {
                rptCaptchaList.Visible = false;
                phEmptyList.Visible = true;
            }
            else
            {
                rptCaptchaList.Visible = true;
                phEmptyList.Visible = false;
                rptCaptchaList.DataSource = list;
                rptCaptchaList.DataBind();
            }
        }

        /// <summary>Click 1 muc trong danh sach -> an muc do (soft delete DB)</summary>
        protected void rptCaptchaList_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "HideItem") return;
            if (!int.TryParse(e.CommandArgument?.ToString(), out int logId)) return;

            HideCaptchaInDb(logId);
            BindCaptchaList();
            hfAuthMode.Value = "login";
        }

        /// <summary>Model item de bind Repeater</summary>
        public class CaptchaItem
        {
            public int Id { get; set; }
            public string MaCaptcha { get; set; }
            public string KetQua { get; set; }
            public string NgayNhap { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Đã có session → đẩy vào trang tương ứng
            if (!IsPostBack && Session["UserID"] != null)
            {
                string vt = Session["VaiTro"]?.ToString() ?? "";
                Response.Redirect(vt == "admin" ? URL_ADMIN : URL_USER, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Sinh captcha lan dau khi vao trang
            if (!IsPostBack)
            {
                GenerateCaptcha();
                BindCaptchaList();   // bind danh sach ma da nhap (neu co)
            }
        }

        // ════════════════════════════════
        //  CAPTCHA
        // ════════════════════════════════

        private void GenerateCaptcha()
        {
            var rnd = new Random();
            char[] chars = new char[5];
            // 3 chu hoa
            for (int i = 0; i < 3; i++) chars[i] = (char)('A' + rnd.Next(26));
            // 2 chu so
            for (int i = 3; i < 5; i++) chars[i] = (char)('0' + rnd.Next(10));
            // Shuffle Fisher-Yates de tron thu tu
            for (int i = chars.Length - 1; i > 0; i--)
            {
                int j = rnd.Next(i + 1);
                char tmp = chars[i]; chars[i] = chars[j]; chars[j] = tmp;
            }
            string captcha = new string(chars) + "@";
            Session["LoginCaptcha"] = captcha;
            lblCaptcha.Text = captcha;
        }

        /// <summary>Click nut Refresh -> sinh ma moi</summary>
        protected void btnRefreshCaptcha_Click(object sender, EventArgs e)
        {
            GenerateCaptcha();
            txtCaptcha.Text = "";
            lblMsg.Visible = false;
            hfAuthMode.Value = "login"; // dam bao van o tab login
        }

        /// <summary>Kiem tra captcha hop le va dung voi ma trong Session</summary>
        private bool ValidateCaptcha()
        {
            string input = (txtCaptcha.Text ?? "").Trim().ToUpper();
            string expected = Session["LoginCaptcha"] as string ?? "";

            // 1. Khong trong
            if (string.IsNullOrEmpty(input))
            {
                HienLoi("Vui lòng nhập mã xác nhận!");
                return false;
            }

            // 2. Dung format (3 chu hoa + 2 so + @)
            if (!CaptchaRegex.IsMatch(input))
            {
                HienLoi("Mã xác nhận sai định dạng! Phải có 3 chữ HOA + 2 chữ số + @");
                // Luu vao DB ket qua "failed_format"
                SaveCaptchaToDb(input, "failed");
                BindCaptchaList();
                GenerateCaptcha();
                txtCaptcha.Text = "";
                return false;
            }

            // 3. Phai khop voi ma da sinh
            bool match = string.Equals(input, expected, StringComparison.Ordinal);

            // ✅ LUU VAO DB: ket qua phu thuoc co khop khong
            SaveCaptchaToDb(input, match ? "success" : "failed");
            BindCaptchaList();

            if (!match)
            {
                HienLoi("Mã xác nhận không đúng! Vui lòng nhập lại.");
                GenerateCaptcha();
                txtCaptcha.Text = "";
                return false;
            }

            return true;
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            // Apply UI dựa trên hfAuthMode hiện tại
            ApplyTabUI(hfAuthMode.Value);
        }

        /// <summary>
        /// Đổi giao diện tab từ server (không cần JS)
        /// </summary>
        private void ApplyTabUI(string mode)
        {
            if (mode == "register")
            {
                formSection.Attributes["class"] = "auth-form-section register-active";
                tabLogin.Attributes["class"] = "tab-btn";
                tabRegister.Attributes["class"] = "tab-btn active";
                formTitle.InnerText = "Tạo tài khoản";
                formSubtitle.InnerText = "Điền thông tin để bắt đầu";
                btnSubmit.Text = "Tạo tài khoản";
                formFooter.InnerHtml = "Đã có tài khoản? <a href=\"#\" onclick=\"switchTab('login',null);return false;\">Đăng nhập</a>";
            }
            else
            {
                formSection.Attributes["class"] = "auth-form-section";
                tabLogin.Attributes["class"] = "tab-btn active";
                tabRegister.Attributes["class"] = "tab-btn";
                formTitle.InnerText = "Chào mừng trở lại";
                formSubtitle.InnerText = "Đăng nhập để tiếp tục sử dụng EventHub";
                btnSubmit.Text = "Đăng nhập";
                formFooter.InnerHtml = "Chưa có tài khoản? <a href=\"#\" onclick=\"switchTab('register',null);return false;\">Đăng ký ngay</a>";
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // ✅ CHỈ dựa vào hfAuthMode để quyết định
            //    (không kiểm tra txtLastName/txtFirstName vì ViewState có thể giữ giá trị cũ)
            if (hfAuthMode.Value == "register")
                DangKy();
            else
                DangNhap();
        }

        // ════════════════════════════════
        //  ĐĂNG NHẬP
        // ════════════════════════════════
        private void DangNhap()
        {
            hfAuthMode.Value = "login";

            string email = txtEmail.Text.Trim().ToLower();
            string mk = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(email)) { HienLoi("Vui lòng nhập email!"); return; }
            if (string.IsNullOrEmpty(mk)) { HienLoi("Vui lòng nhập mật khẩu!"); return; }

            // ✅ KIEM TRA CAPTCHA truoc khi submit
            if (!ValidateCaptcha()) return;

            string vaiTro = "";

            try
            {
                using (SqlConnection cn = new SqlConnection(Conn))
                {
                    cn.Open();

                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT UserID, Ho, Ten, Email, MatKhau, VaiTro, TrangThai, PhongBan
                          FROM dbo.Users
                          WHERE LOWER(Email) = @Email", cn))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);

                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (!dr.Read())
                            {
                                HienLoi("Email không tồn tại trong hệ thống!");
                                return;
                            }

                            string trangThai = dr["TrangThai"].ToString();
                            string mkDB = dr["MatKhau"].ToString().Trim();
                            vaiTro = dr["VaiTro"].ToString().Trim().ToLower();
                            int userId = Convert.ToInt32(dr["UserID"]);
                            string hoTen = (dr["Ho"].ToString() + " " + dr["Ten"].ToString()).Trim();
                            string emailDb = dr["Email"].ToString();
                            string phongBan = dr["PhongBan"] == DBNull.Value ? "" : dr["PhongBan"].ToString();

                            if (trangThai != "active")
                            {
                                HienLoi("Tài khoản đã bị khoá. Vui lòng liên hệ quản trị viên!");
                                return;
                            }

                            if (!string.Equals(mkDB, mk, StringComparison.Ordinal))
                            {
                                HienLoi("Sai mật khẩu! Vui lòng thử lại.");
                                GenerateCaptcha();      // sinh ma moi chong brute force
                                txtCaptcha.Text = "";
                                return;
                            }

                            Session["UserID"] = userId;
                            Session["HoTen"] = hoTen;
                            Session["Email"] = emailDb;
                            Session["VaiTro"] = vaiTro;
                            Session["PhongBan"] = phongBan;
                        }
                    }
                }

                Response.Redirect(vaiTro == "admin" ? URL_ADMIN : URL_USER, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                HienLoi("Lỗi hệ thống: " + ex.Message);
            }
        }

        // ════════════════════════════════
        //  ĐĂNG KÝ
        // ════════════════════════════════
        private void DangKy()
        {
            // Mặc định giữ ở tab đăng ký nếu fail
            hfAuthMode.Value = "register";

            string ho = txtLastName.Text.Trim();
            string ten = txtFirstName.Text.Trim();
            string pb = txtDept.Text.Trim();
            string em = txtEmail.Text.Trim().ToLower();
            string mk = txtPassword.Text.Trim();
            string xn = txtConfirmPassword.Text.Trim();

            if (string.IsNullOrEmpty(ho)) { HienLoi("Vui lòng nhập Họ!"); return; }
            if (string.IsNullOrEmpty(ten)) { HienLoi("Vui lòng nhập Tên!"); return; }
            if (string.IsNullOrEmpty(em)) { HienLoi("Vui lòng nhập Email!"); return; }
            if (string.IsNullOrEmpty(mk)) { HienLoi("Vui lòng nhập mật khẩu!"); return; }
            if (mk.Length < 6) { HienLoi("Mật khẩu phải có ít nhất 6 ký tự!"); return; }
            if (mk != xn) { HienLoi("Mật khẩu xác nhận không khớp!"); return; }

            try
            {
                using (SqlConnection cn = new SqlConnection(Conn))
                {
                    cn.Open();

                    using (SqlCommand chk = new SqlCommand(
                        "SELECT COUNT(*) FROM dbo.Users WHERE LOWER(Email) = @Email", cn))
                    {
                        chk.Parameters.AddWithValue("@Email", em);
                        int count = Convert.ToInt32(chk.ExecuteScalar());
                        if (count > 0)
                        {
                            HienLoi("Email này đã được đăng ký!");
                            return;
                        }
                    }

                    using (SqlCommand ins = new SqlCommand(@"
                        INSERT INTO dbo.Users
                            (Ho, Ten, Email, MatKhau, PhongBan, VaiTro, TrangThai, NgayTao, NgayCapNhat)
                        VALUES
                            (@Ho, @Ten, @Email, @MatKhau, @PhongBan, 'user', 'active', GETDATE(), GETDATE())", cn))
                    {
                        ins.Parameters.AddWithValue("@Ho", ho);
                        ins.Parameters.AddWithValue("@Ten", ten);
                        ins.Parameters.AddWithValue("@Email", em);
                        ins.Parameters.AddWithValue("@MatKhau", mk);
                        ins.Parameters.AddWithValue("@PhongBan",
                            string.IsNullOrEmpty(pb) ? (object)DBNull.Value : (object)pb);

                        if (ins.ExecuteNonQuery() > 0)
                        {
                            // ✅ Thành công → mới chuyển về tab Đăng nhập
                            HienOk("Đăng ký thành công! Vui lòng đăng nhập.");
                            txtLastName.Text = "";
                            txtFirstName.Text = "";
                            txtDept.Text = "";
                            txtPassword.Text = "";
                            txtConfirmPassword.Text = "";
                            hfAuthMode.Value = "login";   // chỉ ở đây mới đổi sang login
                        }
                        else
                        {
                            HienLoi("Đăng ký thất bại. Vui lòng thử lại!");
                        }
                    }
                }
            }
            catch (SqlException sx) when (sx.Number == 2627 || sx.Number == 2601)
            {
                HienLoi("Email đã tồn tại trong hệ thống!");
            }
            catch (Exception ex)
            {
                HienLoi("Lỗi: " + ex.Message);
            }
        }

        private void HienLoi(string msg)
        {
            lblMsg.Text = msg;
            lblMsg.Visible = true;
            lblMsg.CssClass = "msg-box msg-error";
        }

        private void HienOk(string msg)
        {
            lblMsg.Text = msg;
            lblMsg.Visible = true;
            lblMsg.CssClass = "msg-box msg-success";
        }
    }
}