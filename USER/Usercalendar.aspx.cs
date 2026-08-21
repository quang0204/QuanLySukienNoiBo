using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace QuanLySuKien
{
    public partial class Usercalendar : System.Web.UI.Page
    {
        private static readonly string ConnStr =
            ConfigurationManager.ConnectionStrings["EventHubDB"].ConnectionString;

        private int CurrentUserId =>
            Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int uid) ? uid : 0;

        private DateTime CurrentMonth
        {
            get
            {
                if (Session["UCMonth"] is DateTime d) return d;
                return new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            }
            set { Session["UCMonth"] = value; }
        }

        // Cache su kien cua user trong 1 nam (tu thang -6 den +6)
        private List<MyEvent> _myEvents;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Auth
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login_Regis.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                CurrentMonth = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            }

            LoadMyEvents();
            UpdateHeader();
            RenderCalendarGrid();
            BindSidebar();
        }

        // ════════════════════════════════════════════════════════════
        // LOAD SỰ KIỆN CỦA USER (DangKy + SuKien JOIN)
        // ════════════════════════════════════════════════════════════

        private void LoadMyEvents()
        {
            // Lay tat ca su kien user da dang ky (approved/pending),
            // khong tinh cancelled & rejected
            const string sql = @"
                SELECT
                    s.SuKienID,
                    s.TenSuKien,
                    s.LoaiSuKien,
                    s.NgayBatDau,
                    s.NgayKetThuc,
                    s.GioBatDau,
                    s.GioKetThuc,
                    s.DiaDiem,
                    dk.TrangThai     AS DangKyStatus,
                    dk.DaDiemDanh
                FROM dbo.DangKy dk
                INNER JOIN dbo.SuKien s ON dk.SuKienID = s.SuKienID
                WHERE dk.UserID = @uid
                  AND dk.TrangThai IN ('approved','pending')
                ORDER BY s.NgayBatDau ASC;";

            _myEvents = new List<MyEvent>();
            DateTime today = DateTime.Today;

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@uid", SqlDbType.Int).Value = CurrentUserId;
                conn.Open();
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        DateTime bd = (DateTime)rd["NgayBatDau"];
                        DateTime kt = (rd["NgayKetThuc"] as DateTime?) ?? bd;
                        TimeSpan? gbd = rd["GioBatDau"] as TimeSpan?;
                        TimeSpan? gkt = rd["GioKetThuc"] as TimeSpan?;
                        string dkStatus = rd["DangKyStatus"].ToString();
                        bool daDiemDanh = (bool)rd["DaDiemDanh"];

                        // Trang thai hien thi:
                        //   attended  -> da diem danh
                        //   pending   -> cho duyet
                        //   upcoming  -> sap toi (chua dien ra, da duyet)
                        //   confirmed -> hom nay/dang dien ra
                        string status;
                        if (daDiemDanh) status = "attended";
                        else if (dkStatus == "pending") status = "pending";
                        else if (kt < today) status = "attended"; // da qua, mac du chua DD
                        else if (bd <= today && kt >= today) status = "confirmed";
                        else status = "upcoming";

                        _myEvents.Add(new MyEvent
                        {
                            Id = (int)rd["SuKienID"],
                            Name = rd["TenSuKien"].ToString(),
                            Type = LoaiToType(rd["LoaiSuKien"].ToString()),
                            Start = bd.ToString("yyyy-MM-dd"),
                            End = kt.ToString("yyyy-MM-dd"),
                            Time = FormatTimeRange(gbd, gkt),
                            Loc = rd["DiaDiem"].ToString(),
                            Status = status,
                            ApprovalStatus = dkStatus
                        });
                    }
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // HEADER
        // ════════════════════════════════════════════════════════════

        private void UpdateHeader()
        {
            string[] monthNames = { "Tháng 1","Tháng 2","Tháng 3","Tháng 4","Tháng 5","Tháng 6",
                                    "Tháng 7","Tháng 8","Tháng 9","Tháng 10","Tháng 11","Tháng 12" };
            lblPhMonth.Text = $"{monthNames[CurrentMonth.Month - 1]}, {CurrentMonth.Year} — Lịch của tôi";
        }

        // ════════════════════════════════════════════════════════════
        // RENDER CALENDAR GRID
        // ════════════════════════════════════════════════════════════

        private void RenderCalendarGrid()
        {
            var sb = new StringBuilder();
            int year = CurrentMonth.Year;
            int month = CurrentMonth.Month;
            int firstDow = (int)new DateTime(year, month, 1).DayOfWeek;  // 0 = CN
            int daysInMonth = DateTime.DaysInMonth(year, month);
            int prevDays = month == 1 ? DateTime.DaysInMonth(year - 1, 12) : DateTime.DaysInMonth(year, month - 1);

            var pillCss = new Dictionary<string, string>
            {
                { "tb",       "ep-tb" },
                { "workshop", "ep-workshop" },
                { "training", "ep-training" },
                { "seminar",  "ep-seminar" },
                { "other",    "ep-tb" }
            };

            // Previous month filler
            for (int i = firstDow - 1; i >= 0; i--)
                sb.Append($"<div class=\"cal-cell other-month\"><div class=\"day-num-row\"><div class=\"day-num\">{prevDays - i}</div></div><div class=\"day-pills\"></div></div>");

            for (int d = 1; d <= daysInMonth; d++)
            {
                string dateStr = $"{year:0000}-{month:00}-{d:00}";
                bool isToday = (year == DateTime.Today.Year && month == DateTime.Today.Month && d == DateTime.Today.Day);

                // Events for this day (su kien overlap voi ngay nay)
                var dayEvs = new List<MyEvent>();
                foreach (var ev in _myEvents)
                {
                    if (string.Compare(ev.Start, dateStr) <= 0 && string.Compare(ev.End, dateStr) >= 0)
                        dayEvs.Add(ev);
                }

                string css = "cal-cell" + (isToday ? " today" : "");
                sb.Append($"<div class=\"{css}\">");
                sb.Append($"<div class=\"day-num-row\"><div class=\"day-num\">{d}</div>");
                if (dayEvs.Count > 0)
                    sb.Append($"<div class=\"day-count\">{dayEvs.Count} SK</div>");
                sb.Append("</div><div class=\"day-pills\">");

                int limit = Math.Min(dayEvs.Count, 2);
                for (int i = 0; i < limit; i++)
                {
                    var ev = dayEvs[i];
                    string attended = ev.Status == "attended" ? " ep-attended" : "";
                    string cssClass = pillCss.ContainsKey(ev.Type) ? pillCss[ev.Type] : "ep-tb";
                    sb.Append($"<div class=\"ev-pill {cssClass}{attended}\" onclick=\"location.href='EventDetail.aspx?id={ev.Id}'\">{HttpUtility.HtmlEncode(ev.Name)}</div>");
                }
                if (dayEvs.Count > 2)
                    sb.Append($"<div style=\"font-size:9px;color:var(--gray-400);font-family:var(--mono);padding-top:2px\">+{dayEvs.Count - 2} nữa</div>");

                sb.Append("</div></div>");
            }

            // Next month filler
            int total = firstDow + daysInMonth;
            int remaining = total % 7 == 0 ? 0 : 7 - (total % 7);
            for (int d = 1; d <= remaining; d++)
                sb.Append($"<div class=\"cal-cell other-month\"><div class=\"day-num-row\"><div class=\"day-num\">{d}</div></div><div class=\"day-pills\"></div></div>");

            calGrid.InnerHtml = sb.ToString();
        }

        // ════════════════════════════════════════════════════════════
        // SIDEBAR (sắp tới + đã tham gia)
        // ════════════════════════════════════════════════════════════

        private void BindSidebar()
        {
            string[] monthLabels = { "TH1", "TH2", "TH3", "TH4", "TH5", "TH6", "TH7", "TH8", "TH9", "TH10", "TH11", "TH12" };

            var upcoming = new List<object>();
            var attended = new List<object>();

            foreach (var ev in _myEvents)
            {
                DateTime bd = DateTime.Parse(ev.Start);
                string day = bd.Day.ToString();
                string monthLbl = monthLabels[bd.Month - 1];

                if (ev.Status == "attended")
                {
                    attended.Add(new
                    {
                        Id = ev.Id,
                        Name = ev.Name,
                        Time = ev.Time,
                        Loc = ev.Loc,
                        Day = day,
                        MonthLabel = monthLbl
                    });
                }
                else
                {
                    string badgeCss, badgeLabel;
                    switch (ev.Status)
                    {
                        case "confirmed": badgeCss = "ms-confirmed"; badgeLabel = "DANG DIEN RA"; break;
                        case "pending": badgeCss = "ms-pending"; badgeLabel = "CHO DUYET"; break;
                        default: badgeCss = "ms-upcoming"; badgeLabel = "SAP TOI"; break;
                    }

                    upcoming.Add(new
                    {
                        Id = ev.Id,
                        Name = ev.Name,
                        Time = ev.Time,
                        Loc = ev.Loc,
                        Day = day,
                        MonthLabel = monthLbl,
                        BadgeCss = badgeCss,
                        BadgeLabel = badgeLabel
                    });
                }
            }

            // Sort: upcoming asc, attended desc
            upcoming.Sort((a, b) => {
                var ad = a.GetType().GetProperty("Id").GetValue(a);
                return string.Compare(
                    _myEvents.Find(e => e.Id == (int)ad).Start,
                    _myEvents.Find(e => e.Id == (int)b.GetType().GetProperty("Id").GetValue(b)).Start);
            });

            rptSideUpcoming.DataSource = upcoming;
            rptSideUpcoming.DataBind();
            rptSideAttended.DataSource = attended;
            rptSideAttended.DataBind();

            lblUpcomingCount.Text = upcoming.Count.ToString();
            lblAttendedCount.Text = attended.Count.ToString();
            lblStatTotal.Text = _myEvents.Count.ToString();
            lblStatAttended.Text = attended.Count.ToString();
            lblStatUpcoming.Text = upcoming.Count.ToString();
        }

        // ════════════════════════════════════════════════════════════
        // NAVIGATION BUTTONS
        // ════════════════════════════════════════════════════════════

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            CurrentMonth = CurrentMonth.AddMonths(-1);
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            CurrentMonth = CurrentMonth.AddMonths(1);
        }

        protected void btnToday_Click(object sender, EventArgs e)
        {
            CurrentMonth = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
        }

        protected void btnCancelEvent_Command(object sender, CommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int eventId)) return;
            try
            {
                if (!IsCancelAllowed(eventId))
                {
                    ShowToast("Su kien nay khong cho phep huy dang ky.");
                    return;
                }
                CancelRegistration(eventId);
                ShowToast("Da huy dang ky!");
                LoadMyEvents();
                RenderCalendarGrid();
                BindSidebar();
            }
            catch (Exception ex)
            {
                ShowToast("Loi: " + ex.Message);
            }
        }

        /// <summary>Check su kien co cho phep huy DK khong</summary>
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

        // ════════════════════════════════════════════════════════════
        // CANCEL REGISTRATION
        // ════════════════════════════════════════════════════════════

        private void CancelRegistration(int suKienID)
        {
            const string sql = @"
                UPDATE dbo.DangKy
                   SET TrangThai = 'cancelled', NgayCapNhat = GETDATE()
                 WHERE UserID = @u AND SuKienID = @s
                   AND TrangThai IN ('approved','pending');";

            using (var conn = new SqlConnection(ConnStr))
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.Add("@u", SqlDbType.Int).Value = CurrentUserId;
                cmd.Parameters.Add("@s", SqlDbType.Int).Value = suKienID;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ════════════════════════════════════════════════════════════
        // HELPERS
        // ════════════════════════════════════════════════════════════

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

        private static string FormatTimeRange(TimeSpan? bd, TimeSpan? kt)
        {
            if (!bd.HasValue) return "Ca ngay";
            string s = bd.Value.ToString(@"hh\:mm");
            if (kt.HasValue) s += " - " + kt.Value.ToString(@"hh\:mm");
            return s;
        }

        private void ShowToast(string msg)
        {
            string safe = msg.Replace("'", "\\'");
            string js = $"if(window.showToast)showToast('{safe}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "toast", js, true);
        }

        // ════════════════════════════════════════════════════════════
        // MODEL
        // ════════════════════════════════════════════════════════════

        public class MyEvent
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public string Type { get; set; }
            public string Start { get; set; }   // yyyy-MM-dd
            public string End { get; set; }     // yyyy-MM-dd
            public string Time { get; set; }
            public string Loc { get; set; }
            public string Status { get; set; }           // upcoming / confirmed / attended / pending
            public string ApprovalStatus { get; set; }   // approved / pending
        }
    }
}