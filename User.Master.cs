using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace QuanLySuKien
{
    public partial class User : System.Web.UI.MasterPage
    {
        private static readonly string ConnStr =
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        private int CurrentUserId =>
            Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int uid) ? uid : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                // Chua login -> redirect
                Response.Redirect("~/Login_Regis.aspx");
                return;
            }
            // ════════════════════════════════════════════════════════════
            // 1. THONG TIN USER (goc phai)
            // ════════════════════════════════════════════════════════════
            LoadCurrentUserInfo();

            // ════════════════════════════════════════════════════════════
            // 2. THONG BAO (badge + panel)
            // ════════════════════════════════════════════════════════════
            LoadNotifications();

            // ════════════════════════════════════════════════════════════
            // 3. HIGHLIGHT MENU
            // ════════════════════════════════════════════════════════════
            string currentPage = System.IO.Path.GetFileNameWithoutExtension(Request.PhysicalPath).ToLower();
            lnkHome.CssClass = (currentPage == "default" || currentPage == "usertrangchu") ? "nav-link active" : "nav-link";
            lnkEvents.CssClass = currentPage == "events" ? "nav-link active" : "nav-link";
            lnkCalendar.CssClass = (currentPage == "calendar" || currentPage == "usercalendar") ? "nav-link active" : "nav-link";
            lnkProfile.CssClass = currentPage == "userprofile" ? "nav-link active" : "nav-link";
        }

        // ════════════════════════════════════════════════════════════
        // USER INFO
        // ════════════════════════════════════════════════════════════

        private void LoadCurrentUserInfo()
        {
            if (CurrentUserId <= 0)
            {
                lblUserName.Text = "";
                lblUserInitials.Text = "";
                return;
            }

            const string sql = "SELECT Ho, Ten FROM dbo.Users WHERE UserID = @id;";
            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@id", SqlDbType.Int).Value = CurrentUserId;
                    conn.Open();
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (rd.Read())
                        {
                            string ho = rd["Ho"] as string ?? "";
                            string ten = rd["Ten"] as string ?? "";
                            string fullName = (ho + " " + ten).Trim();
                            if (string.IsNullOrEmpty(fullName)) fullName = "User #" + CurrentUserId;

                            string a = !string.IsNullOrEmpty(ho) ? ho.Substring(0, 1) : "";
                            string b = !string.IsNullOrEmpty(ten) ? ten.Substring(0, 1) : "U";
                            string initials = (a + b).ToUpper();

                            lblUserName.Text = fullName;
                            lblUserInitials.Text = initials;
                        }
                    }
                }
            }
            catch
            {
                lblUserName.Text = "";
                lblUserInitials.Text = "";
            }
        }

        // ════════════════════════════════════════════════════════════
        // NOTIFICATIONS
        // ════════════════════════════════════════════════════════════

        private void LoadNotifications()
        {
            if (CurrentUserId <= 0)
            {
                pnlNotifBadge.Visible = false;
                phDefaultNotifs.Visible = true;
                return;
            }

            // Lay 20 thong bao gan nhat + dem so chua doc
            const string sql = @"
                SELECT TOP 20
                    ThongBaoID, TieuDe, NoiDung, LoaiThongBao,
                    NgayTao, DaDoc, LienKet
                FROM dbo.ThongBao
                WHERE UserID = @uid
                ORDER BY NgayTao DESC;";

            var list = new List<NotifItem>();
            int unreadCount = 0;
            DateTime now = DateTime.Now;

            try
            {
                using (var conn = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@uid", SqlDbType.Int).Value = CurrentUserId;
                    conn.Open();
                    using (var rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            bool daDoc = (bool)rd["DaDoc"];
                            if (!daDoc) unreadCount++;

                            DateTime ngay = (DateTime)rd["NgayTao"];
                            list.Add(new NotifItem
                            {
                                Id = (int)rd["ThongBaoID"],
                                Title = rd["TieuDe"].ToString(),
                                Content = TruncateText(rd["NoiDung"].ToString(), 120),
                                IsUnread = !daDoc,
                                TimeLabel = FormatTimeAgo(now - ngay, ngay)
                            });
                        }
                    }
                }
            }
            catch
            {
                // Loi DB - an badge
                pnlNotifBadge.Visible = false;
                phDefaultNotifs.Visible = true;
                return;
            }

            // Badge
            if (unreadCount > 0)
            {
                pnlNotifBadge.Visible = true;
                lblNotifBadge.Text = unreadCount > 99 ? "99+" : unreadCount.ToString();
            }
            else
            {
                pnlNotifBadge.Visible = false;
            }

            // Repeater
            if (list.Count == 0)
            {
                phDefaultNotifs.Visible = true; // empty state
            }
            else
            {
                phDefaultNotifs.Visible = false;
                rptNotifications.DataSource = list;
                rptNotifications.DataBind();
            }
        }

        // ════════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════════

        /// <summary>Format thoi gian relative: "10 phut truoc" / "2 gio truoc" / "Hom qua" / "15/04"</summary>
        private static string FormatTimeAgo(TimeSpan diff, DateTime ngay)
        {
            if (diff.TotalMinutes < 1) return "Vua xong";
            if (diff.TotalMinutes < 60) return (int)diff.TotalMinutes + " phut truoc";
            if (diff.TotalHours < 24) return (int)diff.TotalHours + " gio truoc";
            if (diff.TotalDays < 2) return "Hom qua";
            if (diff.TotalDays < 7) return (int)diff.TotalDays + " ngay truoc";
            return ngay.ToString("dd/MM/yyyy");
        }

        private static string TruncateText(string s, int max)
        {
            if (string.IsNullOrEmpty(s)) return "";
            return s.Length <= max ? s : s.Substring(0, max) + "...";
        }

        // ════════════════════════════════════════════════════════════
        // MODEL
        // ════════════════════════════════════════════════════════════

        public class NotifItem
        {
            public int Id { get; set; }
            public string Title { get; set; }
            public string Content { get; set; }
            public bool IsUnread { get; set; }
            public string TimeLabel { get; set; }
        }
    }
}