<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminCalendar.aspx.cs"
    Inherits="QuanLySuKien.AdminCalendar" MasterPageFile="~/Admin.Master"
    ResponseEncoding="UTF-8" %>

<%-- &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; TITLE &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; --%>
<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    L&#7883;ch qu&#7843;n l&#253; s&#7921; ki&#7879;n - EventHub Admin
</asp:Content>

<%-- &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; HEAD / CSS &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; --%>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* -- MAIN & TOPBAR -- */
        .main {
            margin-left: var(--sidebar);
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh
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

        .topbar-left {
            display: flex;
            align-items: center;
            gap: 16px
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
            gap: 16px
        }

        .topbar-btn {
            width: 36px;
            height: 36px;
            border: 1px solid var(--gray-200);
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            background: var(--white);
            font-size: 16px;
            transition: all 200ms;
            position: relative
        }

            .topbar-btn:hover {
                border-color: var(--black)
            }

        .menu-toggle {
            display: none;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 20px;
            padding: 4px
        }

        @media(max-width:900px) {
            .sidebar {
                transform: translateX(-100%)
            }

                .sidebar.open {
                    transform: translateX(0)
                }

            .main {
                margin-left: 0 !important
            }

            .menu-toggle {
                display: block
            }
        }

        /* &#9472;&#9472; CAL TOOLBAR &#9472;&#9472; */
        .cal-toolbar {
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            padding: 14px 28px;
            display: flex;
            align-items: center;
            gap: 16px;
            flex-shrink: 0;
            flex-wrap: wrap
        }

        .cal-nav-group {
            display: flex;
            align-items: center;
            gap: 8px
        }

        .cal-month-title {
            font-size: 20px;
            font-weight: 900;
            letter-spacing: -1px;
            min-width: 200px;
            font-family: var(--font)
        }

        .cal-nav-btn {
            width: 32px;
            height: 32px;
            border: 1.5px solid var(--gray-200);
            border-radius: 4px;
            background: var(--white);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            transition: all 150ms
        }

            .cal-nav-btn:hover {
                border-color: var(--black)
            }

        .btn-today, input[type="submit"].btn-today {
            padding: 7px 14px;
            border: 1.5px solid var(--gray-200);
            border-radius: 4px;
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            background: var(--white);
            font-family: var(--mono);
            letter-spacing: .5px;
            transition: all 150ms
        }

            .btn-today:hover {
                border-color: var(--black)
            }

        .cal-legend {
            display: flex;
            gap: 14px;
            margin-left: auto;
            flex-wrap: wrap
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: var(--gray-600);
            font-family: var(--font)
        }

        .legend-dot {
            width: 10px;
            height: 10px;
            border-radius: 2px
        }

        .view-toggle {
            display: flex;
            border: 1.5px solid var(--gray-200);
            border-radius: 4px;
            overflow: hidden
        }

        .vt-btn {
            padding: 7px 14px;
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            border: none;
            background: var(--white);
            font-family: var(--mono);
            transition: all 150ms;
            letter-spacing: .5px
        }

            .vt-btn.active {
                background: var(--black);
                color: var(--white)
            }

        .cal-type-filter, select.cal-type-filter {
            padding: 7px 12px;
            border: 1.5px solid var(--gray-200);
            border-radius: 4px;
            font-size: 12px;
            font-family: var(--mono);
            background: var(--white);
            outline: none;
            cursor: pointer;
            transition: border-color 150ms
        }

            .cal-type-filter:focus {
                border-color: var(--black)
            }

        /* &#9472;&#9472; CALENDAR BODY &#9472;&#9472; */
        .cal-body {
            flex: 1;
            display: flex;
            overflow: hidden
        }

        /* Month view */
        .cal-month-view {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden
        }

        .cal-weekdays {
            display: grid;
            grid-template-columns: repeat(7,1fr);
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            flex-shrink: 0
        }

        .cal-wd {
            padding: 10px 8px;
            text-align: center;
            font-size: 10px;
            font-weight: 700;
            font-family: var(--mono);
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: 1px
        }

        .cal-grid {
            flex: 1;
            display: grid;
            grid-template-columns: repeat(7,1fr);
            grid-auto-rows: 1fr;
            overflow-y: auto
        }

        .cal-cell {
            border-right: 1px solid var(--gray-200);
            border-bottom: 1px solid var(--gray-200);
            padding: 6px;
            min-height: 110px;
            cursor: pointer;
            transition: background 100ms;
            display: flex;
            flex-direction: column
        }

            .cal-cell:nth-child(7n) {
                border-right: none
            }

            .cal-cell:hover {
                background: rgba(0,0,0,.02)
            }

            .cal-cell.today {
                background: #f0f7ff
            }

            .cal-cell.other-month .day-num {
                color: var(--gray-300)
            }

        .day-num-wrap {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 4px
        }

        .day-num {
            font-size: 12px;
            font-weight: 600;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            font-family: var(--mono)
        }

        .cal-cell.today .day-num {
            background: var(--black);
            color: var(--white)
        }

        .day-add-btn {
            width: 20px;
            height: 20px;
            background: transparent;
            border: none;
            cursor: pointer;
            font-size: 14px;
            color: var(--gray-400);
            opacity: 0;
            transition: opacity 150ms;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center
        }

        .cal-cell:hover .day-add-btn {
            opacity: 1
        }

        .day-add-btn:hover {
            background: var(--gray-200);
            color: var(--black)
        }

        /* Event pills */
        .day-events {
            display: flex;
            flex-direction: column;
            gap: 2px;
            flex: 1
        }

        .ev-pill {
            border-radius: 2px;
            padding: 2px 6px;
            font-size: 10px;
            font-weight: 700;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            cursor: pointer;
            font-family: var(--mono);
            letter-spacing: .3px;
            transition: opacity 150ms
        }

            .ev-pill:hover {
                opacity: .75
            }

        .ev-tb {
            background: #000;
            color: #fff
        }

        .ev-workshop {
            background: #dbeafe;
            color: #1d4ed8
        }

        .ev-training {
            background: #dcfce7;
            color: #15803d
        }

        .ev-seminar {
            background: #fef3c7;
            color: #d97706
        }

        .ev-more {
            font-size: 10px;
            color: var(--gray-500);
            padding: 1px 6px;
            font-family: var(--mono)
        }

        /* Week view */
        .cal-week-view {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden
        }

        .week-header {
            display: grid;
            grid-template-columns: 60px repeat(7,1fr);
            background: var(--white);
            border-bottom: 1px solid var(--gray-200);
            flex-shrink: 0
        }

        .week-time-col {
            border-right: 1px solid var(--gray-200)
        }

        .week-day-head {
            padding: 10px 8px;
            text-align: center;
            border-right: 1px solid var(--gray-200)
        }

            .week-day-head:last-child {
                border-right: none
            }

        .wdh-name {
            font-size: 10px;
            font-weight: 700;
            font-family: var(--mono);
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: 1px
        }

        .wdh-num {
            font-size: 18px;
            font-weight: 900;
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 4px auto 0;
            border-radius: 50%;
            font-family: var(--font)
        }

            .wdh-num.today {
                background: var(--black);
                color: var(--white)
            }

        .week-body {
            flex: 1;
            display: grid;
            grid-template-columns: 60px repeat(7,1fr);
            overflow-y: auto;
            position: relative
        }

        .week-time-labels {
            border-right: 1px solid var(--gray-200)
        }

        .time-label {
            height: 60px;
            display: flex;
            align-items: flex-start;
            justify-content: flex-end;
            padding-right: 8px;
            padding-top: 4px;
            font-size: 10px;
            font-family: var(--mono);
            color: var(--gray-400)
        }

        .week-col {
            border-right: 1px solid var(--gray-200);
            position: relative;
            min-height: 960px
        }

            .week-col:last-child {
                border-right: none
            }

        .week-hour-line {
            position: absolute;
            left: 0;
            right: 0;
            border-top: 1px solid var(--gray-100)
        }

        .week-event {
            position: absolute;
            left: 4px;
            right: 4px;
            border-radius: 3px;
            padding: 4px 6px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            overflow: hidden;
            border-left: 3px solid transparent;
            transition: opacity 150ms;
            font-family: var(--font)
        }

            .week-event:hover {
                opacity: .85
            }

        .we-tb {
            background: #f0f0f0;
            border-left-color: #000;
            color: #000
        }

        .we-workshop {
            background: #eff6ff;
            border-left-color: #3b82f6;
            color: #1d4ed8
        }

        .we-training {
            background: #f0fdf4;
            border-left-color: #10b981;
            color: #15803d
        }

        .we-seminar {
            background: #fffbeb;
            border-left-color: #f59e0b;
            color: #d97706
        }

        /* &#9472;&#9472; RIGHT PANEL &#9472;&#9472; */
        .cal-right {
            width: 280px;
            background: var(--white);
            border-left: 1px solid var(--gray-200);
            display: flex;
            flex-direction: column;
            overflow: hidden;
            flex-shrink: 0
        }

        .crp-tabs {
            display: flex;
            border-bottom: 1px solid var(--gray-200);
            flex-shrink: 0
        }

        .crp-tab {
            flex: 1;
            padding: 12px 8px;
            font-size: 11px;
            font-weight: 700;
            text-align: center;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            color: var(--gray-500);
            transition: all 150ms;
            font-family: var(--mono);
            letter-spacing: .5px;
            text-transform: uppercase
        }

            .crp-tab:hover {
                color: var(--black)
            }

            .crp-tab.active {
                color: var(--black);
                border-bottom-color: var(--black)
            }

        .crp-body {
            flex: 1;
            overflow-y: auto
        }

        .upcoming-item {
            padding: 14px 16px;
            border-bottom: 1px solid var(--gray-100);
            cursor: pointer;
            transition: background 150ms
        }

            .upcoming-item:hover {
                background: var(--gray-50)
            }

        .ui-date-badge {
            display: flex;
            gap: 10px;
            align-items: flex-start
        }

        .ui-date {
            background: var(--black);
            color: var(--white);
            width: 38px;
            flex-shrink: 0;
            border-radius: 3px;
            text-align: center;
            padding: 5px 0
        }

        .ui-dd {
            font-size: 17px;
            font-weight: 900;
            line-height: 1;
            font-family: var(--font)
        }

        .ui-mm {
            font-size: 9px;
            font-family: var(--mono);
            margin-top: 1px
        }

        .ui-name {
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 3px;
            line-height: 1.3;
            font-family: var(--font)
        }

        .ui-sub {
            font-size: 11px;
            color: var(--gray-500);
            font-family: var(--mono)
        }

        .ui-meta {
            display: flex;
            align-items: center;
            gap: 6px;
            margin-top: 6px
        }

        .ui-badge {
            font-size: 9px;
            font-weight: 700;
            padding: 2px 6px;
            border-radius: 2px;
            font-family: var(--mono)
        }

        .ub-open {
            background: #dcfce7;
            color: #15803d
        }

        .ub-full {
            background: #fee2e2;
            color: #dc2626
        }

        .ub-draft {
            background: var(--gray-100);
            color: var(--gray-500)
        }

        .ui-actions {
            display: flex;
            gap: 5px;
            margin-top: 8px
        }

        .btn-xs {
            padding: 4px 10px;
            border-radius: 2px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            border: 1px solid var(--gray-200);
            background: var(--white);
            font-family: var(--font);
            transition: all 150ms
        }

            .btn-xs:hover {
                border-color: var(--black)
            }

            .btn-xs.primary {
                background: var(--black);
                color: var(--white);
                border-color: var(--black)
            }

            .btn-xs.danger {
                color: var(--error);
                border-color: #fca5a5
            }

                .btn-xs.danger:hover {
                    background: #fef2f2
                }

        .stat-rp-row {
            padding: 14px 16px;
            border-bottom: 1px solid var(--gray-100);
            display: flex;
            align-items: center;
            gap: 12px
        }

        .stat-rp-icon {
            width: 36px;
            height: 36px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            flex-shrink: 0
        }

        .stat-rp-val {
            font-size: 20px;
            font-weight: 900;
            letter-spacing: -.5px;
            font-family: var(--font)
        }

        .stat-rp-lbl {
            font-size: 11px;
            color: var(--gray-500);
            font-family: var(--mono);
            text-transform: uppercase;
            letter-spacing: .5px
        }

        /* &#9472;&#9472; MODAL &#9472;&#9472; */
        .modal-overlay {
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,.5);
            z-index: 1000;
            display: none;
            align-items: center;
            justify-content: center
        }

            .modal-overlay.open {
                display: flex
            }

        .modal-box {
            background: var(--white);
            border-radius: 4px;
            width: 520px;
            max-width: 95%;
            max-height: 90vh;
            overflow-y: auto
        }

        .modal-hd {
            padding: 22px 28px;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            background: var(--white);
            z-index: 1
        }

        .modal-ttl {
            font-size: 18px;
            font-weight: 800;
            letter-spacing: -.5px;
            font-family: var(--font)
        }

        .modal-x {
            background: none;
            border: none;
            font-size: 20px;
            cursor: pointer;
            color: var(--gray-400);
            line-height: 1
        }

            .modal-x:hover {
                color: var(--black)
            }

        .modal-bd {
            padding: 24px 28px
        }

        .modal-ft {
            padding: 16px 28px;
            border-top: 1px solid var(--gray-200);
            display: flex;
            gap: 10px;
            justify-content: flex-end
        }

        .mf {
            margin-bottom: 18px
        }

            .mf label {
                display: block;
                font-size: 11px;
                font-weight: 700;
                margin-bottom: 7px;
                text-transform: uppercase;
                letter-spacing: .8px;
                color: var(--gray-700);
                font-family: var(--mono)
            }

            .mf input, .mf select {
                width: 100%;
                padding: 11px 14px;
                border: 1.5px solid var(--gray-200);
                border-radius: 4px;
                font-size: 14px;
                font-family: var(--font);
                background: var(--white);
                transition: border-color 200ms;
                outline: none;
                box-sizing: border-box
            }

                .mf input:focus, .mf select:focus {
                    border-color: var(--black)
                }

        .mf-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px
        }

        .type-btns {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px
        }

        .type-btn {
            padding: 10px;
            border: 1.5px solid var(--gray-200);
            border-radius: 4px;
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            text-align: center;
            transition: all 150ms;
            background: var(--white);
            font-family: var(--font)
        }

            .type-btn:hover {
                border-color: var(--gray-400)
            }

            .type-btn.sel {
                border-color: var(--black);
                background: var(--black);
                color: var(--white)
            }

        .btn-success, input[type="submit"].btn-success {
            background: var(--success);
            color: var(--white);
            border: none;
            padding: 9px 18px;
            border-radius: 4px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            font-family: var(--font);
            transition: all 200ms
        }

        /* Cal-page layout &#8212; d&#249;ng trong .main c&#7911;a Master */
        .cal-page {
            display: flex;
            flex-direction: column;
            height: calc(100vh - var(--navbar));
            overflow: hidden
        }

        /* Toast ri&#234;ng trang Calendar */
        .cal-toast {
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
            gap: 10px;
            border-left: 3px solid var(--success)
        }

            .cal-toast.show {
                transform: translateY(0);
                opacity: 1
            }

        @media(max-width:1200px) {
            .cal-right {
                display: none
            }
        }
    </style>
</asp:Content>

<%-- &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; TOPBAR PLACEHOLDER &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; --%>

<%-- &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; MAIN CONTENT &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; --%>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField ID="hfDeleteId" runat="server" />
    <asp:Button ID="btnDoDelete" runat="server" OnClick="btnDoDelete_Click" Text="" Style="display: none" CausesValidation="false" />
    <div class="main" style="margin-left: 260px">
        <div class="topbar">
            <div class="topbar-left">
                <button class="menu-toggle" type="button" onclick="document.getElementById('sidebar').classList.toggle('open')"></button>
                <div>
                    <div class="page-title">L&#7883;ch qu&#7843;n l&#253; s&#7921; ki&#7879;n</div>
                    <div class="page-breadcrumb">EventHub / L&#7883;ch s&#7921; ki&#7879;n</div>
                </div>
            </div>
            <div class="topbar-right">
            </div>
        </div>
        <div class="cal-page">

            <%-- CAL TOOLBAR --%>
            <div class="cal-toolbar">
                <div class="cal-nav-group">
                    <button class="cal-nav-btn" type="button" onclick="navigate(-1)">&#8592;</button>
                    <div class="cal-month-title" id="calTitle"></div>
                    <button class="cal-nav-btn" type="button" onclick="navigate(1)">&#8594;</button>
                    <button class="btn-today" type="button" onclick="goToday()">H&#212;M NAY</button>
                </div>
                <div class="view-toggle">
                    <button class="vt-btn active" id="vt-month" type="button" onclick="switchView('month')">TH&#193;NG</button>
                    <button class="vt-btn" id="vt-week" type="button" onclick="switchView('week')">TU&#7846;N</button>
                </div>
                <div class="cal-legend">
                    <div class="legend-item">
                        <div class="legend-dot" style="background: #000"></div>
                        Team Building
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background: #3b82f6"></div>
                        Workshop
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background: #10b981"></div>
                        &#272;&#224;o t&#7841;o
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background: #f59e0b"></div>
                        H&#7897;i th&#7843;o
                    </div>
                </div>
                <div style="display: flex; align-items: center; gap: 8px; margin-left: auto">
                    <asp:DropDownList ID="ddlTypeFilter" runat="server" CssClass="cal-type-filter" AutoPostBack="false">
                        <asp:ListItem Value="">T&#7845;t c&#7843; lo&#7841;i</asp:ListItem>
                        <asp:ListItem Value="tb">Team Building</asp:ListItem>
                        <asp:ListItem Value="workshop">Workshop</asp:ListItem>
                        <asp:ListItem Value="training">&#272;&#224;o t&#7841;o</asp:ListItem>
                        <asp:ListItem Value="seminar">H&#7897;i th&#7843;o</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <%-- CALENDAR BODY --%>
            <div class="cal-body">

                <%-- Month view --%>
                <div class="cal-month-view" id="monthView">
                    <div class="cal-weekdays">
                        <div class="cal-wd">Ch&#7911; nh&#7853;t</div>
                        <div class="cal-wd">Th&#7913; hai</div>
                        <div class="cal-wd">Th&#7913; ba</div>
                        <div class="cal-wd">Th&#7913; t&#432;</div>
                        <div class="cal-wd">Th&#7913; n&#259;m</div>
                        <div class="cal-wd">Th&#7913; s&#225;u</div>
                        <div class="cal-wd">Th&#7913; b&#7843;y</div>
                    </div>
                    <div class="cal-grid" id="calGrid"></div>
                </div>

                <%-- Week view --%>
                <div class="cal-week-view" id="weekView" style="display: none">
                    <div class="week-header" id="weekHeader"></div>
                    <div class="week-body" id="weekBody"></div>
                </div>

                <%-- Right panel --%>
                <div class="cal-right">
                    <div class="crp-tabs">
                        <div class="crp-tab active" onclick="switchRPanel(this,'upcoming')">S&#7855;p t&#7899;i</div>
                        <div class="crp-tab" onclick="switchRPanel(this,'stats')">Th&#7889;ng k&#234;</div>
                    </div>
                    <div class="crp-body" id="rpBody"></div>
                </div>

            </div>
        </div>

    </div>
    <%-- /.main --%>
    <%-- EVENT DETAIL MODAL --%>
    <div class="modal-overlay" id="detailModal" onclick="closeDetailModal(event)">
        <div class="modal-box" onclick="event.stopPropagation()">
            <div class="modal-hd">
                <div class="modal-ttl" id="detailTitle"></div>
                <button class="modal-x" type="button" onclick="closeDetailModal()">&#10005;</button>
            </div>
            <div class="modal-bd" id="detailBody"></div>
            <div class="modal-ft">
                <button class="btn-outline" type="button" onclick="closeDetailModal()">Dong</button>
                <button class="btn-outline" type="button" onclick="editEvent(currentDetailId)">Sua</button>
                <button class="btn-outline" type="button" style="color: #dc2626; border-color: #dc2626" onclick="deleteEventCmd(currentDetailId)">Xoa</button>
            </div>
        </div>
    </div>

    <div class="cal-toast" id="calToast"><span id="calToastMsg"></span></div>
</asp:Content>

<%-- &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; JAVASCRIPT &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; --%>
<asp:Content ID="ScriptContent" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        /* DATA tu server (load tu DB qua code-behind) */
        var eventsDB = <%= EventsJson %>;
        var allEvents = eventsDB; // bao luu danh sach goc

        /* Loc su kien theo loai (tu dropdown ddlTypeFilter) */
        function applyTypeFilter() {
            var dd = document.getElementById('<%= ddlTypeFilter.ClientID %>');
            var type = dd ? dd.value : '';
            if (!type) {
                eventsDB = allEvents.slice();
            } else {
                eventsDB = allEvents.filter(function (e) { return e.type === type; });
            }
            render();
        }

        var TYPE_PILL = { tb: 'ev-tb', workshop: 'ev-workshop', training: 'ev-training', seminar: 'ev-seminar' };
        var TYPE_WEEK = { tb: 'we-tb', workshop: 'we-workshop', training: 'we-training', seminar: 'we-seminar' };
        var TYPE_LABEL = { tb: 'Team Building', workshop: 'Workshop', training: '\u0110\xE0o t\u1EA1o', seminar: 'H\u1ED9i th\u1EA3o' };
        var TYPE_COLOR = { tb: '#000', workshop: '#3b82f6', training: '#10b981', seminar: '#f59e0b' };
        var MONTH_VI = ['Th\xE1ng 1', 'Th\xE1ng 2', 'Th\xE1ng 3', 'Th\xE1ng 4', 'Th\xE1ng 5', 'Th\xE1ng 6',
            'Th\xE1ng 7', 'Th\xE1ng 8', 'Th\xE1ng 9', 'Th\xE1ng 10', 'Th\xE1ng 11', 'Th\xE1ng 12'];
        var MM_SHORT = ['TH1', 'TH2', 'TH3', 'TH4', 'TH5', 'TH6', 'TH7', 'TH8', 'TH9', 'TH10', 'TH11', 'TH12'];
        var DAY_SHORT = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

        var today = new Date();
        var currentDate = new Date(today.getFullYear(), today.getMonth(), 1);
        var currentView = 'month';

        /* ?? HELPERS ?? */
        function pad(n) { return n < 10 ? '0' + n : '' + n; }
        function fmtDate(d) { return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()); }
        function todayStr() { return fmtDate(today); }

        /* ?? RENDER ?? */
        function render() {
            currentView === 'month' ? renderMonth() : renderWeek();
            renderRPanel('upcoming');
        }

        function renderMonth() {
            var yr = currentDate.getFullYear();
            var mo = currentDate.getMonth();
            document.getElementById('calTitle').textContent = MONTH_VI[mo] + ' ' + yr;

            var first = new Date(yr, mo, 1).getDay();           /* 0=Sun */
            var lastDate = new Date(yr, mo + 1, 0).getDate();
            var prevLast = new Date(yr, mo, 0).getDate();
            var ts = todayStr();
            var html = '';

            /* Prev-month filler */
            for (var i = first - 1; i >= 0; i--) {
                html += '<div class="cal-cell other-month"><div class="day-num-wrap"><span class="day-num">' + (prevLast - i) + '</span></div></div>';
            }
            /* Current month */
            for (var d = 1; d <= lastDate; d++) {
                var ds = fmtDate(new Date(yr, mo, d));
                var isT = ds === ts;
                var evs = eventsDB.filter(function (e) { return e.start <= ds && e.end >= ds; });
                html += '<div class="cal-cell' + (isT ? ' today' : '') + '">';
                html += '<div class="day-num-wrap"><span class="day-num">' + d + '</span></div>';
                html += '<div class="day-events">';
                evs.slice(0, 2).forEach(function (e) {
                    html += '<div class="ev-pill ' + TYPE_PILL[e.type] + '" onclick="event.stopPropagation();showDetail(' + e.id + ')">' + e.name + '</div>';
                });
                if (evs.length > 2) html += '<div class="ev-more">+' + (evs.length - 2) + ' kh\xE1c</div>';
                html += '</div></div>';
            }
            /* Next-month filler */
            var total = first + lastDate;
            for (var n = 1; n <= (7 - total % 7) % 7; n++) {
                html += '<div class="cal-cell other-month"><div class="day-num-wrap"><span class="day-num">' + n + '</span></div></div>';
            }
            document.getElementById('calGrid').innerHTML = html;
        }

        function renderWeek() {
            /* Find Monday of current week */
            var base = new Date(currentDate);
            var dow = base.getDay();
            base.setDate(base.getDate() - (dow === 0 ? 6 : dow - 1));
            var ts = todayStr();
            var hdr = '<div class="week-time-col"></div>';
            var days = [];
            for (var i = 0; i < 7; i++) {
                var d = new Date(base); d.setDate(base.getDate() + i);
                days.push(d);
                var ds = fmtDate(d);
                var isT = ds === ts;
                hdr += '<div class="week-day-head"><div class="wdh-name">' + DAY_SHORT[d.getDay()] + '</div>'
                    + '<div class="wdh-num' + (isT ? ' today' : '') + '">' + d.getDate() + '</div></div>';
            }
            document.getElementById('weekHeader').innerHTML = hdr;

            var body = '<div class="week-time-labels">';
            for (var h = 6; h < 22; h++) body += '<div class="time-label">' + pad(h) + ':00</div>';
            body += '</div>';

            days.forEach(function (d) {
                var ds = fmtDate(d);
                var evs = eventsDB.filter(function (e) { return e.start <= ds && e.end >= ds; });
                body += '<div class="week-col">';
                for (var h = 0; h < 16; h++) body += '<div class="week-hour-line" style="top:' + (h * 60) + 'px"></div>';
                evs.forEach(function (e) {
                    var t = e.time.split('\u2013');
                    var sh = parseInt(t[0].split(':')[0], 10), sm = parseInt(t[0].split(':')[1], 10);
                    var et = (t[1] || '17:00').split(':');
                    var eh = parseInt(et[0], 10), em = parseInt(et[1], 10);
                    var top = (sh - 6) * 60 + sm;
                    var height = Math.max((eh - sh) * 60 + (em - sm), 30);
                    body += '<div class="week-event ' + TYPE_WEEK[e.type] + '" style="top:' + top + 'px;height:' + height + 'px" onclick="event.stopPropagation();showDetail(' + e.id + ')">'
                        + '<div>' + e.name + '</div>'
                        + '<div style="font-size:10px;opacity:.7">' + e.time + '</div></div>';
                });
                body += '</div>';
            });
            document.getElementById('weekBody').innerHTML = body;
        }

        function renderRPanel(tab) {
            var el = document.getElementById('rpBody');
            if (tab === 'stats') {
                var total = eventsDB.length;
                var open = eventsDB.filter(function (e) { return e.status === 'open'; }).length;
                var full = eventsDB.filter(function (e) { return e.taken >= e.slots; }).length;
                var totalTaken = eventsDB.reduce(function (s, e) { return s + e.taken; }, 0);
                var html = '';
                html += statRpRow('#f5f5f5', '', total, 'T\u1ED5ng s\u1EF1 ki\u1EC7n');
                html += statRpRow('#dcfce7', '', open, '\u0110ang m\u1EDF \u0110K');
                html += statRpRow('#fee2e2', '', full, '\u0110\xE3 \u0111\xF3ng');
                html += statRpRow('#dbeafe', '', totalTaken, 'T\u1ED5ng l\u01B0\u1EE3t \u0110K');
                html += '<div style="padding:16px"><div style="font-size:12px;font-weight:700;color:var(--gray-500);font-family:var(--mono);text-transform:uppercase;letter-spacing:1px;margin-bottom:12px">Ph\xE2n b\u1ED5 lo\u1EA1i</div>';
                ['tb', 'workshop', 'training', 'seminar'].forEach(function (t) {
                    var cnt = eventsDB.filter(function (e) { return e.type === t; }).length;
                    var pct = total > 0 ? (cnt / total * 100).toFixed(1) : 0;
                    html += '<div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;font-size:12px;font-family:var(--font)">'
                        + '<div style="width:8px;height:8px;background:' + TYPE_COLOR[t] + ';border-radius:2px;flex-shrink:0"></div>'
                        + '<div style="flex:1">' + TYPE_LABEL[t] + '</div>'
                        + '<div style="height:4px;width:' + pct + '%;background:' + TYPE_COLOR[t] + ';border-radius:2px;min-width:4px"></div>'
                        + '<div style="font-family:var(--mono);font-weight:700;min-width:20px;text-align:right">' + cnt + '</div></div>';
                });
                html += '</div>';
                el.innerHTML = html;
                return;
            }
            /* Upcoming tab */
            var ts = todayStr();
            var upcoming = eventsDB.filter(function (e) { return e.start >= ts; })
                .sort(function (a, b) { return a.start.localeCompare(b.start); });
            el.innerHTML = upcoming.map(function (e) {
                var p = e.start.split('-');
                var sc = e.taken >= e.slots ? 'ub-full' : e.status === 'draft' ? 'ub-draft' : 'ub-open';
                var sl = e.taken >= e.slots ? '\u0110\u1EA7y' : e.status === 'draft' ? 'Nh\xE1p' : 'M\u1EDF';
                return '<div class="upcoming-item" onclick="showDetail(' + e.id + ')">'
                    + '<div class="ui-date-badge">'
                    + '<div class="ui-date"><div class="ui-dd">' + p[2] + '</div><div class="ui-mm">' + MM_SHORT[parseInt(p[1], 10) - 1] + '</div></div>'
                    + '<div><div class="ui-name">' + e.name + '</div>'
                    + '<div class="ui-sub">' + e.loc + '</div>'
                    + '<div class="ui-sub">&#9200; ' + e.time + '</div>'
                    + '<div class="ui-meta"><span class="ui-badge ' + sc + '">' + sl + '</span>'
                    + '<span style="font-size:10px;font-family:var(--mono);color:var(--gray-500)">' + e.taken + '/' + e.slots + ' ng\u01B0\u1EDDi</span></div>'
                    + '<div class="ui-actions">'
                    + '<button class="btn-xs" type="button" onclick="event.stopPropagation();editEvent(' + e.id + ')">Sua</button>'
                    + '<button class="btn-xs danger" type="button" onclick="event.stopPropagation();deleteEventCmd(' + e.id + ')">Xoa</button>'
                    + '</div></div></div></div>';
            }).join('');
        }

        function statRpRow(bg, icon, val, lbl) {
            var iconHtml = icon ? '<div class="stat-rp-icon" style="background:' + bg + '">' + icon + '</div>' : '';
            return '<div class="stat-rp-row">' + iconHtml
                + '<div><div class="stat-rp-val">' + val + '</div><div class="stat-rp-lbl">' + lbl + '</div></div></div>';
        }

        function switchRPanel(el, tab) {
            document.querySelectorAll('.crp-tab').forEach(function (t) { t.classList.remove('active'); });
            el.classList.add('active');
            renderRPanel(tab);
        }

        /* ?? NAVIGATION ?? */
        function navigate(dir) {
            if (currentView === 'month') currentDate.setMonth(currentDate.getMonth() + dir);
            else currentDate.setDate(currentDate.getDate() + dir * 7);
            render();
        }
        function goToday() {
            currentDate = new Date(today.getFullYear(), today.getMonth(), 1);
            render();
        }
        function switchView(v) {
            currentView = v;
            document.getElementById('vt-month').classList.toggle('active', v === 'month');
            document.getElementById('vt-week').classList.toggle('active', v === 'week');
            document.getElementById('monthView').style.display = v === 'month' ? '' : 'none';
            document.getElementById('weekView').style.display = v === 'week' ? '' : 'none';
            render();
        }

        /* Chinh sua su kien -> redirect sang AdminEventForm voi id */
        function editEvent(id) {
            window.location.href = 'AdminEventForm.aspx?id=' + id;
        }

        /* Xoa su kien - dung asp:Button an de trigger postback chuan ASP.NET */
        function deleteEventCmd(id) {
            console.log('[DELETE] Click id=' + id);
            if (!confirm('Ban co chac muon xoa su kien nay?')) {
                console.log('[DELETE] Cancelled');
                return;
            }
            var hf = document.getElementById('<%= hfDeleteId.ClientID %>');
            var btn = document.getElementById('<%= btnDoDelete.ClientID %>');
            console.log('[DELETE] hf=', hf, ' btn=', btn);
            if (!hf || !btn) {
                alert('Loi: khong tim thay control xoa. Reload trang va thu lai.');
                return;
            }
            hf.value = id;
            console.log('[DELETE] hf.value=' + hf.value + ', click button...');
            btn.click();
        }

        /* ?? DETAIL ?? */
        var currentDetailId = 0;
        function showDetail(id) {
            var e = eventsDB.find(function (x) { return x.id === id; });
            if (!e) return;
            currentDetailId = id;
            var pct = e.slots > 0 ? Math.round(e.taken / e.slots * 100) : 0;
            document.getElementById('detailTitle').textContent = e.name;
            document.getElementById('detailBody').innerHTML =
                '<div style="display:flex;flex-direction:column;gap:14px">'
                + '<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">'
                + dField('Ng\xE0y', e.start + (e.end !== e.start ? ' \u2192 ' + e.end : ''))
                + dField('Gi\u1EDD', e.time)
                + dField('\u0110\u1ECBa \u0111i\u1EC3m', e.loc)
                + dField('Tr\u1EA1ng th\xE1i', e.status === 'open' ? 'M\u1EDF \u0111\u0103ng k\xFD' : '\u0110\xF3ng')
                + '</div>'
                + '<div><div style="font-size:10px;font-weight:700;font-family:var(--mono);color:var(--gray-500);text-transform:uppercase;letter-spacing:.8px;margin-bottom:8px">Ng\u01B0\u1EDDi \u0111\u0103ng k\xFD</div>'
                + '<div style="display:flex;align-items:center;gap:12px">'
                + '<div style="flex:1;height:8px;background:var(--gray-200);border-radius:4px;overflow:hidden"><div style="height:100%;background:' + (pct >= 100 ? 'var(--error)' : pct >= 80 ? 'var(--warning)' : 'var(--success)') + ';border-radius:4px;width:' + Math.min(pct, 100) + '%"></div></div>'
                + '<div style="font-size:14px;font-weight:700;font-family:var(--mono)">' + e.taken + '/' + e.slots + ' (' + pct + '%)</div>'
                + '</div></div></div>';
            document.getElementById('detailModal').classList.add('open');
        }
        function dField(lbl, val) {
            return '<div><div style="font-size:10px;font-weight:700;font-family:var(--mono);color:var(--gray-500);text-transform:uppercase;letter-spacing:.8px;margin-bottom:4px">' + lbl + '</div><div style="font-size:14px;font-weight:600;font-family:var(--font)">' + val + '</div></div>';
        }
        function closeDetailModal(e) {
            if (!e || e.target === document.getElementById('detailModal'))
                document.getElementById('detailModal').classList.remove('open');
        }
        function deleteEvent(id) {
            var idx = eventsDB.findIndex(function (e) { return e.id === id; });
            if (idx > -1) { var n = eventsDB[idx].name; eventsDB.splice(idx, 1); render(); showCalToast('\u0110\xE3 x\xF3a: ' + n); }
        }
        function exportCal() { showCalToast('\u0110ang xu\u1EA5t l\u1ECBch d\u1EA1ng .ics...'); }
        function showCalToast(msg) {
            document.getElementById('calToastMsg').textContent = msg;
            var t = document.getElementById('calToast');
            t.classList.add('show');
            setTimeout(function () { t.classList.remove('show'); }, 3000);
        }

        /* Init: render lan dau + bind filter dropdown */
        render();

        (function () {
            var dd = document.getElementById('<%= ddlTypeFilter.ClientID %>');
            if (dd) dd.addEventListener('change', applyTypeFilter);
        })();
    </script>
</asp:Content>
