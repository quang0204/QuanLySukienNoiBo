<%@ Page Title="" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Usercalendar.aspx.cs" Inherits="QuanLySuKien.Usercalendar" %>

<asp:Content ID="cHeadStyles" ContentPlaceHolderID="HeadStyles" runat="server">
    <link href="<%= ResolveUrl("~/Styles/Usercalendar.css") %>" rel="stylesheet" type="text/css" />
</asp:Content>

<%-- No hero band for user calendar — use compact page-header instead --%>
<asp:Content ID="cHero" ContentPlaceHolderID="HeroBand" runat="server">
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Page Header (compact, sticky) -->
    <div class="page-header">
        <div class="ph-left">
            <asp:LinkButton ID="btnPrev" runat="server" CssClass="ph-nav-btn" OnClick="btnPrev_Click"></asp:LinkButton>
            <div class="ph-month">
                <asp:Label ID="lblPhMonth" runat="server" Text="Lịch của tôi" />
            </div>
            <asp:LinkButton ID="btnNext" runat="server" CssClass="ph-nav-btn" OnClick="btnNext_Click"></asp:LinkButton>
            <asp:LinkButton ID="btnToday" runat="server" CssClass="today-btn" OnClick="btnToday_Click">HÔM NAY</asp:LinkButton>
        </div>
        <div class="ph-right">
            <div class="legend">
                <div class="leg-item">
                    <div class="leg-dot" style="background: #000"></div>
                    Team Building</div>
                <div class="leg-item">
                    <div class="leg-dot" style="background: #3b82f6"></div>
                    Workshop</div>
                <div class="leg-item">
                    <div class="leg-dot" style="background: #10b981"></div>
                    Đào tạo</div>
                <div class="leg-item">
                    <div class="leg-dot" style="background: #f59e0b"></div>
                    Hội thảo</div>
            </div>
            <div class="view-toggle">
                <button type="button" class="vt-btn active" onclick="switchView('month',this)">THÁNG</button>
                <button type="button" class="vt-btn" onclick="switchView('week',this)">TUẦN</button>
            </div>
        </div>
    </div>

    <!-- Body: calendar + sidebar -->
    <div class="body-wrap">

        <!-- Month View -->
        <div class="month-view" id="monthView">
            <div class="cal-weekdays">
                <div class="cal-wd">Chủ nhật</div>
                <div class="cal-wd">Thứ hai</div>
                <div class="cal-wd">Thứ ba</div>
                <div class="cal-wd">Thứ tư</div>
                <div class="cal-wd">Thứ năm</div>
                <div class="cal-wd">Thứ sáu</div>
                <div class="cal-wd">Thứ bảy</div>
            </div>
            <div class="cal-grid" id="calGrid" runat="server">
                <%-- Rendered server-side --%>
            </div>
        </div>

        <!-- Sidebar -->
        <div class="cal-sidebar">
            <div class="sidebar-tabs">
                <button type="button" class="st active" onclick="setSidebarTab(this,'events')">Sự kiện</button>
                <button type="button" class="st" onclick="setSidebarTab(this,'stats')">Thống kê</button>
            </div>
            <div class="sidebar-body" id="sidebarBodyEl">

                <!-- Events tab (default) -->
                <div id="tab-events">
                    <div class="sidebar-section-label">SẮP TỚI (<asp:Label ID="lblUpcomingCount" runat="server" Text="0" />)</div>
                    <asp:Repeater ID="rptSideUpcoming" runat="server">
                        <ItemTemplate>
                            <div class="my-ev-item" onclick="location.href='EventDetail.aspx?id=<%# Eval("Id") %>'">
                                <div class="mei-top">
                                    <div class="mei-date">
                                        <div class="mei-dd"><%# Eval("Day") %></div>
                                        <div class="mei-mm"><%# Eval("MonthLabel") %></div>
                                    </div>
                                    <div class="mei-info">
                                        <div class="mei-name"><%# Eval("Name") %></div>
                                        <div class="mei-time"> <%# Eval("Time") %></div>
                                        <div class="mei-loc"><%# Eval("Loc") %></div>
                                    </div>
                                    <div class="mei-status">
                                        <span class="ms-badge <%# Eval("BadgeCss") %>"><%# Eval("BadgeLabel") %></span>
                                    </div>
                                </div>
                                <div class="mei-footer">
                                    <a class="btn-detail-ev" href="EventDetail.aspx?id=<%# Eval("Id") %>">Chi tiết</a>
                                    <asp:LinkButton ID="btnCancelItem" runat="server" CssClass="btn-cancel-ev"
                                        CommandArgument='<%# Eval("Id") %>'
                                        OnCommand="btnCancelEvent_Command"
                                        OnClientClick="return confirm('Hủy đăng ký sự kiện này?');">Hủy ĐK</asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <div class="sidebar-section-label">ĐÃ THAM DỰ (<asp:Label ID="lblAttendedCount" runat="server" Text="0" />)</div>
                    <asp:Repeater ID="rptSideAttended" runat="server">
                        <ItemTemplate>
                            <div class="my-ev-item" onclick="location.href='EventDetail.aspx?id=<%# Eval("Id") %>'">
                                <div class="mei-top">
                                    <div class="mei-date" style="background: var(--gray-400)">
                                        <div class="mei-dd"><%# Eval("Day") %></div>
                                        <div class="mei-mm"><%# Eval("MonthLabel") %></div>
                                    </div>
                                    <div class="mei-info">
                                        <div class="mei-name"><%# Eval("Name") %></div>
                                        <div class="mei-time"> <%# Eval("Time") %></div>
                                        <div class="mei-loc"><%# Eval("Loc") %></div>
                                    </div>
                                    <div class="mei-status">
                                        <span class="ms-badge ms-attended">ĐÃ DỰ</span>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <!-- Stats tab (hidden by default, shown via JS) -->
                <div id="tab-stats" style="display: none">
                    <div class="sidebar-stats">
                        <div class="ss-row">
                            <div>
                                <div class="ss-val">
                                    <asp:Label ID="lblStatTotal" runat="server" Text="5" /></div>
                                <div class="ss-lbl">Đã đăng ký</div>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: 100%"></div>
                                </div>
                            </div>
                        </div>
                        <div class="ss-row">
                            <div>
                                <div class="ss-val">
                                    <asp:Label ID="lblStatAttended" runat="server" Text="3" /></div>
                                <div class="ss-lbl">Đã tham dự</div>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: 60%"></div>
                                </div>
                            </div>
                        </div>
                        <div class="ss-row">
                            <div>
                                <div class="ss-val">
                                    <asp:Label ID="lblStatUpcoming" runat="server" Text="2" /></div>
                                <div class="ss-lbl">Sắp tới</div>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: 40%"></div>
                                </div>
                            </div>
                        </div>
                        <div class="ss-row">
                            <div>
                                <div class="ss-val">4.8</div>
                                <div class="ss-lbl">Điểm đánh giá TB</div>
                                <div class="progress-bar">
                                    <div class="progress-fill" style="width: 96%"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Cancel Confirm Modal -->
    <div class="modal-overlay" id="cancelModal">
        <div class="modal">
            <div class="modal-header">
                <h3>Hủy đăng ký sự kiện</h3>
                <button type="button" class="modal-close" onclick="document.getElementById('cancelModal').classList.remove('open')"></button>
            </div>
            <div class="modal-body">
                Bạn có chắc muốn hủy đăng ký? Chỗ của bạn sẽ được nhường cho người khác.
       
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-outline-m" onclick="document.getElementById('cancelModal').classList.remove('open')">Giữ lại</button>
                <button type="button" class="btn-danger-m" onclick="document.getElementById('cancelModal').classList.remove('open');showToast('Đã hủy đăng ký thành công!')">Xác nhận hủy</button>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="PageScripts" runat="server">
    <script>
        var __isWeekView = false;

        function switchView(view, btn) {
            document.querySelectorAll('.vt-btn').forEach(function (b) { b.classList.remove('active'); });
            if (btn) btn.classList.add('active');

            var grid = document.getElementById('calGrid');
            if (!grid) return;

            if (view === 'week') {
                __isWeekView = true;
                showWeekView();
            } else {
                __isWeekView = false;
                showMonthView();
            }
        }

        function showMonthView() {
            var cells = document.querySelectorAll('#calGrid .cal-cell');
            cells.forEach(function (c) { c.style.display = ''; });
        }

        function showWeekView() {
            // Tim ngay HIEN TAI trong calGrid (cell co class "today")
            // Neu khong co (tháng đang xem khác tháng hiện tại) -> lay tuần đầu tháng có chứa ngày
            var cells = document.querySelectorAll('#calGrid .cal-cell');
            if (cells.length === 0) return;

            // Lay index của cell hôm nay
            var todayIdx = -1;
            cells.forEach(function (c, i) {
                if (c.classList.contains('today')) todayIdx = i;
            });

            // Neu khong co today (vd dang xem thang khac), lay tuan dau cua thang
            if (todayIdx === -1) {
                // Tim cell dau tien KHONG phai 'other-month'
                for (var i = 0; i < cells.length; i++) {
                    if (!cells[i].classList.contains('other-month')) {
                        todayIdx = i;
                        break;
                    }
                }
            }

            if (todayIdx === -1) return;

            // Tinh hang chua todayIdx (moi hang 7 cells)
            var rowStart = Math.floor(todayIdx / 7) * 7;
            var rowEnd = rowStart + 7;

            cells.forEach(function (c, i) {
                c.style.display = (i >= rowStart && i < rowEnd) ? '' : 'none';
            });
        }

        function setSidebarTab(el, tab) {
            document.querySelectorAll('.st').forEach(function (t) { t.classList.remove('active'); });
            if (el) el.classList.add('active');
            var evtab = document.getElementById('tab-events');
            var sttab = document.getElementById('tab-stats');
            if (evtab) evtab.style.display = tab === 'events' ? 'block' : 'none';
            if (sttab) sttab.style.display = tab === 'stats' ? 'block' : 'none';
        }

        // Khoi tao: dam bao mac dinh la month view + tab events
        window.addEventListener('DOMContentLoaded', function () {
            showMonthView();
            var evtab = document.getElementById('tab-events');
            var sttab = document.getElementById('tab-stats');
            if (evtab) evtab.style.display = 'block';
            if (sttab) sttab.style.display = 'none';
        });
</script>
</asp:Content>
