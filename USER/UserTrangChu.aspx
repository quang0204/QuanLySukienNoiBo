<%@ Page Title="" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="UserTrangChu.aspx.cs" Inherits="QuanLySuKien.UserTrangChu" %>

<%-- ═══ Page-specific CSS ═══ --%>
<asp:Content ID="cHeadStyles" ContentPlaceHolderID="HeadStyles" runat="server">
    <style>
        /* ── Hero band layout ── */
        .hero-greeting {
            flex: 1
        }

        .greeting-time {
            font-size: 11px;
            font-family: var(--mono);
            color: rgba(255,255,255,.35);
            letter-spacing: 1.5px;
            text-transform: uppercase;
            margin-bottom: 8px
        }

        .greeting-name {
            font-size: 36px;
            font-weight: 900;
            letter-spacing: -1.5px;
            margin-bottom: 6px
        }

        .greeting-role {
            font-size: 14px;
            color: rgba(255,255,255,.5)
        }

        .hero-quick-stats {
            display: flex;
            gap: 0;
            border-left: 1px solid rgba(255,255,255,.1);
            flex-shrink: 0
        }

        .hqs-item {
            padding: 0 32px;
            border-right: 1px solid rgba(255,255,255,.1);
            text-align: center
        }

        .hqs-num {
            font-size: 28px;
            font-weight: 900;
            letter-spacing: -1px
        }

        .hqs-lbl {
            font-size: 10px;
            font-family: var(--mono);
            color: rgba(255,255,255,.35);
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-top: 3px
        }

        .hero-cta {
            flex-shrink: 0
        }

        /* ── Page layout ── */
        .page-body {
            max-width: 1400px;
            margin: 0 auto;
            padding: 32px 48px;
            display: grid;
            grid-template-columns: 1fr 340px;
            gap: 28px
        }

        .main-col {
            display: flex;
            flex-direction: column;
            gap: 28px
        }

        .side-col {
            display: flex;
            flex-direction: column;
            gap: 20px
        }

        /* ── Events grid ── */
        .events-grid-user {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px
        }

        .news-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px
        }
        /* Status badge cho ended & ongoing */
        .s-ended {
            background: #737373 !important;
            color: #fff !important
        }

        .s-ongoing {
            background: #fff5e6 !important;
            color: #cc7700 !important
        }
    </style>
</asp:Content>

<%-- ═══ Announce Band ═══ --%>
<asp:Content ID="cAnnounce" ContentPlaceHolderID="AnnounceBand" runat="server">
    <asp:Panel ID="pnlAnnounce" runat="server" CssClass="announce-band" ClientIDMode="Static">
        <span class="announce-tag">MỚI</span>
        <span class="announce-text">
            <asp:Label ID="lblAnnounceText" runat="server" />
            <asp:HyperLink ID="lnkAnnounce" runat="server" Text="Xem ngay →"
                Style="color: #fff; border-bottom: 1px solid rgba(255,255,255,.4); margin-left: 8px" />
        </span>
        <button type="button" class="announce-close" onclick="closeAnnounce()">X</button>
    </asp:Panel>
</asp:Content>

<%-- ═══ Hero Band ═══ --%>
<asp:Content ID="cHero" ContentPlaceHolderID="HeroBand" runat="server">
    <div class="hero-band">
        <div class="hero-band-inner">
            <div class="hero-greeting">
                <div class="greeting-time" id="timeGreet">Đang tải...</div>
                <div class="greeting-name">
                    Xin chào,
                    <asp:Label ID="lblHeroName" runat="server" Text="Văn An" />
                </div>
                <div class="greeting-role">
                    <asp:Label ID="lblHeroRole" runat="server" Text="Software Engineer · Phòng Engineering · HCM Office" />
                </div>
            </div>

            <div class="hero-quick-stats">
                <div class="hqs-item">
                    <div class="hqs-num">
                        <asp:Label ID="lblStatRegistered" runat="server" Text="2" /></div>
                    <div class="hqs-lbl">Sự kiện đã đăng ký</div>
                </div>
                <div class="hqs-item">
                    <div class="hqs-num">
                        <asp:Label ID="lblStatAttended" runat="server" Text="12" /></div>
                    <div class="hqs-lbl">Đã tham dự</div>
                </div>
                <div class="hqs-item">
                    <div class="hqs-num">
                        <asp:Label ID="lblStatRating" runat="server" Text="4.8*" /></div>
                    <div class="hqs-lbl">Điểm đánh giá</div>
                </div>
            </div>

            <div class="hero-cta">
                <a class="btn-hero" href="Events.aspx">Khám phá sự kiện →</a>
                <a class="btn-hero outline" href="Calendar.aspx">Xem lịch</a>
            </div>
        </div>
    </div>
</asp:Content>

<%-- ═══ Main Content ═══ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-body">

        <!-- ─── MAIN COLUMN ─── -->
        <div class="main-col">

            <!-- Upcoming Events -->
            <div>
                <div class="section-hd">
                    <div class="section-hd-left">
                        <div class="section-hd-label">Sắp diễn ra</div>
                        <div class="section-hd-title">Sự kiện dành cho bạn</div>
                    </div>
                    <a class="section-hd-link" href="Events.aspx">Xem tất cả sự kiện →</a>
                </div>
                <div class="events-grid-user">
                    <asp:Repeater ID="rptHomeEvents" runat="server">
                        <ItemTemplate>
                            <div class="ecard" onclick="location.href='EventDetail.aspx?id=<%# Eval("Id") %>'">
                                <div class="ecard-img" style='<%# string.IsNullOrEmpty(Eval("AnhBia") as string) ? "": "background-image:url(" + ResolveUrl(Eval("AnhBia").ToString()) + ");background-size:cover;background-position:center" %>'>
                                    <div class="ecard-tags">
                                        <span class="ecard-tag"><%# Eval("Tag") %></span>
                                        <%# (bool)Eval("IsMine") ? "<span class=\"ecard-tag\" style=\"background:#000;color:#fff\">Của tôi</span>" : "" %>
                                    </div>
                                    <span class="ecard-status <%# Eval("StatusCss") %>"><%# Eval("StatusLabel") %></span>
                                </div>
                                <div class="ecard-body">
                                    <div class="ecard-title"><%# Eval("Name") %></div>
                                    <div class="ecard-meta">
                                        <div class="ecard-meta-row"><%# Eval("Date") %></div>
                                        <div class="ecard-meta-row"><%# Eval("Location") %></div>
                                    </div>
                                    <div class="ecard-foot">
                                        <div>
                                            <div class="ecard-slots"><%# Eval("Taken") %>/<%# Eval("Slots") %> đăng ký</div>
                                            <div class="slots-bar">
                                                <div class="slots-fill <%# Eval("FillCss") %>"
                                                    style="width: <%# Eval("FillPct") %>%">
                                                </div>
                                            </div>
                                        </div>
                                        <asp:LinkButton ID="btnRegister" runat="server"
                                            CssClass='<%# Eval("StatusCss").ToString() == "s-ended" ? "btn-reg disabled" : (bool)Eval("IsExpired") && !(bool)Eval("IsMine") ? "btn-reg disabled" : (bool)Eval("IsFull") && !(bool)Eval("IsMine") ? "btn-reg disabled" : (bool)Eval("IsMine") && !(bool)Eval("CanCancel") ? "btn-cancel-sm disabled" : (bool)Eval("IsMine") ? "btn-cancel-sm" : "btn-reg" %>'
                                            CommandArgument='<%# Eval("Id") %>'
                                            OnCommand="btnRegister_Command"
                                            Enabled='<%# Eval("StatusCss").ToString() != "s-ended" && Eval("StatusCss").ToString() != "s-ongoing" && (!(bool)Eval("IsExpired") || (bool)Eval("IsMine")) && (!(bool)Eval("IsFull") || (bool)Eval("IsMine")) && (!(bool)Eval("IsMine") || (bool)Eval("CanCancel")) %>'>
                                        <%# Eval("StatusCss").ToString() == "s-ended" ? "Đã kết thúc"
                                            : Eval("StatusCss").ToString() == "s-ongoing" ? "Đang diễn ra"
                                            : (bool)Eval("IsExpired") && !(bool)Eval("IsMine") ? "Hết hạn ĐK"
                                            : (bool)Eval("IsFull") && !(bool)Eval("IsMine") ? "Đã đầy"
                                            : (bool)Eval("IsMine") && !(bool)Eval("CanCancel") ? "Không thể hủy"
                                            : (bool)Eval("IsMine") ? "Hủy ĐK"
                                            : "Đăng ký" %>
                                    </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Sự kiện đã đăng ký -->
            <div style="margin-top: 32px">
                <div class="section-hd">
                    <div class="section-hd-left">
                        <div class="section-hd-label">Của bạn</div>
                        <div class="section-hd-title">Sự kiện đã đăng ký</div>
                    </div>
                    <a class="section-hd-link" href="Userprofile.aspx">Xem lịch sử →</a>
                </div>
                <div class="events-grid-user">
                    <asp:Repeater ID="rptRegisteredEvents" runat="server">
                        <ItemTemplate>
                            <div class="ecard" onclick="location.href='EventDetail.aspx?id=<%# Eval("Id") %>'">
                                <div class="ecard-img" style='<%# string.IsNullOrEmpty(Eval("AnhBia") as string) ? "": "background-image:url(" + ResolveUrl(Eval("AnhBia").ToString()) + ");background-size:cover;background-position:center" %>'>
                                    <div class="ecard-tags">
                                        <span class="ecard-tag"><%# Eval("Tag") %></span>
                                    </div>
                                    <span class="ecard-status <%# Eval("StatusCss") %>"><%# Eval("StatusLabel") %></span>
                                </div>
                                <div class="ecard-body">
                                    <div class="ecard-title"><%# Eval("Name") %></div>
                                    <div class="ecard-meta">
                                        <div class="ecard-meta-row"><%# Eval("Date") %></div>
                                        <div class="ecard-meta-row"><%# Eval("Location") %></div>
                                    </div>
                                    <div class="ecard-foot">
                                        <div>
                                            <div class="ecard-slots"><%# Eval("DkStatusLabel") %></div>
                                        </div>
                                        <asp:LinkButton ID="btnCancelReg" runat="server"
                                            CssClass="btn-cancel-sm"
                                            CommandArgument='<%# Eval("Id") %>'
                                            OnCommand="btnRegister_Command"
                                            OnClientClick="return confirm('Hủy đăng ký sự kiện này?');"
                                            Visible='<%# (bool)Eval("CanCancel") %>'>
                                        Hủy ĐK
                                    </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <asp:Panel ID="pnlNoRegistered" runat="server" Visible="false">
                    <div style="padding: 40px; text-align: center; color: var(--gray-500); background: var(--gray-50); border: 1px dashed var(--gray-200)">
                        Bạn chưa đăng ký sự kiện nào. <a href="Events.aspx" style="color: var(--primary); text-decoration: underline">Xem sự kiện</a>
                    </div>
                </asp:Panel>
            </div>

        </div>

        <!-- ─── SIDEBAR ─── -->
        <div class="side-col">

            <!-- Profile Widget -->
            <div class="profile-widget">
                <div class="pw-top">
                    <div class="pw-avatar">
                        <asp:Label ID="lblSideInitials" runat="server" Text="VA" />
                    </div>
                    <div>
                        <div class="pw-name">
                            <asp:Label ID="lblSideName" runat="server" Text="Văn An" /></div>
                        <div class="pw-role">
                            <asp:Label ID="lblSideRole" runat="server" Text="Engineering · HCM" /></div>
                    </div>
                </div>
                <div class="pw-stats">
                    <div class="pw-stat">
                        <div class="pw-stat-val">
                            <asp:Label ID="lblPwAttended" runat="server" Text="12" /></div>
                        <div class="pw-stat-lbl">Tham dự</div>
                    </div>
                    <div class="pw-stat">
                        <div class="pw-stat-val">
                            <asp:Label ID="lblPwRate" runat="server" Text="92%" /></div>
                        <div class="pw-stat-lbl">Tỷ lệ</div>
                    </div>
                    <div class="pw-stat">
                        <div class="pw-stat-val">
                            <asp:Label ID="lblPwRating" runat="server" Text="4.8*" /></div>
                        <div class="pw-stat-lbl">Điểm</div>
                    </div>
                </div>
                <div class="pw-actions">
                    <a class="pw-btn" href="UserProfile.aspx">Hồ sơ cá nhân</a>
                    <a class="pw-btn" href="UserCalendar.aspx">Lịch sự kiện</a>
                    <a class="pw-btn" href="Events.aspx">Tìm sự kiện mới</a>
                </div>
            </div>

            <!-- My Upcoming Events -->
            <div class="widget">
                <div class="widget-header">
                    <div class="widget-title">Sự kiện của tôi</div>
                    <a class="widget-link" href="UserProfile.aspx">Xem tất cả</a>
                </div>
                <asp:Repeater ID="rptMyEvents" runat="server">
                    <ItemTemplate>
                        <div class="my-event-item" onclick="location.href='EventDetail.aspx?id=<%# Eval("Id") %>'">
                            <div class="mev-icon"></div>
                            <div style="flex: 1">
                                <div class="mev-name"><%# Eval("Name") %></div>
                                <div class="mev-date"><%# Eval("DateShort") %> · <%# Eval("Location") %></div>
                            </div>
                            <div class="mev-status <%# Eval("StatusCss") %>"><%# Eval("StatusLabel") %></div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- Mini Calendar -->
            <div class="mini-cal">
                <div class="mini-cal-header">
                    <div class="mini-cal-title">
                        <asp:Label ID="lblCalMonth" runat="server" Text="Tháng 4, 2025" />
                    </div>
                    <div class="mini-cal-nav">
                        <asp:LinkButton ID="btnCalPrev" runat="server" CssClass="mc-nav-btn"
                            OnClick="btnCalPrev_Click">←</asp:LinkButton>
                        <asp:LinkButton ID="btnCalNext" runat="server" CssClass="mc-nav-btn"
                            OnClick="btnCalNext_Click">→</asp:LinkButton>
                    </div>
                </div>
                <div class="mini-cal-body">
                    <div class="mc-weekdays">
                        <div class="mc-wd">CN</div>
                        <div class="mc-wd">T2</div>
                        <div class="mc-wd">T3</div>
                        <div class="mc-wd">T4</div>
                        <div class="mc-wd">T5</div>
                        <div class="mc-wd">T6</div>
                        <div class="mc-wd">T7</div>
                    </div>
                    <div class="mc-days" id="miniCalDays" runat="server">
                        <%-- Rendered server-side in code-behind --%>
                    </div>
                </div>
            </div>

        </div>
    </div>
</asp:Content>

<%-- ═══ Page Scripts ═══ --%>
<asp:Content ID="cScripts" ContentPlaceHolderID="PageScripts" runat="server">
    <script>
        // Đóng banner sự kiện mới
        function closeAnnounce() {
            var p = document.getElementById('<%= pnlAnnounce.ClientID %>');
            if (p) p.style.display = 'none';
        }

    // setGreeting da co trong User.js (chay tu DOMContentLoaded)
    // syncUserToMaster khong can nua - User.Master.cs tu load tu Session
</script>
</asp:Content>

