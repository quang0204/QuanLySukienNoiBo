<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminParticipants.aspx.cs" Inherits="QuanLySuKien.AdminParticipants" MasterPageFile="~/Admin.Master" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">Nguoi tham gia - EventHub</asp:Content>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box
        }

        :root {
            --black: #000;
            --gray-900: #111;
            --gray-600: #404040;
            --gray-500: #737373;
            --gray-400: #a3a3a3;
            --gray-300: #d4d4d4;
            --gray-200: #e5e5e5;
            --gray-100: #f5f5f5;
            --gray-50: #fafafa;
            --white: #fff;
            --success: #10b981;
            --warning: #f59e0b;
            --error: #ef4444;
            --info: #3b82f6;
            --font: 'Archivo',sans-serif;
            --mono: 'Space Mono',monospace;
            --sidebar: 260px;
            --navbar: 64px
        }

        body {
            font-family: var(--font);
            background: var(--gray-50);
            color: var(--black);
            display: flex;
            min-height: 100vh
        }

        .main {
            margin-left: var(--sidebar);
            flex: 1;
            display: flex;
            flex-direction: column
        }

        .topbar {
            height: var(--navbar);
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 32px;
            position: sticky;
            top: 0;
            z-index: 50
        }

        .page-title {
            font-size: 18px;
            font-weight: 700;
            letter-spacing: -.3px
        }

        .page-breadcrumb {
            font-size: 12px;
            color: var(--gray-500);
            font-family: var(--mono)
        }

        .topbar-right {
            display: flex;
            align-items: center;
            gap: 12px
        }

        .btn-primary {
            background: var(--black);
            color: var(--white);
            border: none;
            padding: 9px 18px;
            border-radius: 4px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            font-family: var(--font);
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 200ms
        }

            .btn-primary:hover {
                opacity: .85
            }

        .content {
            padding: 32px;
            flex: 1
        }
        /* stats */
        .mini-stats {
            display: grid;
            grid-template-columns: repeat(4,1fr);
            gap: 16px;
            margin-bottom: 24px
        }

        .mini-stat {
            background: var(--white);
            border: 1px solid var(--gray-200);
            border-radius: 4px;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            gap: 14px
        }

        .mini-stat-icon {
            width: 40px;
            height: 40px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px
        }

        .mini-stat-info {
        }

        .mini-stat-val {
            font-size: 24px;
            font-weight: 900;
            letter-spacing: -1px
        }

        .mini-stat-lbl {
            font-size: 11px;
            color: var(--gray-500);
            font-family: var(--mono);
            margin-top: 2px;
            text-transform: uppercase;
            letter-spacing: .5px
        }
        /* tabs */
        .tabs-row {
            display: flex;
            gap: 0;
            border-bottom: 1px solid var(--gray-200);
            margin-bottom: 24px
        }

        .tab {
            padding: 12px 20px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            transition: all 150ms;
            color: var(--gray-500)
        }

            .tab:hover {
                color: var(--black)
            }

            .tab.active {
                color: var(--black);
                border-bottom-color: var(--black)
            }

        .tab-count {
            background: var(--gray-100);
            color: var(--gray-600);
            font-size: 11px;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 10px;
            margin-left: 6px;
            font-family: var(--mono)
        }

        .tab.active .tab-count {
            background: var(--black);
            color: var(--white)
        }
        /* filters */
        .filters-row {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
            align-items: center
        }

        .search-input {
            display: flex;
            align-items: center;
            gap: 8px;
            border: 1.5px solid var(--gray-200);
            border-radius: 4px;
            padding: 9px 14px;
            background: var(--white);
            min-width: 240px
        }

            .search-input input {
                border: none;
                background: transparent;
                font-size: 14px;
                font-family: var(--font);
                outline: none;
                width: 100%
            }

        .filter-select {
            padding: 9px 14px;
            border: 1.5px solid var(--gray-200);
            border-radius: 4px;
            font-size: 13px;
            font-family: var(--font);
            background: var(--white);
            cursor: pointer;
            outline: none
        }

        .bulk-actions {
            margin-left: auto;
            display: flex;
            gap: 8px
        }

        .btn-outline {
            padding: 8px 14px;
            border: 1.5px solid var(--gray-300);
            border-radius: 4px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            background: var(--white);
            font-family: var(--font);
            transition: all 150ms
        }

            .btn-outline:hover {
                border-color: var(--black)
            }
        /* table */
        .table-card {
            background: var(--white);
            border: 1px solid var(--gray-200);
            border-radius: 4px;
            overflow: hidden
        }

        .table-wrap {
            overflow-x: auto
        }

        table {
            width: 100%;
            border-collapse: collapse
        }

        th {
            padding: 12px 16px;
            font-size: 11px;
            font-weight: 600;
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: .8px;
            text-align: left;
            font-family: var(--mono);
            background: var(--gray-50);
            border-bottom: 1px solid var(--gray-200)
        }

            th:first-child {
                width: 40px
            }

        td {
            padding: 14px 16px;
            font-size: 14px;
            border-bottom: 1px solid var(--gray-100);
            vertical-align: middle
        }

        tr:last-child td {
            border-bottom: none
        }

        tr:hover td {
            background: var(--gray-50)
        }

        tr.selected td {
            background: #f0f7ff
        }

        .checkbox {
            width: 16px;
            height: 16px;
            cursor: pointer;
            accent-color: var(--black)
        }

        .person-cell {
            display: flex;
            align-items: center;
            gap: 10px
        }

        .person-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
            flex-shrink: 0
        }

        .person-name {
            font-weight: 600;
            font-size: 14px
        }

        .person-email {
            font-size: 12px;
            color: var(--gray-500)
        }

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            border-radius: 2px;
            font-size: 11px;
            font-weight: 700;
            font-family: var(--mono)
        }

        .badge-approved {
            background: #dcfce7;
            color: #15803d
        }

        .badge-pending {
            background: #fef3c7;
            color: #d97706
        }

        .badge-rejected {
            background: #fee2e2;
            color: #dc2626
        }

        .badge-attended {
            background: #000;
            color: #fff
        }

        .badge-absent {
            background: var(--gray-100);
            color: var(--gray-500)
        }

        .action-row {
            display: flex;
            gap: 6px
        }

        .btn-sm {
            padding: 5px 12px;
            border-radius: 2px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            border: 1px solid var(--gray-200);
            background: var(--white);
            font-family: var(--font);
            transition: all 150ms;
            white-space: nowrap
        }

            .btn-sm:hover {
                border-color: var(--black)
            }

            .btn-sm.approve {
                color: #15803d;
                border-color: #86efac
            }

                .btn-sm.approve:hover {
                    background: #f0fdf4;
                    border-color: #15803d
                }

            .btn-sm.reject {
                color: var(--error);
                border-color: #fca5a5
            }

                .btn-sm.reject:hover {
                    background: #fef2f2;
                    border-color: var(--error)
                }

            .btn-sm.attend {
                background: var(--black);
                color: var(--white);
                border-color: var(--black)
            }

                .btn-sm.attend:hover {
                    opacity: .8
                }
        /* pagination */
        .table-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 20px;
            border-top: 1px solid var(--gray-200)
        }

        .page-info {
            font-size: 13px;
            color: var(--gray-600)
        }

        .page-btns {
            display: flex;
            gap: 6px
        }

        .page-btn {
            padding: 6px 12px;
            border: 1px solid var(--gray-200);
            border-radius: 2px;
            font-size: 13px;
            cursor: pointer;
            background: var(--white);
            font-family: var(--font)
        }

            .page-btn.active, .page-btn:hover {
                background: var(--black);
                color: var(--white);
                border-color: var(--black)
            }
        /* event select card */
        .event-select {
            background: var(--white);
            border: 1px solid var(--gray-200);
            border-radius: 4px;
            padding: 16px 20px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 16px
        }

        .event-select-label {
            font-size: 13px;
            font-weight: 600;
            white-space: nowrap
        }

        .event-select select {
            flex: 1;
            padding: 9px 14px;
            border: 1.5px solid var(--gray-200);
            border-radius: 4px;
            font-size: 14px;
            font-family: var(--font);
            background: var(--white);
            cursor: pointer;
            outline: none
        }
        /* toast */
        .toast {
            position: fixed;
            bottom: 24px;
            right: 24px;
            background: var(--black);
            color: var(--white);
            padding: 14px 20px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 600;
            transform: translateY(80px);
            opacity: 0;
            transition: all 300ms;
            z-index: 9999;
            display: flex;
            align-items: center;
            gap: 10px
        }

            .toast.show {
                transform: translateY(0);
                opacity: 1
            }

        @media(max-width:1200px) {
            .mini-stats {
                grid-template-columns: repeat(2,1fr)
            }
        }

        @media(max-width:900px) {
            .sidebar {
                transform: translateX(-100%)
            }

            .main {
                margin-left: 0
            }
        }

        @media(max-width:600px) {
            .content {
                padding: 20px
            }

            .mini-stats {
                grid-template-columns: 1fr
            }

            .filters-row {
                flex-wrap: wrap
            }
        }
    </style>
</asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField ID="hfTab" runat="server" Value="all" />
    <div class="main" style="margin-left: 260px">
        <div class="topbar">
            <div class="topbar-left">
                <button class="menu-toggle" type="button" onclick="document.getElementById('sidebar').classList.toggle('open')"></button>
                <div>
                    <div class="page-title">Quan ly Nguoi tham gia</div>
                    <div class="page-breadcrumb">EventHub / Nguoi tham gia</div>
                </div>
            </div>
            <div class="topbar-right">
            </div>
        </div>
        <div class="content">
            <div class="mini-stats">
                <div class="mini-stat">
                    <div>
                        <div class="mini-stat-val"><%= hfCountApproved.Value %></div>
                        <div class="mini-stat-lbl">Da duyet</div>
                    </div>
                </div>
                <div class="mini-stat">
                    <div>
                        <div class="mini-stat-val"><%= hfCountPending.Value %></div>
                        <div class="mini-stat-lbl">Cho duyet</div>
                    </div>
                </div>
                <div class="mini-stat">
                    <div>
                        <div class="mini-stat-val"><%= hfCountAttended.Value %></div>
                        <div class="mini-stat-lbl">Da diem danh</div>
                    </div>
                </div>
                <div class="mini-stat">
                    <div>
                        <div class="mini-stat-val"><%= hfCountRejected.Value %></div>
                        <div class="mini-stat-lbl">Da tu choi</div>
                    </div>
                </div>
            </div>
            <!-- Chon su kien -->
            <div class="event-select">
                <div class="event-select-label">Su kien:</div>
                <asp:DropDownList ID="ddlSuKien" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSuKien_Changed">
                </asp:DropDownList>
            </div>
            <!-- Tabs -->
            <asp:HiddenField ID="hfCountAll" runat="server" Value="0" />
            <asp:HiddenField ID="hfCountPending" runat="server" Value="0" />
            <asp:HiddenField ID="hfCountApproved" runat="server" Value="0" />
            <asp:HiddenField ID="hfCountRejected" runat="server" Value="0" />
            <asp:HiddenField ID="hfCountAttended" runat="server" Value="0" />
            <div class="tabs-row">
                <div class='tab <%= hfTab.Value=="all"?"active":"" %>' onclick="setTab('all')">Tat ca <span class="tab-count"><%= hfCountAll.Value %></span></div>
                <div class='tab <%= hfTab.Value=="pending"?"active":"" %>' onclick="setTab('pending')">Cho duyet <span class="tab-count"><%= hfCountPending.Value %></span></div>
                <div class='tab <%= hfTab.Value=="approved"?"active":"" %>' onclick="setTab('approved')">Da duyet <span class="tab-count"><%= hfCountApproved.Value %></span></div>
                <div class='tab <%= hfTab.Value=="rejected"?"active":"" %>' onclick="setTab('rejected')">Tu choi <span class="tab-count"><%= hfCountRejected.Value %></span></div>
                <div class='tab <%= hfTab.Value=="attended"?"active":"" %>' onclick="setTab('attended')">Da diem danh <span class="tab-count"><%= hfCountAttended.Value %></span></div>
            </div>
            <!-- Filters -->
            <div class="filters-row">
                <div class="search-input">
                    <asp:TextBox ID="txtSearch" runat="server" placeholder="Tim ten, email, phong ban..." />
                </div>
                <asp:DropDownList ID="ddlFilter" runat="server" CssClass="filter-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_Changed">
                    <asp:ListItem Value="">Tat ca phong ban</asp:ListItem>
                    <asp:ListItem Value="engineering">Engineering</asp:ListItem>
                    <asp:ListItem Value="marketing">Marketing</asp:ListItem>
                    <asp:ListItem Value="hr">HR</asp:ListItem>
                    <asp:ListItem Value="finance">Finance</asp:ListItem>
                </asp:DropDownList>
                <div class="bulk-actions">
                    <asp:Button ID="btnApproveAll" runat="server" Text="&#10003; Duyet tat ca cho" CssClass="btn-outline" OnClick="btnApproveAll_Click" />
                    <asp:Button ID="btnExportList" runat="server" Text="&#8595; Xuat danh sach" CssClass="btn-outline" OnClick="btnExportList_Click" />
                    <asp:Button ID="btnSearch" runat="server" Text="Tim" CssClass="btn-primary" OnClick="btnSearch_Click" />
                </div>
            </div>
            <!-- Table -->
            <div class="table-card">
                <div class="table-wrap">
                    <asp:GridView ID="gvParticipants" runat="server" AutoGenerateColumns="False" GridLines="None"
                        DataKeyNames="MaNguoiDung" ShowHeaderWhenEmpty="True" EmptyDataText="Khong co nguoi tham gia nao."
                        AllowPaging="True" PageSize="15"
                        OnPageIndexChanging="gvParticipants_PageIndexChanging"
                        OnRowCommand="gvParticipants_RowCommand"
                        PagerStyle-CssClass="pagination">
                        <Columns>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <input type="checkbox" id="chkAll" onclick="toggleAll(this)" /></HeaderTemplate>
                                <ItemTemplate>
                                    <input type="checkbox" class="cb p-cb" value='<%# Eval("MaNguoiDung") %>' /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="NGUOI THAM GIA">
                                <ItemTemplate>
                                    <div class="p-cell">
                                        <div class="p-avatar"><%# Eval("TenVietTat") %></div>
                                        <div>
                                            <div class="p-name"><%# Eval("HoTen") %></div>
                                            <div class="p-email"><%# Eval("Email") %></div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="PhongBan" HeaderText="PHONG BAN" />
                            <asp:BoundField DataField="NgayDangKy" HeaderText="DANG KY LUC" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                            <asp:TemplateField HeaderText="TRANG THAI">
                                <ItemTemplate><span class='s-badge s-<%# Eval("TrangThaiClass") %>'><%# Eval("TrangThaiText") %></span></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="DIEM DANH">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server"
                                        CssClass='<%# (bool)Eval("DaDiemDanh") ? "check-btn checked" : "check-btn" %>'
                                        CommandName="Checkin" CommandArgument='<%# Eval("MaNguoiDung") %>'
                                        Enabled='<%# (bool)Eval("CanCheckin") %>'>&#10003;</asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="HANH DONG">
                                <ItemTemplate>
                                    <div class="act-row">
                                        <asp:LinkButton runat="server" CssClass="act-btn approve"
                                            CommandName="Approve" CommandArgument='<%# Eval("MaNguoiDung") %>'
                                            Visible='<%# (bool)Eval("CanApprove") %>'>
                    <%# Eval("TrangThaiClass").ToString() == "rejected" ? "Duyet lai" : "Duyet" %>
                  </asp:LinkButton>
                                        <asp:LinkButton runat="server" CssClass="act-btn reject"
                                            CommandName="Reject" CommandArgument='<%# Eval("MaNguoiDung") %>'
                                            OnClientClick='<%# Eval("TrangThaiClass").ToString() == "approved" ? "return confirm(\u0027Tu choi nguoi nay (da duyet)?\u0027)" : "return confirm(\u0027Tu choi dang ky nay?\u0027)" %>'
                                            Visible='<%# (bool)Eval("CanReject") %>'>Tu choi</asp:LinkButton>
                                        <%-- Label "(Het cho)" hien khi pending nhung su kien day --%>
                                        <asp:Label runat="server"
                                            Text="(Het cho)"
                                            Visible='<%# !(bool)Eval("CanApprove") && Eval("TrangThaiClass").ToString() == "pending" && (bool)Eval("EventFull") %>'
                                            Style="color: #dc2626; font-size: 11px; font-style: italic; margin-right: 6px" />
                                        <%-- Label cho rejected ma su kien da day --%>
                                        <asp:Label runat="server"
                                            Text="(Het cho)"
                                            Visible='<%# !(bool)Eval("CanApprove") && Eval("TrangThaiClass").ToString() == "rejected" && (bool)Eval("EventFull") %>'
                                            Style="color: #dc2626; font-size: 11px; font-style: italic" />
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
<asp:Content ID="ScriptContent" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        function toggleAll(cb) { document.querySelectorAll('.p-cb').forEach(function (c) { c.checked = cb.checked; }); }
        function setTab(val) {
            document.getElementById('<%= hfTab.ClientID %>').value = val;
    __doPostBack('<%= btnSearch.UniqueID %>', '');
        }
</script>
</asp:Content>
