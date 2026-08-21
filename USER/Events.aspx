<%@ Page Title="" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Events.aspx.cs" Inherits="QuanLySuKien.Events" %>

<asp:Content ID="cHeadStyles" ContentPlaceHolderID="HeadStyles" runat="server">
    <style>
        .page-body {
            max-width: 1400px;
            margin: 0 auto;
            padding: 32px 48px;
            display: block
        }

        .main-col {
            display: flex;
            flex-direction: column;
            gap: 28px
        }

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
        /* Filter Chips */
        .events-filter {
            display: flex;
            gap: 8px;
            margin-bottom: 20px;
            flex-wrap: wrap
        }

        .filter-chip {
            padding: 7px 16px;
            border: 2px solid var(--gray-200);
            background: var(--white);
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            transition: all 150ms;
            text-transform: uppercase;
            letter-spacing: .5px;
            font-family: var(--font)
        }

            .filter-chip:hover {
                border-color: var(--black)
            }

            .filter-chip.active {
                background: var(--black);
                color: var(--white);
                border-color: var(--black)
            }
        /* Search bar */
        .search-bar {
            display: flex;
            gap: 0;
            margin-bottom: 16px
        }

        .search-input {
            flex: 1;
            padding: 12px 16px;
            border: 2px solid var(--gray-200);
            background: var(--white);
            font-size: 13px;
            font-family: var(--font);
            outline: none;
            transition: border-color 150ms
        }

            .search-input:focus {
                border-color: var(--black)
            }

        .search-btn {
            padding: 12px 20px;
            background: var(--black);
            color: var(--white);
            border: none;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            font-family: var(--font)
        }
        /* Events grid */
        .events-grid-user {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px
        }

        .events-count {
            font-size: 12px;
            color: var(--gray-500);
            font-family: var(--mono)
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

        @media(max-width:1200px) {
            .page-body {
                grid-template-columns: 1fr
            }
        }

        @media(max-width:900px) {
            .navbar {
                padding: 0 24px
            }

            .nav-links {
                display: none
            }

            .page-body {
                padding: 24px
            }

            .events-grid-user {
                grid-template-columns: 1fr
            }

            .hero-band {
                padding: 28px 24px
            }

            .hero-quick-stats {
                display: none
            }
        }
    </style>
</asp:Content>

<asp:Content ID="cHero" ContentPlaceHolderID="HeroBand" runat="server">
    <div class="hero-band">
        <div class="hero-band-inner">
            <div class="hero-greeting">
                <div class="greeting-time" id="timeGreet">Đang tải...</div>
                <div class="greeting-name">Sự kiện </div>
                <div class="greeting-role">Khám phá và đăng ký các sự kiện dành cho bạn</div>
            </div>
            <div class="hero-quick-stats">
                <div class="hqs-item">
                    <div class="hqs-num">
                        <asp:Label ID="lblStatOpen" runat="server" Text="6" /></div>
                    <div class="hqs-lbl">Sự kiện đang mở</div>
                </div>
                <div class="hqs-item">
                    <div class="hqs-num">
                        <asp:Label ID="lblStatMyReg" runat="server" Text="2" /></div>
                    <div class="hqs-lbl">Đã đăng ký</div>
                </div>
                <div class="hqs-item">
                    <div class="hqs-num">
                        <asp:Label ID="lblStatMyAtt" runat="server" Text="12" /></div>
                    <div class="hqs-lbl">Đã tham dự</div>
                </div>
            </div>
            <div class="hero-cta">
                <a class="btn-hero" href="Calendar.aspx">Xem lịch →</a>
                <a class="btn-hero outline" href="Default.aspx">← Trang chủ</a>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-body">

        <!-- ─── MAIN COLUMN ─── -->
        <div class="main-col">
            <div>
                <div class="section-hd">
                    <div class="section-hd-left">
                        <div class="section-hd-label">Đang mở đăng ký</div>
                        <div class="section-hd-title">Tất cả sự kiện</div>
                    </div>
                    <div class="events-count">
                        <asp:Label ID="lblEventsCount" runat="server" Text="" />
                    </div>
                </div>

                <!-- Search bar -->
                <div class="search-bar">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input"
                        placeholder="Tìm kiếm sự kiện..." />
                    <asp:Button ID="btnSearch" runat="server" CssClass="search-btn"
                        Text=" Tìm" OnClick="btnSearch_Click" />
                </div>

                <!-- Filter Chips -->
                <div class="events-filter">
                    <asp:LinkButton ID="btnFilterAll" runat="server" CssClass="filter-chip active" CommandArgument="all" OnCommand="FilterChip_Command">Tất cả</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterTB" runat="server" CssClass="filter-chip" CommandArgument="tb" OnCommand="FilterChip_Command">Team Building</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterWorkshop" runat="server" CssClass="filter-chip" CommandArgument="workshop" OnCommand="FilterChip_Command">Workshop</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterTraining" runat="server" CssClass="filter-chip" CommandArgument="training" OnCommand="FilterChip_Command">Đào tạo</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterSeminar" runat="server" CssClass="filter-chip" CommandArgument="seminar" OnCommand="FilterChip_Command">Hội thảo</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterMine" runat="server" CssClass="filter-chip" CommandArgument="mine" OnCommand="FilterChip_Command">Của tôi</asp:LinkButton>
                    <asp:LinkButton ID="btnFilterEnded" runat="server" CssClass="filter-chip" CommandArgument="ended" OnCommand="FilterChip_Command">Đã kết thúc</asp:LinkButton>
                </div>

                <!-- Events Grid -->
                <div class="events-grid-user">
                    <asp:Repeater ID="rptEvents" runat="server">
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
                                            CssClass='<%# (bool)Eval("IsAttended") ? "btn-reg disabled" : Eval("StatusCss").ToString() == "s-ended" ? "btn-reg disabled" : (bool)Eval("IsExpired") && !(bool)Eval("IsMine") ? "btn-reg disabled" : (bool)Eval("IsFull") && !(bool)Eval("IsMine") ? "btn-reg disabled" : (bool)Eval("IsMine") && !(bool)Eval("CanCancel") ? "btn-cancel-sm disabled" : (bool)Eval("IsMine") ? "btn-cancel-sm" : "btn-reg" %>'
                                            CommandArgument='<%# Eval("Id") %>'
                                            OnCommand="btnRegister_Command"
                                            Enabled='<%# !(bool)Eval("IsAttended") && Eval("StatusCss").ToString() != "s-ended" && Eval("StatusCss").ToString() != "s-ongoing" && (!(bool)Eval("IsExpired") || (bool)Eval("IsMine")) && (!(bool)Eval("IsFull") || (bool)Eval("IsMine")) && (!(bool)Eval("IsMine") || (bool)Eval("CanCancel")) %>'>
                                        <%# (bool)Eval("IsAttended") ? "Đã tham gia"
                                            : Eval("StatusCss").ToString() == "s-ended" ? "Đã kết thúc"
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
        </div>
    </div>
</asp:Content>
