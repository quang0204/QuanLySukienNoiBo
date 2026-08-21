using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace QuanLySuKien
{
    public partial class AdminCalendar : System.Web.UI.Page
    {
        private static readonly string ConnStr =
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        public string EventsJson { get; private set; } = "[]";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login_Regis.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            // Luon load events (sau khi delete tu btnDoDelete_Click thi LoadEvents se chay lai)
            LoadEvents();
        }

        // ════════════════════════════════════════════════════════════
        // BUTTON HANDLER - XOA
        // ════════════════════════════════════════════════════════════

        protected void btnDoDelete_Click(object sender, EventArgs e)
        {
            string idStr = hfDeleteId.Value;
            if (!int.TryParse(idStr, out int delId) || delId <= 0)
            {
                ShowToast("ID khong hop le: " + idStr);
                return;
            }

            string ten = GetEventName(delId);
            try
            {
                int affected = DeleteEvent(delId);
                if (affected > 0)
                {
                    ShowToast("Da xoa: " + ten);
                }
                else
                {
                    ShowToast("Khong xoa duoc. Su kien khong ton tai.");
                }
            }
            catch (Exception ex)
            {
                ShowToast("Loi xoa: " + ex.Message);
            }

            // Reload events sau khi xoa
            LoadEvents();
            hfDeleteId.Value = "";
        }

        // ════════════════════════════════════════════════════════════
        // LOAD EVENTS -> JSON
        // ════════════════════════════════════════════════════════════

        private void LoadEvents()
        {
            const string sql = @"
                SELECT
                    s.SuKienID, s.TenSuKien, s.LoaiSuKien,
                    s.NgayBatDau, s.NgayKetThuc,
                    s.GioBatDau, s.GioKetThuc,
                    s.DiaDiem, s.SucChua,
                    dbo.fn_TinhTrangThai(
                        s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                        s.SucChua, ISNULL(d.SoDuyet, 0),
                        s.GioBatDau, s.GioKetThuc
                    ) AS TrangThai,
                    ISNULL(d.SoDangKy, 0) AS SoDangKy,
                    ISNULL(d.SoDuyet,  0) AS SoDuyet
                FROM dbo.SuKien s
                LEFT JOIN (
                    SELECT SuKienID,
                           COUNT(*) AS SoDangKy,
                           SUM(CASE WHEN TrangThai = 'approved' THEN 1 ELSE 0 END) AS SoDuyet
                    FROM dbo.DangKy
                    WHERE TrangThai IN ('approved','pending')
                    GROUP BY SuKienID
                ) d ON s.SuKienID = d.SuKienID
                ORDER BY s.NgayBatDau ASC;";

            var sb = new StringBuilder("[");
            bool first = true;

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
                        DateTime bd = (DateTime)rd["NgayBatDau"];
                        DateTime kt = rd["NgayKetThuc"] as DateTime? ?? bd;
                        TimeSpan? gbd = rd["GioBatDau"] as TimeSpan?;
                        TimeSpan? gkt = rd["GioKetThuc"] as TimeSpan?;
                        string diaDiem = rd["DiaDiem"].ToString();
                        int sucChua = (int)rd["SucChua"];
                        string trangThai = rd["TrangThai"].ToString();
                        int soDangKy = (int)rd["SoDangKy"];
                        int soDuyet  = (int)rd["SoDuyet"];

                        string type = LoaiToType(loai);
                        string time = FormatTime(gbd, gkt);

                        sb.Append("{");
                        sb.Append($"\"id\":{id},");
                        sb.Append($"\"name\":\"{JsEscape(name)}\",");
                        sb.Append($"\"emoji\":\"\",");
                        sb.Append($"\"type\":\"{type}\",");
                        sb.Append($"\"start\":\"{bd:yyyy-MM-dd}\",");
                        sb.Append($"\"end\":\"{kt:yyyy-MM-dd}\",");
                        sb.Append($"\"time\":\"{JsEscape(time)}\",");
                        sb.Append($"\"loc\":\"{JsEscape(diaDiem)}\",");
                        sb.Append($"\"slots\":{sucChua},");
                        sb.Append($"\"taken\":{soDuyet},");
                        sb.Append($"\"registered\":{soDangKy},");
                        sb.Append($"\"status\":\"{trangThai}\"");
                        sb.Append("}");
                    }
                }
            }
            sb.Append("]");
            EventsJson = sb.ToString();
        }

        // ════════════════════════════════════════════════════════════
        // DELETE EVENT - tra ve so dong bi xoa
        // ════════════════════════════════════════════════════════════

        private int DeleteEvent(int suKienID)
        {
            int affected = 0;
            using (var conn = new SqlConnection(ConnStr))
            {
                conn.Open();
                using (var tran = conn.BeginTransaction())
                {
                    try
                    {
                        ExecNonQuery(conn, tran, "DELETE FROM dbo.Feedback    WHERE SuKienID = @id;", suKienID);
                        ExecNonQuery(conn, tran, "DELETE FROM dbo.DanhSachCho WHERE SuKienID = @id;", suKienID);
                        ExecNonQuery(conn, tran, "DELETE FROM dbo.ThongBao    WHERE SuKienID = @id;", suKienID);
                        ExecNonQuery(conn, tran, "DELETE FROM dbo.DangKy      WHERE SuKienID = @id;", suKienID);
                        affected = ExecNonQuery(conn, tran, "DELETE FROM dbo.SuKien WHERE SuKienID = @id;", suKienID);
                        tran.Commit();
                    }
                    catch { tran.Rollback(); throw; }
                }
            }
            return affected;
        }

        private int ExecNonQuery(SqlConnection conn, SqlTransaction tran, string sql, int id)
        {
            using (var cmd = new SqlCommand(sql, conn, tran))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;
                return cmd.ExecuteNonQuery();
            }
        }

        // ════════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════════

        private string GetEventName(int id)
        {
            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand("SELECT TenSuKien FROM dbo.SuKien WHERE SuKienID = @id;", conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;
                conn.Open();
                var v = cmd.ExecuteScalar();
                return v == null ? ("ID " + id) : v.ToString();
            }
        }

        private void ShowToast(string msg)
        {
            string safe = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            ClientScript.RegisterStartupScript(GetType(), "calToast",
                "<script>if(window.showCalToast)showCalToast('" + safe + "');else alert('" + safe + "');</script>");
        }

        private static string LoaiToType(string loai)
        {
            switch ((loai ?? "").Trim())
            {
                case "Team Building": return "tb";
                case "Workshop":      return "workshop";
                case "Dao tao":       return "training";
                case "Hoi thao":      return "seminar";
                default:              return "workshop";
            }
        }

        private static string FormatTime(TimeSpan? gbd, TimeSpan? gkt)
        {
            if (!gbd.HasValue && !gkt.HasValue) return "";
            string s = "";
            if (gbd.HasValue) s += gbd.Value.ToString(@"hh\:mm");
            else s += "??:??";
            s += "\u2013";
            if (gkt.HasValue) s += gkt.Value.ToString(@"hh\:mm");
            else s += "??:??";
            return s;
        }

        private static string JsEscape(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Replace("\\", "\\\\")
                    .Replace("\"", "\\\"")
                    .Replace("\r", "\\r")
                    .Replace("\n", "\\n")
                    .Replace("\t", "\\t");
        }
    }
}