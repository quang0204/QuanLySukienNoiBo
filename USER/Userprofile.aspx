<%@ Page Title="" Language="C#" MasterPageFile="~/User.Master" AutoEventWireup="true" CodeBehind="Userprofile.aspx.cs" Inherits="QuanLySuKien.Userprofile" %>

<asp:Content ID="cHeadStyles" ContentPlaceHolderID="HeadStyles" runat="server">
    <style>
        /* ── Profile Hero ── */
        .profile-hero {
            background: var(--black);
            color: var(--white);
            padding: 48px 48px 0;
            position: relative;
            overflow: hidden
        }

            .profile-hero::before {
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

        .profile-top {
            display: flex;
            align-items: flex-end;
            gap: 24px;
            padding-bottom: 32px;
            flex-wrap: wrap
        }

        .profile-avatar-big {
            width: 96px;
            height: 96px;
            background: var(--gray-700);
            border: 3px solid rgba(255,255,255,.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 34px;
            font-weight: 900;
            flex-shrink: 0;
            position: relative
        }

        .avatar-edit {
            position: absolute;
            bottom: 0;
            right: 0;
            width: 28px;
            height: 28px;
            background: var(--white);
            color: var(--black);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            cursor: pointer;
            border: none
        }

        .profile-info {
            flex: 1;
            min-width: 200px
        }

        .profile-name {
            font-size: 32px;
            font-weight: 900;
            letter-spacing: -1px;
            margin-bottom: 4px
        }

        .profile-title-text {
            font-size: 14px;
            color: rgba(255,255,255,.6)
        }

        .profile-tags {
            display: flex;
            gap: 8px;
            margin-top: 12px;
            flex-wrap: wrap
        }

        .profile-tag {
            border: 1px solid rgba(255,255,255,.2);
            padding: 4px 10px;
            font-size: 11px;
            font-family: var(--mono)
        }

        .profile-stats {
            display: flex;
            align-items: center;
            gap: 20px;
            padding-bottom: 8px;
            flex-shrink: 0
        }

        .p-stat-val {
            font-size: 20px;
            font-weight: 900;
            letter-spacing: -.5px
        }

        .ps-sep {
            width: 1px;
            height: 28px;
            background: rgba(255,255,255,.15);
            flex-shrink: 0
        }

        .p-stat-lbl {
            font-size: 10px;
            color: rgba(255,255,255,.4);
            font-family: var(--mono);
            margin-top: 2px;
            text-transform: uppercase;
            letter-spacing: .5px
        }

        /* ── Tabs ── */
        .profile-tabs {
            border-top: 1px solid rgba(255,255,255,.1);
            display: flex;
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
            z-index: 1
        }

        .p-tab {
            padding: 14px 24px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            color: rgba(255,255,255,.5);
            transition: all 150ms;
            background: none;
            border-top: none;
            border-left: none;
            border-right: none;
            font-family: var(--font)
        }

            .p-tab:hover {
                color: var(--white)
            }

            .p-tab.active {
                color: var(--white);
                border-bottom-color: var(--white)
            }

        .p-tab-danger {
            color: rgba(239,68,68,.55) !important
        }

            .p-tab-danger:hover {
                color: #ef4444 !important
            }

        /* ── Layout ── */
        .page-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 32px 48px;
            display: grid;
            grid-template-columns: 1fr 300px;
            gap: 24px;
            align-items: start
        }

        .tab-panel {
            display: none
        }

            .tab-panel.active {
                display: block
            }

        /* ── Cards ── */
        .card {
            background: var(--white);
            border: 1px solid var(--gray-200);
            overflow: hidden;
            margin-bottom: 20px
        }

            .card:last-child {
                margin-bottom: 0
            }

        .card-header {
            padding: 18px 24px;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            justify-content: space-between;
            align-items: center
        }

            .card-header h3 {
                font-size: 15px;
                font-weight: 800;
                letter-spacing: -.3px
            }

        .card-body {
            padding: 24px
        }

        /* ── History ── */
        .history-item {
            display: flex;
            gap: 16px;
            align-items: flex-start;
            padding: 18px 0;
            border-bottom: 1px solid var(--gray-100)
        }

            .history-item:last-child {
                border-bottom: none
            }

        .hi-date {
            width: 44px;
            flex-shrink: 0;
            background: var(--black);
            color: var(--white);
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 6px 0;
            font-family: var(--mono);
            text-align: center
        }

            .hi-date.cancelled {
                background: var(--gray-400)
            }

        .hi-dd {
            font-size: 16px;
            font-weight: 700;
            line-height: 1
        }

        .hi-mm {
            font-size: 9px;
            margin-top: 2px;
            opacity: .6
        }

        .hi-info {
            flex: 1
        }

        .hi-name {
            font-size: 14px;
            font-weight: 700;
            margin-bottom: 5px
        }

        .hi-meta {
            font-size: 12px;
            color: var(--gray-500);
            display: flex;
            gap: 14px;
            flex-wrap: wrap
        }

        .hi-status {
            flex-shrink: 0;
            padding-top: 2px
        }

        .badge-upcoming {
            background: #fef3c7;
            color: #d97706
        }

        .badge-attended {
            background: #000;
            color: #fff
        }

        .badge-cancelled {
            background: #fee2e2;
            color: #dc2626
        }

        /* ── Form ── */
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px
        }

        .info-field label {
            display: block;
            font-size: 10px;
            font-weight: 700;
            font-family: var(--mono);
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: .8px;
            margin-bottom: 7px
        }

        .info-val {
            font-size: 14px;
            font-weight: 500;
            color: var(--black);
            padding: 3px 0;
            min-height: 22px
        }

            .info-val.readonly {
                color: var(--gray-400)
            }

        .info-input {
            width: 100%;
            padding: 11px 13px;
            border: 1.5px solid var(--gray-200);
            font-size: 14px;
            font-family: var(--font);
            outline: none;
            transition: border-color 150ms
        }

            .info-input:focus {
                border-color: var(--black)
            }

        .btn-edit {
            padding: 8px 18px;
            border: 1.5px solid var(--gray-200);
            background: var(--white);
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            font-family: var(--font);
            transition: all 150ms
        }

            .btn-edit:hover {
                border-color: var(--black)
            }

        .btn-save {
            padding: 8px 18px;
            background: var(--black);
            color: var(--white);
            border: none;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            font-family: var(--font)
        }

        /* Password section */
        .pw-field {
            margin-bottom: 16px
        }

        .pw-label {
            font-size: 10px;
            font-weight: 700;
            font-family: var(--mono);
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: .8px;
            display: block;
            margin-bottom: 7px
        }

        .pw-input {
            width: 100%;
            max-width: 420px;
            padding: 11px 13px;
            border: 1.5px solid var(--gray-200);
            font-size: 14px;
            font-family: var(--font);
            outline: none;
            transition: border-color 150ms
        }

            .pw-input:focus {
                border-color: var(--black)
            }

        /* Toggle / Notification settings */
        .toggle-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 24px;
            border-bottom: 1px solid var(--gray-100)
        }

            .toggle-row:last-child {
                border-bottom: none
            }

        .toggle-title {
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 3px
        }

        .toggle-sub {
            font-size: 12px;
            color: var(--gray-500)
        }

        .toggle-switch {
            position: relative;
            display: inline-block;
            width: 44px;
            height: 24px;
            cursor: pointer;
            flex-shrink: 0
        }

            .toggle-switch input {
                opacity: 0;
                width: 0;
                height: 0;
                position: absolute
            }

        .toggle-track {
            position: absolute;
            inset: 0;
            background: var(--gray-300);
            border-radius: 24px;
            transition: .2s
        }

        .toggle-thumb {
            position: absolute;
            top: 3px;
            left: 3px;
            width: 18px;
            height: 18px;
            background: #fff;
            border-radius: 50%;
            transition: .2s;
            box-shadow: 0 1px 3px rgba(0,0,0,.2)
        }

        .toggle-switch input:checked ~ .toggle-track {
            background: var(--black)
        }

        .toggle-switch input:checked ~ .toggle-thumb {
            transform: translateX(20px)
        }

        /* ── Sidebar ── */
        .sidebar-card {
            background: var(--white);
            border: 1px solid var(--gray-200);
            overflow: hidden;
            margin-bottom: 16px
        }

            .sidebar-card:last-child {
                margin-bottom: 0
            }

        .sc-head {
            padding: 14px 18px;
            border-bottom: 1px solid var(--gray-200);
            font-size: 13px;
            font-weight: 800;
            letter-spacing: -.2px
        }

        .stat-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1px;
            background: var(--gray-200)
        }

        .stat-cell {
            background: var(--white);
            padding: 16px 10px;
            text-align: center
        }

        .stat-icon {
            font-size: 20px;
            margin-bottom: 5px
        }

        .stat-val {
            font-size: 18px;
            font-weight: 900;
            letter-spacing: -.5px
        }

        .stat-lbl {
            font-size: 10px;
            font-family: var(--mono);
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: .5px;
            margin-top: 2px
        }

        .upcoming-row {
            padding: 12px 18px;
            border-bottom: 1px solid var(--gray-100);
            display: flex;
            gap: 10px;
            align-items: center
        }

            .upcoming-row:last-child {
                border-bottom: none
            }

        .up-date {
            background: var(--black);
            color: var(--white);
            width: 36px;
            flex-shrink: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 4px 0;
            font-family: var(--mono)
        }

        .up-dd {
            font-size: 15px;
            font-weight: 700;
            line-height: 1
        }

        .up-mm {
            font-size: 9px;
            margin-top: 2px;
            opacity: .6
        }

        .up-name {
            font-size: 12px;
            font-weight: 700;
            margin-bottom: 2px
        }

        .up-sub {
            font-size: 11px;
            color: var(--gray-500)
        }

        .action-btn {
            width: 100%;
            padding: 11px 14px;
            border: 1.5px solid var(--gray-200);
            background: var(--white);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            font-family: var(--font);
            text-align: left;
            transition: all 150ms;
            display: block;
            margin-bottom: 8px;
            text-decoration: none
        }

            .action-btn:last-child {
                margin-bottom: 0
            }

            .action-btn:hover {
                border-color: var(--black)
            }

            .action-btn.danger {
                border-color: #fee2e2;
                color: var(--error)
            }

                .action-btn.danger:hover {
                    border-color: var(--error)
                }

        @media(max-width:1024px) {
            .page-content {
                grid-template-columns: 1fr
            }

            .profile-stats {
                display: none
            }
        }

        @media(max-width:768px) {
            .navbar {
                padding: 0 24px
            }

            .nav-links {
                display: none
            }

            .profile-hero {
                padding: 32px 24px 0
            }

            .page-content {
                padding: 20px 16px
            }

            .info-grid {
                grid-template-columns: 1fr
            }
        }

        /* Feedback stars */
        .fb-star {
            font-size: 32px;
            cursor: pointer;
            color: #d4d4d4;
            font-family: Georgia,serif;
            line-height: 1;
            user-select: none;
            transition: color 150ms
        }

            .fb-star:hover, .fb-star.active {
                color: #ffc107
            }

        .btn-feedback:hover {
            opacity: .8
        }
    </style>
</asp:Content>

<asp:Content ID="cHero" ContentPlaceHolderID="HeroBand" runat="server">
    <div class="profile-hero">
        <div class="hero-inner">
            <div class="profile-top">
                <div class="profile-avatar-big">
                    <asp:Label ID="lblAvatarInitials" runat="server" Text="VA" />
                    <button class="avatar-edit" title="Đổi ảnh">️</button>
                </div>
                <div class="profile-info">
                    <div class="profile-name">
                        <asp:Label ID="lblFullName" runat="server" Text="Nguyễn Văn An" />
                    </div>
                    <div class="profile-title-text">
                        <asp:Label ID="lblJobTitle" runat="server" Text="Software Engineer · Phòng Engineering · HCM Office" />
                    </div>
                    <div class="profile-tags">
                        <span class="profile-tag">
                            <asp:Label ID="lblTagDept" runat="server" Text="Engineering" /></span>
                        <span class="profile-tag">
                            <asp:Label ID="lblTagLevel" runat="server" Text="Senior" /></span>
                        <span class="profile-tag">
                            <asp:Label ID="lblTagOffice" runat="server" Text="HCM" /></span>
                        <span class="profile-tag">
                            <asp:Label ID="lblTagYear" runat="server" Text="Từ 2021" /></span>
                    </div>
                </div>
                <div class="profile-stats">
                    <div style="text-align: center">
                        <div class="p-stat-val">
                            <asp:Label ID="lblStatTotalAtt" runat="server" Text="12" /></div>
                        <div class="p-stat-lbl">Đã tham dự</div>
                    </div>
                    <div class="ps-sep"></div>
                    <div style="text-align: center">
                        <div class="p-stat-val">
                            <asp:Label ID="lblStatAttRate" runat="server" Text="92%" /></div>
                        <div class="p-stat-lbl">Tỷ lệ tham dự</div>
                    </div>
                    <div class="ps-sep"></div>
                    <div style="text-align: center">
                        <div class="p-stat-val">
                            <asp:Label ID="lblStatRating" runat="server" Text="4.8*" /></div>
                        <div class="p-stat-lbl">Điểm đánh giá</div>
                    </div>
                    <div class="ps-sep"></div>
                    <div style="text-align: center">
                        <div class="p-stat-val">
                            <asp:Label ID="lblStatYears" runat="server" Text="3" /></div>
                        <div class="p-stat-lbl">Năm công tác</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tabs -->
        <asp:HiddenField ID="hfActiveTab" runat="server" Value="history" />
        <div class="profile-tabs">
            <button type="button" class="p-tab active" data-tab="history" onclick="switchTab('history',this)">Lịch sử sự kiện</button>
            <button type="button" class="p-tab" data-tab="info" onclick="switchTab('info',this)">Thông tin cá nhân</button>
            <button type="button" class="p-tab" data-tab="password" onclick="switchTab('password',this)">Đổi mật khẩu</button>
            <button type="button" class="p-tab p-tab-danger" data-tab="danger" onclick="switchTab('danger',this)">Đăng xuất</button>
        </div>
    </div>
</asp:Content>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-content">

        <!-- ─── MAIN COLUMN ─── -->
        <div>

            <!-- TAB: History -->
            <div class="tab-panel active" id="tab-history">
                <div class="card">
                    <div class="card-header">
                        <h3>Lịch sử tham gia sự kiện</h3>
                        <span style="font-size: 11px; font-family: var(--mono); color: var(--gray-400)">12 sự kiện</span>
                    </div>
                    <div class="card-body" style="padding: 0 24px">
                        <asp:Repeater ID="rptHistory" runat="server" OnItemCommand="rptHistory_ItemCommand">
                            <ItemTemplate>
                                <div class="history-item">
                                    <div class='hi-date <%# Eval("DateCss") %>'
                                        onclick="location.href='EventDetail.aspx?id=<%# Eval("Id") %>'"
                                        style="cursor: pointer">
                                        <div class="hi-dd"><%# Eval("Day") %></div>
                                        <div class="hi-mm"><%# Eval("MonthLabel") %></div>
                                    </div>
                                    <div class="hi-info"
                                        onclick="location.href='EventDetail.aspx?id=<%# Eval("Id") %>'"
                                        style="cursor: pointer">
                                        <div class="hi-name"><%# Eval("Name") %></div>
                                        <div class="hi-meta">
                                            <span><%# Eval("Location") %></span>
                                            <span><%# Eval("Category") %></span>
                                        </div>
                                    </div>
                                    <div class="hi-status">
                                        <span class="badge <%# Eval("BadgeCss") %>"><%# Eval("StatusLabel") %></span>
                                        <%-- Nut Danh gia: chi hien khi da tham gia & su kien da ket thuc --%>
                                        <asp:LinkButton ID="btnFeedback" runat="server"
                                            Visible='<%# (bool)Eval("CanFeedback") %>'
                                            CommandName="OpenFeedback"
                                            CommandArgument='<%# Eval("Id") %>'
                                            CssClass="btn-feedback"
                                            Style="display: inline-block; margin-left: 8px; padding: 6px 12px; background: #000; color: #fff; border: none; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; text-decoration: none; font-family: var(--mono)">
                                        <%# (bool)Eval("HasFeedback") ? "Sua DG" : "Danh gia" %>
                                    </asp:LinkButton>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>

            <!-- TAB: Personal Info -->
            <div class="tab-panel" id="tab-info">
                <div class="card">
                    <div class="card-header">
                        <h3>Thông tin cá nhân</h3>
                        <asp:Button ID="btnEditInfo" runat="server" CssClass="btn-edit"
                            Text="️ Chỉnh sửa" OnClick="btnEditInfo_Click" />
                    </div>
                    <div class="card-body">
                        <div class="info-grid">
                            <div class="info-field">
                                <label>Họ và tên</label>
                                <asp:TextBox ID="txtFullName" runat="server" CssClass="info-input" Text="Nguyễn Văn An" ReadOnly="true" />
                            </div>
                            <div class="info-field">
                                <label>Email công ty</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="info-input" Text="vanan@company.com" ReadOnly="true" />
                            </div>
                            <div class="info-field">
                                <label>Số điện thoại</label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="info-input" Text="0912 345 678" ReadOnly="true" />
                            </div>
                            <div class="info-field">
                                <label>Phòng ban</label>
                                <div class="info-val readonly">Engineering</div>
                            </div>
                            <div class="info-field">
                                <label>Chức vụ</label>
                                <div class="info-val readonly">Software Engineer</div>
                            </div>
                            <div class="info-field">
                                <label>Văn phòng</label>
                                <div class="info-val readonly">HCM Office</div>
                            </div>
                            <div class="info-field">
                                <label>Ngày vào làm</label>
                                <div class="info-val readonly">01/03/2021</div>
                            </div>
                            <div class="info-field">
                                <label>Mã nhân viên</label>
                                <div class="info-val readonly">EMP-2021-089</div>
                            </div>
                        </div>
                    </div>
                    <div style="padding: 16px 24px; border-top: 1px solid var(--gray-100); display: flex; gap: 10px; justify-content: flex-end">
                        <asp:Button ID="btnSaveInfo" runat="server" CssClass="btn-save"
                            Text="Lưu thay đổi" OnClick="btnSaveInfo_Click" Visible="false" />
                    </div>
                </div>
            </div>

            <!-- TAB: Password -->
            <div class="tab-panel" id="tab-password">
                <div class="card">
                    <div class="card-header">
                        <h3>Đổi mật khẩu</h3>
                    </div>
                    <div class="card-body">
                        <div class="pw-field">
                            <label class="pw-label">Mật khẩu hiện tại</label>
                            <asp:TextBox ID="txtCurrentPw" runat="server" CssClass="pw-input" TextMode="Password" />
                        </div>
                        <div class="pw-field">
                            <label class="pw-label">Mật khẩu mới</label>
                            <asp:TextBox ID="txtNewPw" runat="server" CssClass="pw-input" TextMode="Password" />
                        </div>
                        <div class="pw-field">
                            <label class="pw-label">Xác nhận mật khẩu mới</label>
                            <asp:TextBox ID="txtConfirmPw" runat="server" CssClass="pw-input" TextMode="Password" />
                        </div>
                        <asp:Button ID="btnChangePw" runat="server" CssClass="btn-save"
                            Text="Cập nhật mật khẩu" OnClick="btnChangePw_Click" />
                    </div>
                </div>
            </div>

            <!-- TAB: Danger Zone -->
            <div class="tab-panel" id="tab-danger">
                <div class="card">
                    <div class="card-header">
                        <h3>Đăng xuất</h3>
                    </div>
                    <div class="card-body">
                        <p style="color: var(--gray-600); margin-bottom: 16px">Đăng xuất khỏi tài khoản trên thiết bị này.</p>
                        <asp:Button ID="btnLogout" runat="server" CssClass="action-btn"
                            Text="Đăng xuất ngay" OnClick="btnLogout_Click" />
                    </div>
                </div>

                <div class="card" style="border-color: #fecaca; margin-top: 20px">
                    <div class="card-header" style="background: #fff5f5">
                        <h3 style="color: var(--error)">Khu vực nguy hiểm</h3>
                    </div>
                    <div class="card-body">
                        <p style="color: var(--gray-600); margin-bottom: 16px">Các hành động sau sẽ ảnh hưởng vĩnh viễn đến tài khoản của bạn.</p>
                        <asp:Button ID="btnDeactivate" runat="server" CssClass="action-btn danger"
                            Text="Tạm dừng tài khoản"
                            OnClientClick="return confirm('Tạm dừng tài khoản? Bạn sẽ bị đăng xuất.');"
                            OnClick="btnDeactivate_Click" />
                        <asp:Button ID="btnDeleteAccount" runat="server" CssClass="action-btn danger"
                            Text="Xóa tài khoản vĩnh viễn"
                            OnClientClick="return confirm('Bạn có chắc muốn xóa tài khoản? Hành động này không thể hoàn tác.');"
                            OnClick="btnDeleteAccount_Click" />
                    </div>
                </div>
            </div>

        </div>

        <!-- ─── SIDEBAR ─── -->
        <div>
            <!-- Upcoming Events -->
            <div class="sidebar-card">
                <div class="sc-head">Sắp diễn ra</div>
                <asp:Repeater ID="rptUpcoming" runat="server">
                    <ItemTemplate>
                        <div class="upcoming-row" onclick="location.href='EventDetail.aspx?id=<%# Eval("Id") %>'">
                            <div class="up-date">
                                <div class="up-dd"><%# Eval("Day") %></div>
                                <div class="up-mm"><%# Eval("MonthLabel") %></div>
                            </div>
                            <div>
                                <div class="up-name"><%# Eval("Name") %></div>
                                <div class="up-sub"><%# Eval("Sub") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- Quick Actions -->
            <div class="sidebar-card">
                <div class="sc-head">Thao tác nhanh</div>
                <div style="padding: 16px">
                    <a class="action-btn" href="Events.aspx">Tìm sự kiện mới</a>
                    <a class="action-btn" href="UserCalendar.aspx">Xem lịch của tôi</a>
                    <a class="action-btn" href="Calendar.aspx">️ Lịch tổng hợp</a>
                </div>
            </div>
        </div>

        <!-- ═══ MODAL ĐÁNH GIÁ ═══ -->
        <asp:Panel ID="pnlFbModal" runat="server" Visible="false"
            Style="position: fixed; inset: 0; background: rgba(0,0,0,.6); z-index: 9999; display: flex; align-items: center; justify-content: center; padding: 20px">
            <div style="background: #fff; max-width: 520px; width: 100%; padding: 28px; position: relative">
                <button type="button" onclick="closeFbModal()"
                    style="position: absolute; top: 14px; right: 14px; background: none; border: none; font-size: 24px; cursor: pointer; color: #666">
                    X
                </button>

                <div style="font-family: var(--mono); font-size: 11px; letter-spacing: 1px; color: #666; margin-bottom: 6px">ĐÁNH GIÁ SỰ KIỆN</div>
                <h3 style="font-size: 18px; margin-bottom: 8px">
                    <asp:Label ID="lblFbEventName" runat="server" />
                </h3>
                <div style="font-size: 13px; color: #737373; margin-bottom: 20px">
                    <asp:Label ID="lblFbEventDate" runat="server" />
                </div>

                <div style="font-size: 13px; font-weight: 700; margin-bottom: 8px">Đánh giá của bạn:</div>
                <div id="fbStarsModal" style="display: flex; gap: 8px; margin-bottom: 18px; justify-content: center">
                    <span class="fb-star" data-val="1" onclick="setStarModal(1)">*</span>
                    <span class="fb-star" data-val="2" onclick="setStarModal(2)">*</span>
                    <span class="fb-star" data-val="3" onclick="setStarModal(3)">*</span>
                    <span class="fb-star" data-val="4" onclick="setStarModal(4)">*</span>
                    <span class="fb-star" data-val="5" onclick="setStarModal(5)">*</span>
                </div>
                <asp:HiddenField ID="hfFbScore" runat="server" Value="0" />
                <asp:HiddenField ID="hfFbEventId" runat="server" Value="0" />

                <div style="font-size: 13px; font-weight: 700; margin-bottom: 8px">Bình luận (tuỳ chọn):</div>
                <asp:TextBox ID="txtFbContent" runat="server" TextMode="MultiLine" Rows="4"
                    placeholder="Chia sẻ cảm nhận của bạn về sự kiện..."
                    Style="width: 100%; border: 1px solid #d4d4d4; padding: 12px; font-family: var(--font); font-size: 13px; resize: vertical; margin-bottom: 20px" />

                <div style="display: flex; gap: 10px; justify-content: flex-end">
                    <button type="button" onclick="closeFbModal()"
                        style="padding: 10px 20px; background: #fff; color: #000; border: 1px solid #d4d4d4; font-weight: 700; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; cursor: pointer; font-family: var(--font)">
                        Huỷ</button>
                    <asp:Button ID="btnSubmitFeedback" runat="server" Text="GỬI ĐÁNH GIÁ"
                        OnClick="btnSubmitFeedback_Click"
                        Style="padding: 10px 20px; background: #000; color: #fff; border: none; font-weight: 700; font-size: 12px; letter-spacing: 1px; cursor: pointer; font-family: var(--font)" />
                </div>
            </div>
        </asp:Panel>

    </div>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="PageScripts" runat="server">
    <script>
        function switchTab(tabId, el) {
            document.querySelectorAll('.tab-panel').forEach(function (p) { p.classList.remove('active'); });
            document.querySelectorAll('.p-tab').forEach(function (t) { t.classList.remove('active'); });
            document.getElementById('tab-' + tabId).classList.add('active');
            if (el) el.classList.add('active');
            // Luu vao hidden field de giu tab sau postback
            var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
            if (hf) hf.value = tabId;
        }

        // Restore tab khi load (sau postback)
        window.addEventListener('DOMContentLoaded', function () {
            var hf = document.getElementById('<%= hfActiveTab.ClientID %>');
    var active = hf ? hf.value : 'history';
    if (!active) active = 'history';
    var btn = document.querySelector('.p-tab[data-tab="' + active + '"]');
    switchTab(active, btn);

    // Auto fill star khi mo modal (neu hf co value)
    var hfScore = document.getElementById('<%= hfFbScore.ClientID %>');
    if (hfScore && parseInt(hfScore.value) > 0) {
        setStarModal(parseInt(hfScore.value));
    }
});

        // Star rating in modal
        function setStarModal(val) {
            var hf = document.getElementById('<%= hfFbScore.ClientID %>');
            if (hf) hf.value = val;
            var stars = document.querySelectorAll('#fbStarsModal .fb-star');
            stars.forEach(function (s) {
                var v = parseInt(s.getAttribute('data-val'));
                if (v <= val) s.classList.add('active');
                else s.classList.remove('active');
            });
        }

        function closeFbModal() {
            // Postback empty event id de an modal
            document.querySelector('[id$="pnlFbModal"]').style.display = 'none';
        }

        // Toast helper (de cac handler tu code-behind goi)
        function showToast(msg) {
            var t = document.createElement('div');
            t.className = 'toast show';
            t.style.cssText = 'position:fixed;bottom:24px;right:24px;background:#000;color:#fff;padding:14px 20px;border-radius:4px;font-size:14px;font-weight:600;z-index:9999;box-shadow:0 4px 12px rgba(0,0,0,.3)';
            t.textContent = msg;
            document.body.appendChild(t);
            setTimeout(function () {
                t.style.transition = 'opacity .3s';
                t.style.opacity = '0';
                setTimeout(function () { t.remove(); }, 300);
            }, 3000);
        }
</script>
</asp:Content>
