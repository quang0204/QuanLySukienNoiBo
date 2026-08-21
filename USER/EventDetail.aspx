<%@ Page Title="" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="EventDetail.aspx.cs" Inherits="QuanLySuKien.EventDetail" %>

<asp:Content ID="cHeadStyles" ContentPlaceHolderID="HeadStyles" runat="server">
    <style>
        /* ── Event Hero ── */
        .event-hero {
            background: var(--black);
            color: var(--white);
            padding: 48px 48px 0;
            position: relative;
            overflow: hidden
        }

            .event-hero::before {
                content: '';
                position: absolute;
                inset: 0;
                background: repeating-linear-gradient(-45deg,transparent,transparent 20px,rgba(255,255,255,.015) 20px,rgba(255,255,255,.015) 21px)
            }

        .hero-inner {
            position: relative;
            z-index: 1;
            max-width: 1200px;
            margin: 0 auto
        }

        .hero-meta {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 16px;
            flex-wrap: wrap
        }

        .hero-title {
            font-size: 44px;
            font-weight: 900;
            letter-spacing: -2px;
            line-height: 1.1;
            margin-bottom: 14px;
            max-width: 780px
        }

        .hero-subtitle {
            font-size: 15px;
            color: rgba(255,255,255,.6);
            line-height: 1.7;
            max-width: 640px;
            margin-bottom: 32px
        }

        .hero-stats {
            display: flex;
            gap: 40px;
            border-top: 1px solid rgba(255,255,255,.1);
            padding: 24px 0
        }

        .hs-item {
            display: flex;
            flex-direction: column;
            gap: 4px
        }

        .hs-val {
            font-size: 20px;
            font-weight: 900;
            letter-spacing: -.5px
        }

        .hs-lbl {
            font-size: 11px;
            font-family: var(--mono);
            color: rgba(255,255,255,.4);
            text-transform: uppercase;
            letter-spacing: .5px
        }

        /* ── Content layout ── */
        .page-body {
            max-width: 1200px;
            margin: 0 auto;
            padding: 32px 48px;
            display: grid;
            grid-template-columns: 1fr 360px;
            gap: 28px;
            align-items: start
        }

        /* ── Section Cards (left) ── */
        .section-card {
            background: var(--white);
            border: 1px solid var(--gray-200);
            overflow: hidden;
            margin-bottom: 20px
        }

        .section-card-header {
            padding: 18px 24px;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            align-items: center;
            justify-content: space-between
        }

            .section-card-header h3 {
                font-size: 15px;
                font-weight: 700
            }

        .section-card-body {
            padding: 24px
        }

        .description-text {
            font-size: 14px;
            line-height: 1.8;
            color: var(--gray-700)
        }

            .description-text p {
                margin-bottom: 16px
            }

                .description-text p:last-child {
                    margin-bottom: 0
                }

        /* Agenda */
        .agenda-item {
            display: flex;
            gap: 16px;
            padding: 14px 0;
            border-bottom: 1px solid var(--gray-100)
        }

            .agenda-item:last-child {
                border-bottom: none
            }

        .agenda-time {
            font-size: 11px;
            font-family: var(--mono);
            font-weight: 700;
            color: var(--gray-500);
            width: 80px;
            flex-shrink: 0;
            padding-top: 2px
        }

        .agenda-title {
            font-size: 14px;
            font-weight: 700;
            margin-bottom: 4px
        }

        .agenda-detail {
            font-size: 12px;
            color: var(--gray-500)
        }

        /* Speakers */
        .speaker-item {
            display: flex;
            gap: 14px;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid var(--gray-100)
        }

            .speaker-item:last-child {
                border-bottom: none
            }

        .speaker-ava {
            width: 48px;
            height: 48px;
            background: var(--black);
            color: var(--white);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 15px;
            font-weight: 700;
            flex-shrink: 0
        }

        .speaker-name {
            font-size: 14px;
            font-weight: 700
        }

        .speaker-role {
            font-size: 12px;
            color: var(--gray-500)
        }

        /* Location */
        .location-map {
            background: var(--gray-100);
            height: 160px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 16px;
            border: 1px solid var(--gray-200);
            position: relative;
            overflow: hidden
        }

        .location-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px
        }

        .loc-item label {
            font-size: 10px;
            font-weight: 700;
            font-family: var(--mono);
            color: var(--gray-400);
            text-transform: uppercase;
            letter-spacing: .5px;
            display: block;
            margin-bottom: 4px
        }

        .loc-val {
            font-size: 13px;
            font-weight: 500
        }

        /* ── Right sidebar cards ── */
        .right-card {
            background: var(--white);
            border: 1px solid var(--gray-200);
            overflow: hidden;
            margin-bottom: 16px
        }

        .rc-header {
            padding: 14px 20px;
            border-bottom: 1px solid var(--gray-200);
            font-size: 13px;
            font-weight: 700;
            display: flex;
            justify-content: space-between;
            align-items: center
        }

        .rc-body {
            padding: 20px
        }

        /* Register box */
        .register-box {
            background: var(--black);
            color: var(--white);
            padding: 24px;
            margin-bottom: 16px;
            position: relative;
            overflow: hidden
        }

            .register-box::before {
                content: '';
                position: absolute;
                bottom: -40px;
                right: -40px;
                width: 160px;
                height: 160px;
                border-radius: 50%;
                background: rgba(255,255,255,.04)
            }

        .reg-cap-label {
            font-size: 10px;
            font-family: var(--mono);
            color: rgba(255,255,255,.4);
            text-transform: uppercase;
            letter-spacing: .8px;
            margin-bottom: 8px
        }

        .reg-cap-numbers {
            display: flex;
            justify-content: space-between;
            align-items: baseline;
            margin-bottom: 8px
        }

        .reg-cap-registered {
            font-size: 28px;
            font-weight: 900;
            letter-spacing: -1px
        }

        .reg-cap-total {
            font-size: 14px;
            color: rgba(255,255,255,.4)
        }

        .progress-bar {
            height: 6px;
            background: rgba(255,255,255,.15);
            overflow: hidden;
            margin-bottom: 6px
        }

        .progress-fill {
            height: 100%;
            background: var(--white);
            transition: width 600ms ease
        }

        .reg-cap-pct {
            font-size: 11px;
            font-family: var(--mono);
            color: rgba(255,255,255,.5)
        }

        .deadline-row {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 12px;
            color: rgba(255,255,255,.6);
            margin: 14px 0 20px
        }

        .deadline-dot {
            width: 6px;
            height: 6px;
            background: var(--warning);
            border-radius: 50%;
            flex-shrink: 0
        }

        .btn-register {
            width: 100%;
            padding: 14px;
            background: var(--white);
            color: var(--black);
            border: none;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            font-family: var(--font);
            position: relative;
            z-index: 1;
            transition: all 200ms;
            text-align: center;
            display: block
        }

            .btn-register:hover {
                transform: translateY(-1px);
                box-shadow: 0 6px 20px rgba(255,255,255,.2)
            }

            .btn-register.registered {
                background: var(--success);
                color: var(--white)
            }

        .btn-cancel-reg {
            width: 100%;
            padding: 10px;
            background: transparent;
            color: rgba(255,255,255,.5);
            border: 1px solid rgba(255,255,255,.15);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            font-family: var(--font);
            margin-top: 10px;
            transition: all 200ms;
            position: relative;
            z-index: 1
        }

            .btn-cancel-reg:hover {
                color: var(--white);
                border-color: rgba(255,255,255,.4)
            }

        /* Info rows */
        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            padding: 10px 0;
            border-bottom: 1px solid var(--gray-100)
        }

            .info-row:last-child {
                border-bottom: none
            }

        .ir-label {
            font-size: 11px;
            font-family: var(--mono);
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: .5px;
            padding-top: 2px
        }

        .ir-val {
            font-size: 13px;
            font-weight: 600;
            text-align: right;
            max-width: 180px
        }

        /* Attendees */
        .attendee-list {
            padding: 0 20px 8px
        }

        .attendee-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 0;
            border-bottom: 1px solid var(--gray-100)
        }

            .attendee-item:last-child {
                border-bottom: none
            }

        .att-ava {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: var(--black);
            color: var(--white);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            font-weight: 700;
            flex-shrink: 0
        }

        .att-info {
            flex: 1
        }

        .att-name {
            font-size: 13px;
            font-weight: 600
        }

        .att-dept {
            font-size: 11px;
            color: var(--gray-500)
        }

        .att-status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            flex-shrink: 0;
            background: var(--success)
        }

        /* Similar events */
        .similar-item {
            display: flex;
            gap: 12px;
            padding: 12px 20px;
            border-bottom: 1px solid var(--gray-100);
            cursor: pointer;
            transition: background 150ms
        }

            .similar-item:last-child {
                border-bottom: none
            }

            .similar-item:hover {
                background: var(--gray-50)
            }

        .sim-date {
            background: var(--black);
            color: var(--white);
            width: 36px;
            flex-shrink: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 5px 0;
            font-family: var(--mono)
        }

        .sim-dd {
            font-size: 15px;
            font-weight: 700;
            line-height: 1
        }

        .sim-mm {
            font-size: 9px;
            margin-top: 2px
        }

        .sim-title {
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 3px
        }

        .sim-sub {
            font-size: 11px;
            color: var(--gray-500)
        }

        /* Modal */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,.6);
            z-index: 1000;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            pointer-events: none;
            transition: opacity 200ms
        }

            .modal-overlay.open {
                opacity: 1;
                pointer-events: all
            }

        .modal {
            background: var(--white);
            width: 460px;
            overflow: hidden;
            transform: translateY(20px);
            transition: transform 200ms
        }

        .modal-overlay.open .modal {
            transform: translateY(0)
        }

        .modal-header {
            padding: 20px 24px;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            align-items: center;
            justify-content: space-between
        }

            .modal-header h3 {
                font-size: 16px;
                font-weight: 700
            }

        .modal-close {
            font-size: 20px;
            color: var(--gray-400);
            cursor: pointer;
            background: none;
            border: none
        }

        .modal-body {
            padding: 24px
        }

        .modal-event-name {
            font-size: 18px;
            font-weight: 900;
            letter-spacing: -.5px;
            margin-bottom: 16px
        }

        .modal-info-row {
            display: flex;
            gap: 8px;
            font-size: 13px;
            color: var(--gray-600);
            margin-bottom: 8px;
            align-items: center
        }

        .modal-info-icon {
            font-size: 14px;
            width: 20px
        }

        .modal-footer {
            padding: 16px 24px;
            border-top: 1px solid var(--gray-200);
            display: flex;
            gap: 10px;
            justify-content: flex-end
        }

        .btn-modal-cancel {
            padding: 10px 20px;
            border: 1.5px solid var(--gray-200);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            background: var(--white);
            font-family: var(--font);
            transition: all 150ms
        }

            .btn-modal-cancel:hover {
                border-color: var(--black)
            }

        .btn-confirm {
            padding: 10px 24px;
            background: var(--black);
            color: var(--white);
            border: none;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            font-family: var(--font)
        }

            .btn-confirm:hover {
                opacity: .85
            }
    </style>
</asp:Content>

<%-- ═══ Hero Band (event-specific) ═══ --%>
<asp:Content ID="cHero" ContentPlaceHolderID="HeroBand" runat="server">
    <div class="event-hero">
        <div class="hero-inner">
            <div class="breadcrumb">
                <a href="Default.aspx">Trang chủ</a>
                <span>/</span>
                <a href="Events.aspx">Sự kiện</a>
                <span>/</span>
                <span style="color: rgba(255,255,255,.7)">
                    <asp:Label ID="lblBreadcrumb" runat="server" Text="Chi tiết sự kiện" />
                </span>
            </div>
            <div class="hero-meta">
                <span class="badge badge-open">
                    <asp:Label ID="lblStatusBadge" runat="server" Text="● Đang mở đăng ký" />
                </span>
                <span class="badge badge-category">
                    <asp:Label ID="lblCategoryBadge" runat="server" Text="Workshop" />
                </span>
                <asp:Repeater ID="rptTags" runat="server">
                    <ItemTemplate>
                        <span class="badge badge-category"><%# Eval("Tag") %></span>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <h1 class="hero-title">
                <asp:Label ID="lblEventTitle" runat="server" Text="Workshop UX Research &amp; User Testing Q2 2025" />
            </h1>
            <p class="hero-subtitle">
                <asp:Label ID="lblEventSubtitle" runat="server"
                    Text="Khóa học thực hành về phương pháp nghiên cứu người dùng, usability testing và cách tổng hợp insight để cải thiện sản phẩm." />
            </p>
            <div class="hero-stats">
                <div class="hs-item">
                    <div class="hs-val">
                        <asp:Label ID="lblHsDayOfWeek" runat="server" Text="Thứ Tư" /></div>
                    <div class="hs-lbl">Ngày trong tuần</div>
                </div>
                <div class="hs-item">
                    <div class="hs-val">
                        <asp:Label ID="lblHsDate" runat="server" Text="23/04/2025" /></div>
                    <div class="hs-lbl">Ngày tổ chức</div>
                </div>
                <div class="hs-item">
                    <div class="hs-val">
                        <asp:Label ID="lblHsTime" runat="server" Text="09:00 – 17:00" /></div>
                    <div class="hs-lbl">Thời gian</div>
                </div>
                <div class="hs-item">
                    <div class="hs-val">
                        <asp:Label ID="lblHsLocation" runat="server" Text="Tầng 12 · Tòa A" /></div>
                    <div class="hs-lbl">Địa điểm</div>
                </div>
                <div class="hs-item">
                    <div class="hs-val">Miễn phí</div>
                    <div class="hs-lbl">Chi phí</div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<%-- ═══ Main Content ═══ --%>
<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-body">

        <!-- ─── LEFT COLUMN ─── -->
        <div>

            <!-- Description -->
            <div class="section-card">
                <div class="section-card-header">
                    <h3>Giới thiệu sự kiện</h3>
                </div>
                <div class="section-card-body">
                    <div class="description-text">
                        <asp:Literal ID="litDescription" runat="server" />
                    </div>
                </div>
            </div>

            <!-- Agenda -->
            <div class="section-card">
                <div class="section-card-header">
                    <h3>Chương trình chi tiết</h3>
                </div>
                <div class="section-card-body" style="padding: 0 24px">
                    <asp:Repeater ID="rptAgenda" runat="server">
                        <ItemTemplate>
                            <div class="agenda-item">
                                <div class="agenda-time"><%# Eval("Time") %></div>
                                <div class="agenda-content">
                                    <div class="agenda-title"><%# Eval("Title") %></div>
                                    <div class="agenda-detail"><%# Eval("Detail") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Speakers -->
            <div class="section-card">
                <div class="section-card-header">
                    <h3>Diễn giả & Facilitators</h3>
                </div>
                <div class="section-card-body" style="padding: 0 24px">
                    <asp:Repeater ID="rptSpeakers" runat="server">
                        <ItemTemplate>
                            <div class="speaker-item">
                                <div class="speaker-ava"><%# Eval("Initials") %></div>
                                <div>
                                    <div class="speaker-name"><%# Eval("Name") %></div>
                                    <div class="speaker-role"><%# Eval("Role") %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Location -->
            <div class="section-card">
                <div class="section-card-header">
                    <h3>Địa điểm tổ chức</h3>
                </div>
                <div class="section-card-body">
                    <div class="location-map">
                        <div style="position: absolute; inset: 0; background: linear-gradient(135deg,#f5f5f5 25%,#e8e8e8 25%,#e8e8e8 50%,#f5f5f5 50%,#f5f5f5 75%,#e8e8e8 75%); background-size: 20px 20px"></div>
                        <div style="position: relative; z-index: 1; text-align: center">
                            <div style="font-size: 28px; margin-bottom: 4px"></div>
                            <div style="font-size: 12px; font-weight: 700; background: var(--white); padding: 6px 14px; border: 1px solid var(--gray-200)">
                                <asp:Label ID="lblMapPin" runat="server" Text="Phòng Innovation Lab · Tầng 12 · Tòa A" />
                            </div>
                        </div>
                    </div>
                    <div class="location-grid">
                        <asp:Repeater ID="rptLocationGrid" runat="server">
                            <ItemTemplate>
                                <div class="loc-item">
                                    <label><%# Eval("Label") %></label>
                                    <div class="loc-val"><%# Eval("Value") %></div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>

        </div>

        <!-- ─── RIGHT SIDEBAR ─── -->
        <div>

            <!-- Register Box -->
            <div class="register-box">
                <div class="reg-cap-label">Số người đăng ký</div>
                <div class="reg-cap-numbers">
                    <span class="reg-cap-registered">
                        <asp:Label ID="lblRegCount" runat="server" Text="68" />
                    </span>
                    <span class="reg-cap-total">/
                   
                        <asp:Label ID="lblTotalSlots" runat="server" Text="80" />
                        chỗ
                </span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: <%# FillPct %>%"></div>
                </div>
                <div class="reg-cap-pct">
                    <asp:Label ID="lblFillPct" runat="server" Text="85% đã lấp đầy · Còn 12 chỗ" />
                </div>
                <div class="deadline-row">
                    <div class="deadline-dot"></div>
                    Hạn đăng ký: <strong style="color: var(--white); margin-left: 4px">
                        <asp:Label ID="lblDeadline" runat="server" Text="20/04/2025" />
                    </strong>
                </div>

                <asp:Button ID="btnRegister" runat="server" CssClass="btn-register"
                    Text="Đăng ký tham gia" OnClientClick="openModal(); return false;" />
                <asp:Button ID="btnCancelReg" runat="server" CssClass="btn-cancel-reg"
                    Text="Hủy đăng ký" Visible="false" OnClick="btnCancelReg_Click" />
            </div>

            <!-- Event Info -->
            <div class="right-card">
                <div class="rc-header">Thông tin sự kiện</div>
                <div class="rc-body" style="padding: 0 20px">
                    <asp:Repeater ID="rptEventInfo" runat="server">
                        <ItemTemplate>
                            <div class="info-row">
                                <span class="ir-label"><%# Eval("Label") %></span>
                                <span class="ir-val" style='<%# Eval("Style") %>'><%# Eval("Value") %></span>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Attendees -->
            <div class="right-card">
                <div class="rc-header">
                    <span>Người đăng ký (<asp:Label ID="lblAttCount" runat="server" Text="68" />)</span>
                    <span style="font-size: 11px; font-family: var(--mono); color: var(--gray-400); cursor: pointer">Xem tất cả</span>
                </div>
                <div class="attendee-list">
                    <asp:Repeater ID="rptAttendees" runat="server">
                        <ItemTemplate>
                            <div class="attendee-item">
                                <div class="att-ava" style='background: <%# Eval("AvaColor") %>'><%# Eval("Initials") %></div>
                                <div class="att-info">
                                    <div class="att-name"><%# Eval("Name") %></div>
                                    <div class="att-dept"><%# Eval("Dept") %></div>
                                </div>
                                <div class="att-status-dot"></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <div style="text-align: center; padding: 12px 0; font-size: 12px; font-family: var(--mono); color: var(--gray-400)">
                        +
                        <asp:Label ID="lblMoreAttendees" runat="server" Text="64" />
                        người khác
               
                    </div>
                </div>
            </div>

            <!-- Similar Events -->
            <div class="right-card">
                <div class="rc-header">Sự kiện tương tự</div>
                <asp:Repeater ID="rptSimilarEvents" runat="server">
                    <ItemTemplate>
                        <div class="similar-item" onclick="location.href='EventDetail.aspx?id=<%# Eval("Id") %>'">
                            <div class="sim-date">
                                <div class="sim-dd"><%# Eval("Day") %></div>
                                <div class="sim-mm"><%# Eval("MonthLabel") %></div>
                            </div>
                            <div>
                                <div class="sim-title"><%# Eval("Title") %></div>
                                <div class="sim-sub"><%# Eval("Sub") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

        </div>
    </div>

    <!-- ─── REGISTRATION MODAL ─── -->
    <div class="modal-overlay" id="regModal">
        <div class="modal">
            <div class="modal-header">
                <h3>Xác nhận đăng ký</h3>
                <button class="modal-close" onclick="closeModal()">X</button>
            </div>
            <div class="modal-body">
                <div class="modal-event-name">
                    <asp:Label ID="lblModalEventName" runat="server"
                        Text="Workshop UX Research & User Testing Q2 2025" />
                </div>
                <div class="modal-info-row">
                    <span class="modal-info-icon"></span>
                    <span>
                        <asp:Label ID="lblModalDate" runat="server" Text="Thứ Tư, 23/04/2025" /></span>
                </div>
                <div class="modal-info-row">
                    <span class="modal-info-icon"></span>
                    <span>
                        <asp:Label ID="lblModalTime" runat="server" Text="09:00 – 17:00" /></span>
                </div>
                <div class="modal-info-row">
                    <span class="modal-info-icon"></span>
                    <span>
                        <asp:Label ID="lblModalLoc" runat="server" Text="Innovation Lab, Tầng 12, Tòa A" /></span>
                </div>
                <div class="modal-info-row">
                    <span class="modal-info-icon"></span>
                    <span>Đăng ký với tư cách: <strong>Nguyễn Văn An</strong></span>
                </div>
                <div style="background: var(--gray-50); padding: 14px; margin-top: 16px; border: 1px solid var(--gray-200); font-size: 13px; color: var(--gray-600); line-height: 1.6">
                    Bằng việc đăng ký, bạn cam kết tham gia đầy đủ. Vui lòng hủy trước 24h nếu không thể tham dự.
           
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-modal-cancel" onclick="closeModal()">Hủy</button>
                <asp:Button ID="btnConfirmRegister" runat="server" CssClass="btn-confirm"
                    Text="v Xác nhận đăng ký" OnClick="btnConfirmRegister_Click"
                    OnClientClick="closeModal();" />
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="PageScripts" runat="server">
    <script>
        function openModal() {
            document.getElementById('regModal').classList.add('open');
        }
        function closeModal() {
            document.getElementById('regModal').classList.remove('open');
        }
        document.getElementById('regModal').addEventListener('click', function (e) {
            if (e.target === this) closeModal();
        });
</script>
</asp:Content>
