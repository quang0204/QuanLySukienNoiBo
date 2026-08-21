using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;

namespace QuanLySuKien
{
    public partial class CaptchaList : System.Web.UI.Page
    {
        // Regex: DUNG 3 chu HOA + DUNG 2 chu so + ket thuc @
        private static readonly Regex CaptchaRegex =
            new Regex(@"^(?=(?:[^A-Z]*[A-Z]){3}[^A-Z]*$)(?=(?:[^0-9]*[0-9]){2}[^0-9]*$)[A-Z0-9]{5}@$");

        // Danh sach ma luu trong Session (theo tung user)
        // Cach 1: dung Session -> moi user co list rieng
        // Cach 2: dung Application -> tat ca user dung chung (khong dung trong vi du nay)
        private const string SESSION_KEY = "CaptchaList";

        private List<string> CodeList
        {
            get
            {
                if (Session[SESSION_KEY] == null)
                    Session[SESSION_KEY] = new List<string>();
                return (List<string>)Session[SESSION_KEY];
            }
            set { Session[SESSION_KEY] = value; }
        }

        // ════════════════════════════════════════════════════════════
        // PAGE LIFECYCLE
        // ════════════════════════════════════════════════════════════

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindList();
            }
        }

        // ════════════════════════════════════════════════════════════
        // THEM MA VAO DANH SACH
        // ════════════════════════════════════════════════════════════

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;  // Validator chan neu sai

            string code = (txtMa.Text ?? "").Trim().ToUpper();

            // Double check format o server (chong client tat JS)
            if (!CaptchaRegex.IsMatch(code))
            {
                ShowError("Ma sai format! Vui long kiem tra lai.");
                return;
            }

            // Lay list hien tai
            var list = CodeList;

            // (Optional) Khong cho them trung lap
            if (list.Contains(code))
            {
                ShowError("Ma '" + code + "' da co trong danh sach!");
                return;
            }

            // Them vao list
            list.Add(code);
            CodeList = list;  // luu lai Session

            ShowSuccess("Da them ma '" + code + "' vao danh sach!");
            txtMa.Text = "";  // clear input
            BindList();
        }

        // ════════════════════════════════════════════════════════════
        // CLICK 1 MUC -> AN MUC DO
        // ════════════════════════════════════════════════════════════

        protected void rptList_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "HideItem") return;

            if (!int.TryParse(e.CommandArgument?.ToString(), out int index)) return;

            var list = CodeList;
            if (index < 0 || index >= list.Count) return;

            string removed = list[index];
            list.RemoveAt(index);
            CodeList = list;

            ShowSuccess("Da an ma '" + removed + "' khoi danh sach!");
            BindList();
        }

        // ════════════════════════════════════════════════════════════
        // XOA TAT CA
        // ════════════════════════════════════════════════════════════

        protected void btnClearAll_Click(object sender, EventArgs e)
        {
            CodeList = new List<string>();
            ShowSuccess("Da xoa toan bo danh sach!");
            BindList();
        }

        // ════════════════════════════════════════════════════════════
        // BIND DANH SACH LEN REPEATER
        // ════════════════════════════════════════════════════════════

        private void BindList()
        {
            var list = CodeList;
            lblCount.Text = list.Count.ToString();

            if (list.Count == 0)
            {
                rptList.Visible = false;
                phEmpty.Visible = true;
            }
            else
            {
                rptList.Visible = true;
                phEmpty.Visible = false;
                rptList.DataSource = list;
                rptList.DataBind();
            }
        }

        // ════════════════════════════════════════════════════════════
        // HELPERS - HIEN THONG BAO
        // ════════════════════════════════════════════════════════════

        private void ShowError(string msg)
        {
            pnlSuccess.Visible = false;
            pnlError.Visible = true;
            lblError.Text = msg;
        }

        private void ShowSuccess(string msg)
        {
            pnlError.Visible = false;
            pnlSuccess.Visible = true;
            lblSuccess.Text = msg;
        }
    }
}