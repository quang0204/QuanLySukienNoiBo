using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

namespace QuanLySuKien
{
    public partial class AdminEventForm : System.Web.UI.Page
    {
        // ════════════════════════════════════════════════════════════
        // CẤU HÌNH
        // ════════════════════════════════════════════════════════════

        private static readonly string ConnStr =
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        // Thư mục lưu ảnh bìa (tương đối tới root web)
        private const string UploadFolder = "~/Uploads/Events/";

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
            if (!IsPostBack)
            {
                // Default ngày bắt đầu = hôm nay (chỉ khi tạo mới)
                txtNgayBatDau.Text = DateTime.Today.ToString("yyyy-MM-dd");

                string id = Request.QueryString["id"];
                if (!string.IsNullOrEmpty(id) && int.TryParse(id, out int eventId))
                {
                    lblPageTitle.Text = "Chinh sua su kien";
                    lblBreadcrumb.Text = "Chinh sua";
                    hfEventId.Value = eventId.ToString();
                    LoadEvent(eventId);
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // BUTTON HANDLERS
        // ════════════════════════════════════════════════════════════

        protected void btnPublish_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            // Validate logic
            string err = ValidateInput();
            if (err != null) { ShowToast(err); return; }

            try
            {
                string trangThai = CalculateStatus();
                SaveEvent(trangThai);
                Response.Redirect("AdminEvents.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                ShowToast("Loi: " + ex.Message);
            }
        }

        /// <summary>
        /// Tinh TrangThai dung theo cac dieu kien:
        ///   now > NgayKT                -> 'ended'
        ///   BD <= now <= KT             -> 'ongoing'
        ///   now > HanDK hoac het cho    -> 'closed'  (chua dien ra)
        ///   Con han + con cho:
        ///     Neu admin truoc do dat 'closed' -> giu 'closed'
        ///     Mac dinh -> 'open'
        /// </summary>
        private string CalculateStatus()
        {
            DateTime ngayBatDau = DateTime.Parse(txtNgayBatDau.Text);
            DateTime? ngayKetThuc = string.IsNullOrWhiteSpace(txtNgayKetThuc.Text)
                ? (DateTime?)null : DateTime.Parse(txtNgayKetThuc.Text);
            DateTime? hanDangKy = string.IsNullOrWhiteSpace(txtHanDangKy.Text)
                ? (DateTime?)null : DateTime.Parse(txtHanDangKy.Text);
            int sucChua = int.Parse(txtSucChua.Text);

            DateTime today = DateTime.Today;
            DateTime ngayKt = ngayKetThuc ?? ngayBatDau;

            // 1. Da qua ngay ket thuc
            if (ngayKt.Date < today) return "ended";

            // 2. Trong khoang BD-KT -> ongoing
            if (ngayBatDau.Date <= today && ngayKt.Date >= today) return "ongoing";

            // ===== Cac TH chua toi NgayBatDau =====

            // 3. Het cho -> closed (chi check khi edit)
            string trangThaiCu = null;
            if (int.TryParse(hfEventId.Value, out int existingId) && existingId > 0)
            {
                int soDuyet = CountApproved(existingId);
                if (soDuyet >= sucChua) return "closed";
                trangThaiCu = GetCurrentStatus(existingId);
            }

            // 4. Het han DK -> closed
            if (hanDangKy.HasValue && hanDangKy.Value.Date < today) return "closed";

            // 5. Ton trong: neu admin truoc do dat 'closed' -> giu nguyen
            if (trangThaiCu == "closed") return "closed";

            // 6. Mac dinh -> open
            return "open";
        }

        /// <summary>Dem so dang ky da duyet cho su kien</summary>
        private int CountApproved(int suKienID)
        {
            const string sql =
                "SELECT COUNT(*) FROM dbo.DangKy WHERE SuKienID = @id AND TrangThai = 'approved';";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = suKienID;
                conn.Open();
                return (int)cmd.ExecuteScalar();
            }
        }

        /// <summary>Lay TrangThai hien tai cua su kien</summary>
        private string GetCurrentStatus(int suKienID)
        {
            const string sql = "SELECT TrangThai FROM dbo.SuKien WHERE SuKienID = @id;";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = suKienID;
                conn.Open();
                var result = cmd.ExecuteScalar();
                return result == null ? null : result.ToString();
            }
        }

        /// <summary>
        /// Validate input: ngay BD >= hom nay (khi tao moi), ngay KT >= BD,
        /// gio BD <= gio KT (neu cung ngay), han DK < ngay BD
        /// </summary>
        private string ValidateInput()
        {
            DateTime ngayBatDau = DateTime.Parse(txtNgayBatDau.Text);
            DateTime? ngayKetThuc = string.IsNullOrWhiteSpace(txtNgayKetThuc.Text)
                ? (DateTime?)null : DateTime.Parse(txtNgayKetThuc.Text);
            DateTime? hanDangKy = string.IsNullOrWhiteSpace(txtHanDangKy.Text)
                ? (DateTime?)null : DateTime.Parse(txtHanDangKy.Text);
            TimeSpan gioBatDau = ParseTime(txtGioBatDau.Text, new TimeSpan(8, 0, 0));
            TimeSpan? gioKetThuc = string.IsNullOrWhiteSpace(txtGioKetThuc.Text)
                ? (TimeSpan?)null : ParseTime(txtGioKetThuc.Text, new TimeSpan(17, 0, 0));

            DateTime today = DateTime.Today;
            bool isNew = !(int.TryParse(hfEventId.Value, out int eid) && eid > 0);

            // 1. Khi tao moi: ngay BD >= hom nay
            if (isNew && ngayBatDau.Date < today)
                return "Ngay bat dau phai >= ngay hien tai";

            // 2. Ngay KT >= ngay BD
            if (ngayKetThuc.HasValue && ngayKetThuc.Value.Date < ngayBatDau.Date)
                return "Ngay ket thuc phai >= ngay bat dau";

            // 3. Gio BD <= gio KT (neu cung ngay)
            if (gioKetThuc.HasValue)
            {
                DateTime ngayKt = ngayKetThuc ?? ngayBatDau;
                if (ngayBatDau.Date == ngayKt.Date && gioBatDau > gioKetThuc.Value)
                    return "Gio bat dau phai <= gio ket thuc";
            }

            // 4. Han DK < ngay BD
            if (hanDangKy.HasValue && hanDangKy.Value.Date >= ngayBatDau.Date)
                return "Han dang ky phai truoc ngay bat dau su kien";

            return null; // OK
        }

        protected void btnDraft_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate nhe cho draft (van phai dam bao logic ngay thang)
                if (!string.IsNullOrWhiteSpace(txtNgayBatDau.Text))
                {
                    string err = ValidateInput();
                    if (err != null) { ShowToast(err); return; }
                }

                SaveEvent("draft");
                ShowToast("Da luu nhap!");
            }
            catch (Exception ex)
            {
                ShowToast("Loi khi luu nhap: " + ex.Message);
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Response.Redirect("AdminEvents.aspx");
        }

        // ════════════════════════════════════════════════════════════
        // CORE: Save (Insert hoặc Update)
        // ════════════════════════════════════════════════════════════

        private void SaveEvent(string trangThai)
        {
            // Lấy dữ liệu từ form
            string tenSuKien = txtTenSuKien.Text.Trim();
            string moTa = txtMoTa.Text.Trim();
            // LoaiSuKien lấy từ HiddenField (do JS set khi click option-card)
            string loaiSuKien = string.IsNullOrEmpty(hfLoaiSuKien.Value) ? "Team Building" : hfLoaiSuKien.Value;

            DateTime ngayBatDau = DateTime.Parse(txtNgayBatDau.Text);
            DateTime? ngayKetThuc = string.IsNullOrWhiteSpace(txtNgayKetThuc.Text)
                ? (DateTime?)null : DateTime.Parse(txtNgayKetThuc.Text);

            TimeSpan gioBatDau = ParseTime(txtGioBatDau.Text, new TimeSpan(8, 0, 0));
            TimeSpan? gioKetThuc = string.IsNullOrWhiteSpace(txtGioKetThuc.Text)
                ? (TimeSpan?)null : ParseTime(txtGioKetThuc.Text, new TimeSpan(17, 0, 0));

            string diaDiem = txtDiaDiem.Text.Trim();
            string linkBanDo = string.IsNullOrWhiteSpace(txtLinkBanDo.Text) ? null : txtLinkBanDo.Text.Trim();
            int sucChua = int.Parse(txtSucChua.Text);
            DateTime? hanDangKy = string.IsNullOrWhiteSpace(txtHanDangKy.Text)
                ? (DateTime?)null : DateTime.Parse(txtHanDangKy.Text);

            bool yeuCauDuyet = chkYeuCauDuyet.Checked;
            bool danhSachCho = chkDanhSachCho.Checked;
            bool choPhepHuy = chkHuyDangKy.Checked;
            bool batFeedback = chkFeedback.Checked;

            // Xử lý upload ảnh (nếu có)
            string anhBia = HandleImageUpload();

            // Lấy NguoiTaoID từ Session
            int nguoiTaoID = GetCurrentUserId();

            // Insert hay Update?
            int.TryParse(hfEventId.Value, out int existingId);

            if (existingId > 0)
            {
                UpdateEvent(existingId, tenSuKien, moTa, loaiSuKien, ngayBatDau, ngayKetThuc,
                    gioBatDau, gioKetThuc, diaDiem, linkBanDo, sucChua, hanDangKy, anhBia,
                    trangThai, yeuCauDuyet, danhSachCho, choPhepHuy, batFeedback);
            }
            else
            {
                int newId = InsertEvent(tenSuKien, moTa, loaiSuKien, ngayBatDau, ngayKetThuc,
                    gioBatDau, gioKetThuc, diaDiem, linkBanDo, sucChua, hanDangKy, anhBia,
                    trangThai, yeuCauDuyet, danhSachCho, choPhepHuy, batFeedback, nguoiTaoID);
                hfEventId.Value = newId.ToString();
            }
        }

        // ════════════════════════════════════════════════════════════
        // DATA ACCESS - INSERT
        // ════════════════════════════════════════════════════════════

        private int InsertEvent(string tenSuKien, string moTa, string loaiSuKien,
            DateTime ngayBatDau, DateTime? ngayKetThuc, TimeSpan gioBatDau, TimeSpan? gioKetThuc,
            string diaDiem, string linkBanDo, int sucChua, DateTime? hanDangKy, string anhBia,
            string trangThai, bool yeuCauDuyet, bool danhSachCho, bool choPhepHuy, bool batFeedback,
            int nguoiTaoID)
        {
            const string sql = @"
                INSERT INTO dbo.SuKien
                    (TenSuKien, MoTa, LoaiSuKien, NgayBatDau, NgayKetThuc,
                     GioBatDau, GioKetThuc, DiaDiem, LinkBanDo, SucChua,
                     HanDangKy, AnhBia, TrangThai, YeuCauDuyet, DanhSachCho,
                     ChoPhepHuy, BatFeedback, NguoiTaoID, NgayTao, NgayCapNhat)
                VALUES
                    (@TenSuKien, @MoTa, @LoaiSuKien, @NgayBatDau, @NgayKetThuc,
                     @GioBatDau, @GioKetThuc, @DiaDiem, @LinkBanDo, @SucChua,
                     @HanDangKy, @AnhBia, @TrangThai, @YeuCauDuyet, @DanhSachCho,
                     @ChoPhepHuy, @BatFeedback, @NguoiTaoID, GETDATE(), GETDATE());
                SELECT CAST(SCOPE_IDENTITY() AS INT);";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@TenSuKien", SqlDbType.NVarChar, 200).Value = tenSuKien;
                cmd.Parameters.Add("@MoTa", SqlDbType.NVarChar, -1).Value = (object)moTa ?? DBNull.Value;
                cmd.Parameters.Add("@LoaiSuKien", SqlDbType.NVarChar, 30).Value = loaiSuKien;
                cmd.Parameters.Add("@NgayBatDau", SqlDbType.Date).Value = ngayBatDau;
                cmd.Parameters.Add("@NgayKetThuc", SqlDbType.Date).Value = (object)ngayKetThuc ?? DBNull.Value;
                cmd.Parameters.Add("@GioBatDau", SqlDbType.Time).Value = gioBatDau;
                cmd.Parameters.Add("@GioKetThuc", SqlDbType.Time).Value = (object)gioKetThuc ?? DBNull.Value;
                cmd.Parameters.Add("@DiaDiem", SqlDbType.NVarChar, 300).Value = diaDiem;
                cmd.Parameters.Add("@LinkBanDo", SqlDbType.NVarChar, 500).Value = (object)linkBanDo ?? DBNull.Value;
                cmd.Parameters.Add("@SucChua", SqlDbType.Int).Value = sucChua;
                cmd.Parameters.Add("@HanDangKy", SqlDbType.Date).Value = (object)hanDangKy ?? DBNull.Value;
                cmd.Parameters.Add("@AnhBia", SqlDbType.NVarChar, 500).Value = (object)anhBia ?? DBNull.Value;
                cmd.Parameters.Add("@TrangThai", SqlDbType.NVarChar, 20).Value = trangThai;
                cmd.Parameters.Add("@YeuCauDuyet", SqlDbType.Bit).Value = yeuCauDuyet;
                cmd.Parameters.Add("@DanhSachCho", SqlDbType.Bit).Value = danhSachCho;
                cmd.Parameters.Add("@ChoPhepHuy", SqlDbType.Bit).Value = choPhepHuy;
                cmd.Parameters.Add("@BatFeedback", SqlDbType.Bit).Value = batFeedback;
                cmd.Parameters.Add("@NguoiTaoID", SqlDbType.Int).Value = nguoiTaoID;

                conn.Open();
                return (int)cmd.ExecuteScalar();
            }
        }

        // ════════════════════════════════════════════════════════════
        // DATA ACCESS - UPDATE
        // ════════════════════════════════════════════════════════════

        private void UpdateEvent(int suKienID, string tenSuKien, string moTa, string loaiSuKien,
            DateTime ngayBatDau, DateTime? ngayKetThuc, TimeSpan gioBatDau, TimeSpan? gioKetThuc,
            string diaDiem, string linkBanDo, int sucChua, DateTime? hanDangKy, string anhBia,
            string trangThai, bool yeuCauDuyet, bool danhSachCho, bool choPhepHuy, bool batFeedback)
        {
            // Nếu không upload ảnh mới (anhBia = null) thì giữ ảnh cũ qua COALESCE
            const string sql = @"
                UPDATE dbo.SuKien SET
                    TenSuKien       = @TenSuKien,
                    MoTa            = @MoTa,
                    LoaiSuKien      = @LoaiSuKien,
                    NgayBatDau      = @NgayBatDau,
                    NgayKetThuc     = @NgayKetThuc,
                    GioBatDau       = @GioBatDau,
                    GioKetThuc      = @GioKetThuc,
                    DiaDiem         = @DiaDiem,
                    LinkBanDo       = @LinkBanDo,
                    SucChua         = @SucChua,
                    HanDangKy       = @HanDangKy,
                    AnhBia          = COALESCE(@AnhBia, AnhBia),
                    TrangThai       = @TrangThai,
                    YeuCauDuyet     = @YeuCauDuyet,
                    DanhSachCho     = @DanhSachCho,
                    ChoPhepHuy      = @ChoPhepHuy,
                    BatFeedback     = @BatFeedback,
                    NgayCapNhat     = GETDATE()
                WHERE SuKienID      = @SuKienID;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@SuKienID", SqlDbType.Int).Value = suKienID;
                cmd.Parameters.Add("@TenSuKien", SqlDbType.NVarChar, 200).Value = tenSuKien;
                cmd.Parameters.Add("@MoTa", SqlDbType.NVarChar, -1).Value = (object)moTa ?? DBNull.Value;
                cmd.Parameters.Add("@LoaiSuKien", SqlDbType.NVarChar, 30).Value = loaiSuKien;
                cmd.Parameters.Add("@NgayBatDau", SqlDbType.Date).Value = ngayBatDau;
                cmd.Parameters.Add("@NgayKetThuc", SqlDbType.Date).Value = (object)ngayKetThuc ?? DBNull.Value;
                cmd.Parameters.Add("@GioBatDau", SqlDbType.Time).Value = gioBatDau;
                cmd.Parameters.Add("@GioKetThuc", SqlDbType.Time).Value = (object)gioKetThuc ?? DBNull.Value;
                cmd.Parameters.Add("@DiaDiem", SqlDbType.NVarChar, 300).Value = diaDiem;
                cmd.Parameters.Add("@LinkBanDo", SqlDbType.NVarChar, 500).Value = (object)linkBanDo ?? DBNull.Value;
                cmd.Parameters.Add("@SucChua", SqlDbType.Int).Value = sucChua;
                cmd.Parameters.Add("@HanDangKy", SqlDbType.Date).Value = (object)hanDangKy ?? DBNull.Value;
                cmd.Parameters.Add("@AnhBia", SqlDbType.NVarChar, 500).Value = (object)anhBia ?? DBNull.Value;
                cmd.Parameters.Add("@TrangThai", SqlDbType.NVarChar, 20).Value = trangThai;
                cmd.Parameters.Add("@YeuCauDuyet", SqlDbType.Bit).Value = yeuCauDuyet;
                cmd.Parameters.Add("@DanhSachCho", SqlDbType.Bit).Value = danhSachCho;
                cmd.Parameters.Add("@ChoPhepHuy", SqlDbType.Bit).Value = choPhepHuy;
                cmd.Parameters.Add("@BatFeedback", SqlDbType.Bit).Value = batFeedback;

                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ════════════════════════════════════════════════════════════
        // LOAD: Bind dữ liệu lên form khi edit
        // ════════════════════════════════════════════════════════════

        private void LoadEvent(int id)
        {
            const string sql = "SELECT * FROM dbo.SuKien WHERE SuKienID = @id;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();

                using (var rd = cmd.ExecuteReader())
                {
                    if (!rd.Read())
                    {
                        ShowToast("Khong tim thay su kien!");
                        return;
                    }

                    txtTenSuKien.Text = rd["TenSuKien"].ToString();
                    txtMoTa.Text = rd["MoTa"] as string ?? "";

                    // LoaiSuKien set vào hidden field, JS sẽ đọc và đánh selected
                    hfLoaiSuKien.Value = rd["LoaiSuKien"].ToString();

                    txtNgayBatDau.Text = ((DateTime)rd["NgayBatDau"]).ToString("yyyy-MM-dd");
                    txtNgayKetThuc.Text = (rd["NgayKetThuc"] as DateTime?)?.ToString("yyyy-MM-dd") ?? "";
                    txtGioBatDau.Text = ((TimeSpan)rd["GioBatDau"]).ToString(@"hh\:mm");
                    txtGioKetThuc.Text = (rd["GioKetThuc"] as TimeSpan?)?.ToString(@"hh\:mm") ?? "";

                    txtDiaDiem.Text = rd["DiaDiem"].ToString();
                    txtLinkBanDo.Text = rd["LinkBanDo"] as string ?? "";
                    txtSucChua.Text = rd["SucChua"].ToString();
                    txtHanDangKy.Text = (rd["HanDangKy"] as DateTime?)?.ToString("yyyy-MM-dd") ?? "";

                    chkYeuCauDuyet.Checked = (bool)rd["YeuCauDuyet"];
                    chkDanhSachCho.Checked = (bool)rd["DanhSachCho"];
                    chkHuyDangKy.Checked = (bool)rd["ChoPhepHuy"];
                    chkFeedback.Checked = (bool)rd["BatFeedback"];

                    string anhBia = rd["AnhBia"] as string;
                    if (!string.IsNullOrEmpty(anhBia))
                    {
                        imgPreview.ImageUrl = ResolveUrl(anhBia);
                        // Đảm bảo image hiển thị (CSS display:none cho .upload-preview mặc định)
                        // Markup dùng class 'has-img', script sẽ thêm class này khi có ảnh
                        ClientScript.RegisterStartupScript(GetType(), "showImg",
                            "document.getElementById('uploadZone').classList.add('has-img');", true);
                    }
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // UPLOAD ẢNH BÌA
        // ════════════════════════════════════════════════════════════

        private string HandleImageUpload()
        {
            if (!fuAnhBia.HasFile) return null;

            string ext = Path.GetExtension(fuAnhBia.FileName).ToLowerInvariant();
            string[] allowed = { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
            if (Array.IndexOf(allowed, ext) < 0)
                throw new Exception("Dinh dang anh khong hop le. Chi chap nhan: jpg, png, gif, webp.");

            // Giới hạn 5MB
            if (fuAnhBia.PostedFile.ContentLength > 5 * 1024 * 1024)
                throw new Exception("Anh vuot qua 5MB.");

            // Đảm bảo thư mục tồn tại
            string physicalDir = Server.MapPath(UploadFolder);
            if (!Directory.Exists(physicalDir))
                Directory.CreateDirectory(physicalDir);

            // Tên file unique
            string fileName = $"event_{DateTime.Now:yyyyMMddHHmmss}_{Guid.NewGuid():N}".Substring(0, 40) + ext;
            string physicalPath = Path.Combine(physicalDir, fileName);

            fuAnhBia.SaveAs(physicalPath);

            // Trả về đường dẫn tương đối lưu vào DB
            return UploadFolder.TrimStart('~') + fileName;
        }

        // ════════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════════

        private TimeSpan ParseTime(string text, TimeSpan fallback)
        {
            if (TimeSpan.TryParse(text, out TimeSpan ts)) return ts;
            return fallback;
        }

        /// <summary>
        /// Lấy UserID từ Session. Cần cấu hình trong trang đăng nhập:
        ///   Session["UserID"] = userId;
        /// Tạm fallback về 1 (admin seed) nếu chưa có session.
        /// </summary>
        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int uid))
                return uid;

            // Fallback - nên redirect ve Login.aspx trong production
            return 1;
        }

        private void ShowToast(string msg)
        {
            string safe = msg.Replace("'", "\\'");
            // Toast theo CSS Master Page (class .toast.show)
            string js = $@"
                var t=document.createElement('div');
                t.className='toast show';
                t.textContent='{safe}';
                document.body.appendChild(t);
                setTimeout(function(){{t.classList.remove('show');setTimeout(function(){{t.remove();}},300);}},3000);";
            ClientScript.RegisterStartupScript(GetType(), "toast", js, true);
        }
    }
}