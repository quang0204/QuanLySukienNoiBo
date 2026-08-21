using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace QuanLySuKien
{
    public partial class AdminParticipants : System.Web.UI.Page
    {
        private static readonly string ConnStr =
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        // ════════════════════════════════════════════════════════════
        // PAGE LIFECYCLE
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
                if (string.IsNullOrEmpty(hfTab.Value))
                    hfTab.Value = "pending";

                BindEventDropdown();
                LoadParticipants();
            }
        }

        // ════════════════════════════════════════════════════════════
        // BIND DROPDOWN SU KIEN
        // ════════════════════════════════════════════════════════════

        private void BindEventDropdown()
        {
            const string sql = @"
                SELECT s.SuKienID, s.TenSuKien, s.NgayBatDau,
                       ISNULL(d.SoDK, 0) AS SoDK
                FROM dbo.SuKien s
                LEFT JOIN (
                    SELECT SuKienID, COUNT(*) AS SoDK FROM dbo.DangKy
                    WHERE TrangThai IN ('approved','pending')
                    GROUP BY SuKienID
                ) d ON s.SuKienID = d.SuKienID
                WHERE s.TrangThai <> 'draft'
                ORDER BY s.NgayBatDau DESC;";

            string prev = ddlSuKien.SelectedValue;
            ddlSuKien.Items.Clear();
            ddlSuKien.Items.Add(new ListItem("-- Tat ca su kien --", ""));

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        DateTime bd = (DateTime)rd["NgayBatDau"];
                        string text = string.Format("{0} ({1:dd/MM/yyyy}) - {2} nguoi",
                            rd["TenSuKien"], bd, rd["SoDK"]);
                        ddlSuKien.Items.Add(new ListItem(text, rd["SuKienID"].ToString()));
                    }
                }
            }

            if (!string.IsNullOrEmpty(prev))
                ddlSuKien.SelectedValue = prev;
        }

        // ════════════════════════════════════════════════════════════
        // LOAD PARTICIPANTS
        // ════════════════════════════════════════════════════════════

        private void LoadParticipants()
        {
            string tab = hfTab.Value ?? "pending";
            int? suKienId = null;
            if (int.TryParse(ddlSuKien.SelectedValue, out int sid) && sid > 0)
                suKienId = sid;

            string phongBan = ddlFilter.SelectedValue;
            string keyword = txtSearch.Text?.Trim() ?? "";

            var sb = new StringBuilder(@"
                SELECT
                    dk.DangKyID,
                    dk.UserID AS MaNguoiDung,
                    dk.SuKienID,
                    u.Ho + N' ' + u.Ten AS HoTen,
                    LEFT(u.Ho,1) + LEFT(u.Ten,1) AS TenVietTat,
                    u.Email, u.PhongBan,
                    dk.TrangThai,
                    dk.DaDiemDanh,
                    dk.NgayDangKy,
                    s.SucChua,
                    -- Dem so duyet HIEN TAI cua su kien
                    ISNULL((SELECT COUNT(*) FROM dbo.DangKy d2
                            WHERE d2.SuKienID = s.SuKienID
                              AND d2.TrangThai = 'approved'), 0) AS SoDaDuyet
                FROM dbo.DangKy dk
                INNER JOIN dbo.Users u ON dk.UserID = u.UserID
                INNER JOIN dbo.SuKien s ON dk.SuKienID = s.SuKienID
                WHERE 1=1 ");

            // QUAN TRONG: KHONG hien 'cancelled' (user huy roi)
            switch (tab)
            {
                case "pending": sb.Append(" AND dk.TrangThai = 'pending' "); break;
                case "approved": sb.Append(" AND dk.TrangThai = 'approved' AND dk.DaDiemDanh = 0 "); break;
                case "rejected": sb.Append(" AND dk.TrangThai = 'rejected' "); break;
                case "attended": sb.Append(" AND dk.DaDiemDanh = 1 "); break;
                case "all":
                default:
                    sb.Append(" AND dk.TrangThai IN ('pending','approved','rejected') ");
                    break;
            }

            if (suKienId.HasValue)
                sb.Append(" AND dk.SuKienID = @sid ");
            if (!string.IsNullOrEmpty(phongBan))
                sb.Append(" AND u.PhongBan LIKE @pb ");
            if (!string.IsNullOrEmpty(keyword))
                sb.Append(" AND (u.Ho LIKE @kw OR u.Ten LIKE @kw OR u.Email LIKE @kw) ");

            sb.Append(" ORDER BY dk.NgayDangKy ASC;");  // Sort ASC -> ai dk truoc thi hien truoc

            var list = new List<ParticipantRow>();
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sb.ToString(), conn))
            {
                if (suKienId.HasValue)
                    cmd.Parameters.Add("@sid", SqlDbType.Int).Value = suKienId.Value;
                if (!string.IsNullOrEmpty(phongBan))
                    cmd.Parameters.Add("@pb", SqlDbType.NVarChar, 100).Value = "%" + phongBan + "%";
                if (!string.IsNullOrEmpty(keyword))
                    cmd.Parameters.Add("@kw", SqlDbType.NVarChar, 200).Value = "%" + keyword + "%";

                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        string tt = rd["TrangThai"].ToString();
                        bool daDD = (bool)rd["DaDiemDanh"];
                        int sucChua = (int)rd["SucChua"];
                        int soDaDuyet = (int)rd["SoDaDuyet"];

                        // Su kien da day cho? (so duyet >= suc chua)
                        bool eventFull = soDaDuyet >= sucChua;

                        // CSS + label cho badge
                        string ttCss, ttText;
                        if (daDD)
                        {
                            ttCss = "attended"; ttText = "Da diem danh";
                        }
                        else
                        {
                            switch (tt)
                            {
                                case "pending": ttCss = "pending"; ttText = "Cho duyet"; break;
                                case "approved": ttCss = "approved"; ttText = "Da duyet"; break;
                                case "rejected": ttCss = "rejected"; ttText = "Tu choi"; break;
                                default: ttCss = "pending"; ttText = tt; break;
                            }
                        }

                        // ═══ LOGIC HANH DONG (LINH HOAT) ═══
                        // - pending + con cho     -> [Duyet] [Tu choi]
                        // - pending + het cho     -> (Het cho) [Tu choi]
                        // - approved + chua DD    -> [Tu choi] (doi y -> chuyen rejected, mo cho cho nguoi khac)
                        // - approved + da DD      -> KHONG cho lam gi (da tham gia roi)
                        // - rejected + con cho    -> [Duyet lai]  (admin doi y -> approve lai)
                        // - rejected + het cho    -> (Het cho) (khong duyet duoc nx)
                        bool canApprove, canReject;
                        if (daDD)
                        {
                            // Da diem danh -> khong cho doi
                            canApprove = false;
                            canReject = false;
                        }
                        else if (tt == "pending")
                        {
                            canApprove = !eventFull;  // chi duyet khi con cho
                            canReject = true;        // luon co the tu choi
                        }
                        else if (tt == "approved")
                        {
                            canApprove = false;       // da duyet roi, khong can duyet nx
                            canReject = true;        // van cho tu choi (admin doi y)
                        }
                        else if (tt == "rejected")
                        {
                            canApprove = !eventFull;  // cho duyet lai neu con cho
                            canReject = false;       // da tu choi roi, khong can tu choi nx
                        }
                        else
                        {
                            canApprove = false;
                            canReject = false;
                        }

                        bool canCheckin = (tt == "approved" && !daDD);

                        list.Add(new ParticipantRow
                        {
                            DangKyID = (int)rd["DangKyID"],
                            MaNguoiDung = (int)rd["MaNguoiDung"],
                            HoTen = rd["HoTen"].ToString(),
                            TenVietTat = (rd["TenVietTat"] as string ?? "").ToUpper(),
                            Email = rd["Email"].ToString(),
                            PhongBan = rd["PhongBan"] as string ?? "",
                            NgayDangKy = (DateTime)rd["NgayDangKy"],
                            DaDiemDanh = daDD,
                            TrangThaiText = ttText,
                            TrangThaiClass = ttCss,
                            CanApprove = canApprove,
                            CanReject = canReject,
                            CanCheckin = canCheckin,
                            EventFull = eventFull
                        });
                    }
                }
            }

            gvParticipants.DataSource = list;
            gvParticipants.DataBind();

            UpdateTabCounts(suKienId);
        }

        // ════════════════════════════════════════════════════════════
        // UPDATE TAB COUNTS
        // ════════════════════════════════════════════════════════════

        private void UpdateTabCounts(int? suKienId)
        {
            const string sql = @"
                SELECT
                    SUM(CASE WHEN TrangThai IN ('pending','approved','rejected') THEN 1 ELSE 0 END) AS AllCnt,
                    SUM(CASE WHEN TrangThai = 'pending'  THEN 1 ELSE 0 END) AS PendingCnt,
                    SUM(CASE WHEN TrangThai = 'approved' AND DaDiemDanh = 0 THEN 1 ELSE 0 END) AS ApprovedCnt,
                    SUM(CASE WHEN TrangThai = 'rejected' THEN 1 ELSE 0 END) AS RejectedCnt,
                    SUM(CASE WHEN DaDiemDanh = 1 THEN 1 ELSE 0 END) AS AttendedCnt
                FROM dbo.DangKy
                WHERE (@sid IS NULL OR SuKienID = @sid);";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@sid", SqlDbType.Int).Value =
                    suKienId.HasValue ? (object)suKienId.Value : DBNull.Value;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        hfCountAll.Value = (rd["AllCnt"] == DBNull.Value ? 0 : (int)rd["AllCnt"]).ToString();
                        hfCountPending.Value = (rd["PendingCnt"] == DBNull.Value ? 0 : (int)rd["PendingCnt"]).ToString();
                        hfCountApproved.Value = (rd["ApprovedCnt"] == DBNull.Value ? 0 : (int)rd["ApprovedCnt"]).ToString();
                        hfCountRejected.Value = (rd["RejectedCnt"] == DBNull.Value ? 0 : (int)rd["RejectedCnt"]).ToString();
                        hfCountAttended.Value = (rd["AttendedCnt"] == DBNull.Value ? 0 : (int)rd["AttendedCnt"]).ToString();
                    }
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // BUTTON HANDLERS
        // ════════════════════════════════════════════════════════════

        protected void ddlSuKien_Changed(object sender, EventArgs e) { LoadParticipants(); }
        protected void ddlFilter_Changed(object sender, EventArgs e) { LoadParticipants(); }
        protected void btnSearch_Click(object sender, EventArgs e) { LoadParticipants(); }
        protected void btnExport_Click(object sender, EventArgs e) { ExportParticipantsCsv(); }
        protected void btnNotify_Click(object sender, EventArgs e) { /* TODO */ }
        protected void btnExportList_Click(object sender, EventArgs e) { ExportParticipantsCsv(); }

        protected void btnApproveAll_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(ddlSuKien.SelectedValue, out int sid) || sid <= 0)
            {
                Toast("Vui long chon su kien truoc.");
                return;
            }

            // Tinh so cho con lai
            int sucChua, soDaDuyet;
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(
                @"SELECT s.SucChua,
                         ISNULL((SELECT COUNT(*) FROM dbo.DangKy
                                 WHERE SuKienID = s.SuKienID AND TrangThai = 'approved'), 0) AS SoDuyet
                  FROM dbo.SuKien s WHERE s.SuKienID = @sid;", conn))
            {
                cmd.Parameters.Add("@sid", SqlDbType.Int).Value = sid;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (!rd.Read()) { Toast("Khong tim thay su kien."); return; }
                    sucChua = (int)rd["SucChua"];
                    soDaDuyet = (int)rd["SoDuyet"];
                }
            }

            int conLai = sucChua - soDaDuyet;
            if (conLai <= 0)
            {
                Toast("Su kien da day cho. Khong the duyet them.");
                LoadParticipants();
                return;
            }

            // Duyet TOI DA conLai dang ky pending (theo thu tu NgayDangKy ASC - ai dk truoc duoc duyet truoc)
            string sql = @"
                ;WITH PendingOrder AS (
                    SELECT TOP (@maxApprove) DangKyID
                    FROM dbo.DangKy
                    WHERE SuKienID = @sid AND TrangThai = 'pending'
                    ORDER BY NgayDangKy ASC
                )
                UPDATE dbo.DangKy
                   SET TrangThai = 'approved',
                       NguoiDuyetID = @adminId,
                       NgayDuyet = GETDATE(),
                       NgayCapNhat = GETDATE()
                 WHERE DangKyID IN (SELECT DangKyID FROM PendingOrder);";

            int adminId = (int)(Session["UserID"] ?? 1);
            int rows = 0;
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@sid", SqlDbType.Int).Value = sid;
                cmd.Parameters.Add("@adminId", SqlDbType.Int).Value = adminId;
                cmd.Parameters.Add("@maxApprove", SqlDbType.Int).Value = conLai;
                conn.Open();
                rows = cmd.ExecuteNonQuery();
            }

            // Check con pending khong (= du nhu cau hon suc chua)
            int conPending = 0;
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(
                "SELECT COUNT(*) FROM dbo.DangKy WHERE SuKienID = @sid AND TrangThai = 'pending';", conn))
            {
                cmd.Parameters.Add("@sid", SqlDbType.Int).Value = sid;
                conn.Open();
                conPending = (int)cmd.ExecuteScalar();
            }

            if (conPending > 0)
                Toast("Da duyet " + rows + " dang ky. Con " + conPending + " dang ky chua duoc duyet do het cho.");
            else
                Toast("Da duyet " + rows + " dang ky.");

            LoadParticipants();
        }

        protected void gvParticipants_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvParticipants.PageIndex = e.NewPageIndex;
            LoadParticipants();
        }

        protected void gvParticipants_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int userId)) return;
            if (!int.TryParse(ddlSuKien.SelectedValue, out int sid) || sid <= 0)
            {
                Toast("Vui long chon su kien truoc.");
                return;
            }

            try
            {
                int adminId = (int)(Session["UserID"] ?? 1);

                // Lay trang thai hien tai cua dang ky
                string curStatus = GetRegistrationStatus(userId, sid);
                bool daDD = HasAttended(userId, sid);

                if (e.CommandName == "Approve")
                {
                    // Khong cho thay doi neu da diem danh
                    if (daDD)
                    {
                        Toast("Nguoi nay da diem danh, khong the thay doi.");
                        LoadParticipants();
                        return;
                    }
                    // Khong duyet 2 lan
                    if (curStatus == "approved")
                    {
                        Toast("Da duyet roi.");
                        LoadParticipants();
                        return;
                    }
                    // Check con cho khong
                    // (truong hop chuyen tu rejected -> approved hoac pending -> approved)
                    if (IsEventFull(sid))
                    {
                        Toast("Su kien da day cho. Khong the duyet them.");
                        LoadParticipants();
                        return;
                    }
                    UpdateRegistrationStatus(userId, sid, "approved", adminId);
                    Toast("Da duyet dang ky.");
                }
                else if (e.CommandName == "Reject")
                {
                    if (daDD)
                    {
                        Toast("Nguoi nay da diem danh, khong the tu choi.");
                        LoadParticipants();
                        return;
                    }
                    if (curStatus == "rejected")
                    {
                        Toast("Da tu choi roi.");
                        LoadParticipants();
                        return;
                    }
                    UpdateRegistrationStatus(userId, sid, "rejected", adminId);
                    Toast("Da tu choi dang ky.");
                }
                else if (e.CommandName == "Checkin")
                {
                    ToggleAttended(userId, sid);
                    Toast("Da diem danh.");
                }
                LoadParticipants();
            }
            catch (Exception ex)
            {
                Toast("Loi: " + ex.Message);
            }
        }

        private string GetRegistrationStatus(int userId, int suKienId)
        {
            const string sql = @"SELECT TrangThai FROM dbo.DangKy
                                 WHERE UserID = @u AND SuKienID = @s;";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@u", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@s", SqlDbType.Int).Value = suKienId;
                conn.Open();
                var v = cmd.ExecuteScalar();
                return v?.ToString() ?? "";
            }
        }

        private bool HasAttended(int userId, int suKienId)
        {
            const string sql = @"SELECT COUNT(*) FROM dbo.DangKy
                                 WHERE UserID = @u AND SuKienID = @s AND DaDiemDanh = 1;";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@u", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@s", SqlDbType.Int).Value = suKienId;
                conn.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        /// <summary>Check su kien da day cho duyet chua</summary>
        private bool IsEventFull(int suKienId)
        {
            const string sql = @"
                SELECT s.SucChua,
                       ISNULL((SELECT COUNT(*) FROM dbo.DangKy
                               WHERE SuKienID = s.SuKienID AND TrangThai = 'approved'), 0) AS SoDuyet
                FROM dbo.SuKien s WHERE s.SuKienID = @sid;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@sid", SqlDbType.Int).Value = suKienId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (!rd.Read()) return false;
                    int sucChua = (int)rd["SucChua"];
                    int soDuyet = (int)rd["SoDuyet"];
                    return soDuyet >= sucChua;
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // DATA ACCESS
        // ════════════════════════════════════════════════════════════

        private void UpdateRegistrationStatus(int userId, int suKienId, string newStatus, int adminId)
        {
            const string sql = @"
                UPDATE dbo.DangKy
                   SET TrangThai = @s,
                       NguoiDuyetID = @aid,
                       NgayDuyet = GETDATE(),
                       NgayCapNhat = GETDATE()
                 WHERE UserID = @uid AND SuKienID = @sid;";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@uid", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@sid", SqlDbType.Int).Value = suKienId;
                cmd.Parameters.Add("@s", SqlDbType.NVarChar, 20).Value = newStatus;
                cmd.Parameters.Add("@aid", SqlDbType.Int).Value = adminId;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void ToggleAttended(int userId, int suKienId)
        {
            const string sql = @"
                UPDATE dbo.DangKy
                   SET DaDiemDanh = 1, NgayCapNhat = GETDATE()
                 WHERE UserID = @uid AND SuKienID = @sid AND TrangThai = 'approved';";
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@uid", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@sid", SqlDbType.Int).Value = suKienId;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ════════════════════════════════════════════════════════════
        // EXPORT CSV
        // ════════════════════════════════════════════════════════════

        private void ExportParticipantsCsv()
        {
            int sid = 0;
            int.TryParse(ddlSuKien.SelectedValue, out sid);

            string sql = @"
                SELECT u.Ho + N' ' + u.Ten AS HoTen, u.Email, u.PhongBan,
                       dk.TrangThai, dk.DaDiemDanh, dk.NgayDangKy, s.TenSuKien
                FROM dbo.DangKy dk
                INNER JOIN dbo.Users u ON dk.UserID = u.UserID
                INNER JOIN dbo.SuKien s ON dk.SuKienID = s.SuKienID
                WHERE dk.TrangThai IN ('pending','approved','rejected')
                " + (sid > 0 ? " AND dk.SuKienID = @sid " : "") + @"
                ORDER BY dk.NgayDangKy DESC;";

            var sb = new StringBuilder();
            sb.AppendLine("Ho ten,Email,Phong ban,Trang thai,Da diem danh,Ngay dang ky,Su kien");

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                if (sid > 0) cmd.Parameters.Add("@sid", SqlDbType.Int).Value = sid;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        sb.AppendFormat("\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5:dd/MM/yyyy HH:mm}\",\"{6}\"\n",
                            rd["HoTen"], rd["Email"], rd["PhongBan"],
                            rd["TrangThai"],
                            ((bool)rd["DaDiemDanh"]) ? "Roi" : "Chua",
                            rd["NgayDangKy"], rd["TenSuKien"]);
                    }
                }
            }

            string fileName = "NguoiThamGia_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv";
            Response.Clear();
            Response.ContentType = "text/csv; charset=utf-8";
            Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName);
            Response.BinaryWrite(new byte[] { 0xEF, 0xBB, 0xBF });
            Response.Write(sb.ToString());
            Response.End();
        }

        private void Toast(string msg)
        {
            string safe = msg.Replace("'", "\\'");
            ScriptManager.RegisterStartupScript(this, GetType(), "toast",
                "alert('" + safe + "');", true);
        }

        // ════════════════════════════════════════════════════════════
        // MODEL
        // ════════════════════════════════════════════════════════════

        public class ParticipantRow
        {
            public int DangKyID { get; set; }
            public int MaNguoiDung { get; set; }
            public string HoTen { get; set; }
            public string TenVietTat { get; set; }
            public string Email { get; set; }
            public string PhongBan { get; set; }
            public DateTime NgayDangKy { get; set; }
            public bool DaDiemDanh { get; set; }
            public string TrangThaiText { get; set; }
            public string TrangThaiClass { get; set; }
            public bool CanApprove { get; set; }
            public bool CanReject { get; set; }
            public bool CanCheckin { get; set; }
            public bool EventFull { get; set; }
        }
    }
}