using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace QuanLySuKien
{
    public partial class Admin : System.Web.UI.MasterPage
    {
        private static readonly string ConnStr =
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAdminInfo();
            }
        }

        private void LoadAdminInfo()
        {
            // Lay UserID tu Session
            if (Session["UserID"] == null)
            {
                // Chua login -> redirect
                Response.Redirect("~/Login_Regis.aspx");
                return;
            }

            int userId = Convert.ToInt32(Session["UserID"]);

            const string sql = @"
                SELECT Ho, Ten, ChucVu, VaiTro
                FROM dbo.Users
                WHERE UserID = @id;";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    if (rd.Read())
                    {
                        string ho = rd["Ho"] as string ?? "";
                        string ten = rd["Ten"] as string ?? "";
                        string chucVu = rd["ChucVu"] as string ?? "";
                        string vaiTro = rd["VaiTro"] as string ?? "";

                        // Ten day du
                        string fullName = (ho + " " + ten).Trim();
                        if (string.IsNullOrEmpty(fullName)) fullName = "Admin";
                        lblUserName.Text = fullName;

                        // Avatar = chu cai dau cua Ho + Ten (VIET HOA)
                        string avatar = "";
                        if (!string.IsNullOrEmpty(ho)) avatar += ho.Substring(0, 1).ToUpper();
                        if (!string.IsNullOrEmpty(ten)) avatar += ten.Substring(0, 1).ToUpper();
                        if (string.IsNullOrEmpty(avatar)) avatar = "A";
                        lblUserAvatar.Text = avatar;

                        // Vai tro / Chuc vu
                        string roleText = "";
                        if (vaiTro == "admin")
                            roleText = string.IsNullOrEmpty(chucVu) ? "Admin" : chucVu;
                        else
                            roleText = chucVu ?? "";
                        lblUserRole.Text = roleText;
                    }
                    else
                    {
                        // Session bi loi -> redirect login
                        Session.Clear();
                        Response.Redirect("~/Login_Regis.aspx");
                    }
                }
            }
        }
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();      // Xoa toan bo session keys
            Session.Abandon();    // Huy session
            Response.Redirect("~/Login_Regis.aspx");
        }
        // Goi tu cac trang con de danh dau nav item active
        public void SetActiveNav(string navId)
        {
            var nav = FindControl(navId) as System.Web.UI.HtmlControls.HtmlAnchor;
            if (nav != null) nav.Attributes["class"] = "nav-item active";
        }
    }
}