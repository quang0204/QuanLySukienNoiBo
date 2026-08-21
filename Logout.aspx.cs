using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Quản_Lý_Sự_Kiện
{
    public partial class Logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Xoá toàn bộ session
            Session.Clear();
            Session.Abandon();

            // Xoá cookie session
            if (Request.Cookies["ASP.NET_SessionId"] != null)
            {
                Response.Cookies["ASP.NET_SessionId"].Value = "";
                Response.Cookies["ASP.NET_SessionId"].Expires = DateTime.Now.AddDays(-1);
            }

            // Quay về trang Login
            Response.Redirect("~/Login_Regis.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}