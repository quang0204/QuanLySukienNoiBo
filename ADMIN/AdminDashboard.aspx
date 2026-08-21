<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs"
    Inherits="QuanLySuKien.AdminDashboard" MasterPageFile="~/Admin.Master"
    ResponseEncoding="UTF-8" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    Dashboard - EventHub Admin
</asp:Content>

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
            --gray-800: #1e1e1e;
            --gray-700: #2d2d2d;
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
            --sidebar: 260px;
            --navbar: 64px;
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
            flex-direction: column;
            min-height: 100vh
        }

        /* TOPBAR */
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

        .btn-primary {
            background: var(--black);
            color: var(--white);
            border: none;
            padding: 9px 18px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            font-family: var(--font);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 200ms
        }

            .btn-primary:hover {
                opacity: .85
            }

        .menu-toggle {
            display: none;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 20px
        }

        @media(max-width:900px) {
            .main {
                margin-left: 0
            }

            .menu-toggle {
                display: block
            }

            .charts-row {
                grid-template-columns: 1fr
            }
        }

        @media(max-width:600px) {
            .stats-grid {
                grid-template-columns: 1fr
            }

            .content {
                padding: 20px
            }
        }

        /* CONTENT */
        .content {
            padding: 32px;
            flex: 1
        }

        /* Stats */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4,1fr);
            gap: 20px;
            margin-bottom: 32px
        }

        @media(max-width:1200px) {
            .stats-grid {
                grid-template-columns: repeat(2,1fr)
            }
        }

        .stat-card {
            background: var(--white);
            border: 1px solid var(--gray-200);
            padding: 24px;
            position: relative;
            overflow: hidden
        }

            .stat-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 3px;
                background: var(--black)
            }

            .stat-card.success::before {
                background: var(--success)
            }

            .stat-card.warning::before {
                background: var(--warning)
            }

            .stat-card.info::before {
                background: var(--info)
            }

        .stat-label {
            font-size: 12px;
            font-weight: 600;
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: .8px;
            margin-bottom: 12px;
            font-family: var(--mono)
        }

        .stat-value {
            font-size: 40px;
            font-weight: 900;
            letter-spacing: -2px;
            line-height: 1
        }

        .stat-change {
            display: flex;
            align-items: center;
            gap: 6px;
            margin-top: 10px;
            font-size: 12px
        }

        .change-up {
            color: var(--success)
        }

        .change-down {
            color: var(--error)
        }

        .change-neutral {
            color: var(--gray-500)
        }

        /* Charts */
        .charts-row {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 20px;
            margin-bottom: 32px
        }

        .chart-card {
            background: var(--white);
            border: 1px solid var(--gray-200);
            padding: 24px
        }

        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px
        }

        .chart-title {
            font-size: 15px;
            font-weight: 700
        }

        .chart-legend {
            display: flex;
            gap: 16px
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            color: var(--gray-600)
        }

        .legend-dot {
            width: 8px;
            height: 8px;
            border-radius: 2px
        }

        .donut-legend {
            margin-top: 16px;
            width: 100%
        }

        .donut-legend-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 6px 0;
            border-bottom: 1px solid var(--gray-100);
            font-size: 12px
        }

        .donut-legend-left {
            display: flex;
            align-items: center;
            gap: 8px
        }

        .dl-dot {
            width: 8px;
            height: 8px;
            border-radius: 2px;
            flex-shrink: 0
        }

        .dl-val {
            font-weight: 700;
            font-family: var(--mono)
        }

        /* Table */
        .table-card {
            background: var(--white);
            border: 1px solid var(--gray-200);
            overflow: hidden;
            margin-bottom: 32px
        }

        .table-header {
            padding: 20px 24px;
            border-bottom: 1px solid var(--gray-200);
            display: flex;
            justify-content: space-between;
            align-items: center
        }

            .table-header h3 {
                font-size: 15px;
                font-weight: 700
            }

        .table-wrap {
            overflow-x: auto
        }

        table {
            width: 100%;
            border-collapse: collapse
        }

        th {
            padding: 12px 20px;
            font-size: 11px;
            font-weight: 600;
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: .8px;
            text-align: left;
            font-family: var(--mono);
            background: var(--gray-50);
            border-bottom: 1px solid var(--gray-200);
            white-space: nowrap
        }

        td {
            padding: 14px 20px;
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

        .badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 8px;
            font-size: 11px;
            font-weight: 700;
            font-family: var(--font);
            white-space: nowrap
        }

        .badge-open {
            background: #dcfce7;
            color: #15803d
        }

        .badge-closed {
            background: #fee2e2;
            color: #dc2626
        }

        .badge-soon {
            background: #fef3c7;
            color: #d97706
        }

        .progress-bar {
            height: 4px;
            background: var(--gray-200);
            overflow: hidden;
            width: 80px;
            flex-shrink: 0
        }

        .progress-fill {
            height: 100%;
            background: var(--black);
            transition: width .3s
        }

        .btn-sm {
            padding: 5px 12px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            border: 1px solid var(--gray-200);
            background: var(--white);
            font-family: var(--font);
            transition: all 150ms;
            text-decoration: none;
            color: inherit
        }

            .btn-sm:hover {
                border-color: var(--black);
                background: var(--gray-50)
            }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hfBarLabels" runat="server" />
    <asp:HiddenField ID="hfBarReg" runat="server" />
    <asp:HiddenField ID="hfBarAtt" runat="server" />
    <asp:HiddenField ID="hfDonutLabels" runat="server" />
    <asp:HiddenField ID="hfDonutVals" runat="server" />

    <div class="main">
        <div class="topbar">
            <div class="topbar-left">
                <button class="menu-toggle" type="button" onclick="document.getElementById('sidebar').classList.toggle('open')">&#9776;</button>
                <div>
                    <div class="page-title">Dashboard</div>
                    <div class="page-breadcrumb">EventHub / T&#7893;ng quan</div>
                </div>
            </div>
            <div class="topbar-right">
                <asp:Button ID="btnCreateEvent" runat="server" Text="+ T&#7841;o s&#7921; ki&#7879;n"
                    CssClass="btn-primary" OnClick="btnCreateEvent_Click" />
            </div>
        </div>

        <div class="content">

            <%-- STAT CARDS --%>
            <div class="stats-grid">

                <div class="stat-card">
                    <div class="stat-label">T&#7893;ng s&#7921; ki&#7879;n</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalEvents" runat="server" Text="&#8212;" />
                    </div>
                    <div class="stat-change">
                        <asp:Label ID="lblEventDelta" runat="server" CssClass="change-neutral" Text="&#273;ang t&#7843;i..." />
                    </div>
                </div>

                <div class="stat-card success">
                    <div class="stat-label">T&#7893;ng ng&#432;&#7901;i tham gia</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalParticipants" runat="server" Text="&#8212;" />
                    </div>
                    <div class="stat-change">
                        <asp:Label ID="lblParticipantDelta" runat="server" CssClass="change-neutral" Text="&#273;ang t&#7843;i..." />
                        <span style="color: var(--gray-500)">so v&#7899;i th&#225;ng tr&#432;&#7899;c</span>
                    </div>
                </div>

                <div class="stat-card warning">
                    <div class="stat-label">T&#7881; l&#7879; tham d&#7921;</div>
                    <div class="stat-value">
                        <asp:Label ID="lblAttendRate" runat="server" Text="&#8212;" />
                    </div>
                    <div class="stat-change">
                        <span style="color: var(--gray-500)">&#273;i&#7875;m danh / &#273;&#227; duy&#7879;t</span>
                    </div>
                </div>

                <div class="stat-card info">
                    <div class="stat-label">S&#7921; ki&#7879;n th&#225;ng n&#224;y</div>
                    <div class="stat-value">
                        <asp:Label ID="lblThisMonth" runat="server" Text="&#8212;" />
                    </div>
                    <div class="stat-change">
                        <span style="color: var(--gray-500)">trong th&#225;ng hi&#7879;n t&#7841;i</span>
                    </div>
                </div>

            </div>

            <%-- CHARTS ROW --%>
            <div class="charts-row">

                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">Ng&#432;&#7901;i tham gia theo th&#225;ng &#8212; <span id="chartYear"></span></div>
                        <div class="chart-legend">
                            <div class="legend-item">
                                <div class="legend-dot" style="background: var(--black)"></div>
                                &#272;&#259;ng k&#253;
                            </div>
                            <div class="legend-item">
                                <div class="legend-dot" style="background: var(--gray-300)"></div>
                                Th&#7921;c d&#7921;
                            </div>
                        </div>
                    </div>
                    <div style="display: flex; gap: 0; height: 200px">
                        <div id="yAxis" style="width: 36px; display: flex; flex-direction: column; justify-content: space-between; align-items: flex-end; padding-right: 8px; padding-bottom: 24px"></div>
                        <div style="flex: 1; display: flex; flex-direction: column; gap: 0">
                            <div id="barArea" style="flex: 1; position: relative; display: flex; align-items: flex-end; gap: 4px"></div>
                            <div id="xAxis" style="height: 24px; display: flex; gap: 4px"></div>
                        </div>
                    </div>
                </div>

                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">Lo&#7841;i s&#7921; ki&#7879;n</div>
                    </div>
                    <div style="display: flex; justify-content: center">
                        <svg id="donutSvg" viewBox="0 0 160 160" style="width: 160px; height: 160px">
                            <circle cx="80" cy="80" r="60" fill="none" stroke="#e5e5e5" stroke-width="20" />
                            <text id="donutTotal" x="80" y="76" text-anchor="middle"
                                font-family="Arial" font-size="24" font-weight="900">0</text>
                            <text x="80" y="94" text-anchor="middle"
                                font-family="Arial" font-size="9" fill="#737373">S&#7920; KI&#7878;N</text>
                        </svg>
                    </div>
                    <div id="donutLegend" class="donut-legend"></div>
                </div>

            </div>

            <%-- RECENT EVENTS TABLE --%>
            <div class="table-card">
                <div class="table-header">
                    <h3>S&#7921; ki&#7879;n g&#7847;n &#273;&#226;y</h3>
                    <asp:HyperLink ID="lnkViewAll" runat="server"
                        NavigateUrl="~/ADMIN/AdminEvents.aspx"
                        CssClass="btn-sm">Xem t&#7845;t c&#7843; &#8594;</asp:HyperLink>
                </div>
                <div class="table-wrap">
                    <asp:GridView ID="gvRecent" runat="server"
                        AutoGenerateColumns="False"
                        GridLines="None"
                        ShowHeaderWhenEmpty="True"
                        EmptyDataText="Ch&#432;a c&#243; s&#7921; ki&#7879;n n&#224;o."
                        OnRowCommand="gvRecent_RowCommand">
                        <Columns>

                            <asp:BoundField DataField="TenSuKien" HeaderText="T&#202;N S&#7920; KI&#7878;N" />

                            <asp:BoundField DataField="NgayToChuc" HeaderText="NG&#192;Y"
                                DataFormatString="{0:dd/MM/yyyy}" />

                            <asp:BoundField DataField="LoaiSuKien" HeaderText="LO&#7840;I" />

                            <asp:TemplateField HeaderText="&#272;&#258;NG K&#221; / S&#7912;C CH&#7912;A">
                                <ItemTemplate>
                                    <div style="display: flex; align-items: center; gap: 8px">
                                        <div class="progress-bar">
                                            <div class="progress-fill" style='width: <%# Eval("PhanTram") %>%'></div>
                                        </div>
                                        <span style="font-size: 12px; font-family: var(--mono); white-space: nowrap">
                                            <%# Eval("SoDangKy") %>/<%# Eval("SucChua") %>
                                        </span>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="T&#204;NH TR&#7840;NG">
                                <ItemTemplate>
                                    <span class='badge badge-<%# Eval("TrangThaiClass") %>'>
                                        <asp:Literal runat="server" Text='<%# Eval("TrangThaiText") %>' Mode="PassThrough" />
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="H&#192;NH &#272;&#7896;NG">
                                <ItemTemplate>
                                    <div style="display: flex; gap: 8px">
                                        <asp:LinkButton runat="server" CssClass="btn-sm"
                                            CommandName="EditEv"
                                            CommandArgument='<%# Eval("MaSuKien") %>'>S&#7917;a</asp:LinkButton>
                                        <asp:LinkButton runat="server" CssClass="btn-sm"
                                            CommandName="ViewEv"
                                            CommandArgument='<%# Eval("MaSuKien") %>'>Xem</asp:LinkButton>
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
        (function () {
            function hf(id) {
                var el = document.getElementById(id);
                try { return el && el.value ? JSON.parse(el.value) : []; }
                catch (e) { return []; }
            }

            var months = hf('<%= hfBarLabels.ClientID %>');
            var reg = hf('<%= hfBarReg.ClientID %>');
            var att = hf('<%= hfBarAtt.ClientID %>');
            var dLabels = hf('<%= hfDonutLabels.ClientID %>');
            var dVals = hf('<%= hfDonutVals.ClientID %>');

            var yearEl = document.getElementById('chartYear');
            if (yearEl) yearEl.textContent = new Date().getFullYear();

            if (!months.length) {
                months = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
                reg = [80, 120, 95, 140, 180, 160, 200, 175, 140, 190, 220, 250];
                att = [70, 105, 80, 120, 155, 140, 180, 150, 125, 170, 200, 230];
            }

            /* BAR CHART */
            var barArea = document.getElementById('barArea');
            var xAxis = document.getElementById('xAxis');
            var yAxisEl = document.getElementById('yAxis');

            if (barArea && xAxis && yAxisEl) {
                var maxVal = Math.max.apply(null, reg.concat(att)) || 1;
                var step = maxVal <= 10 ? 2 : maxVal <= 50 ? 10 : maxVal <= 200 ? 50 : 100;
                var ceiling = Math.ceil(maxVal / step) * step;

                var yLevels = 5;
                for (var yi = yLevels; yi >= 0; yi--) {
                    var lbl = document.createElement('div');
                    lbl.textContent = Math.round(ceiling * yi / yLevels);
                    lbl.style.cssText = 'font-size:10px;color:#a3a3a3;font-family:var(--mono);line-height:1';
                    yAxisEl.appendChild(lbl);
                }

                for (var gi = 0; gi <= yLevels; gi++) {
                    var line = document.createElement('div');
                    line.style.cssText = 'position:absolute;left:0;right:0;bottom:' + (gi / yLevels * 100) + '%;height:1px;background:' + (gi === 0 ? '#d4d4d4' : '#f0f0f0') + ';pointer-events:none';
                    barArea.appendChild(line);
                }

                months.forEach(function (m, i) {
                    var hReg = ceiling ? (reg[i] / ceiling * 100) : 0;
                    var hAtt = ceiling ? (att[i] / ceiling * 100) : 0;

                    var b1 = document.createElement('div');
                    b1.style.cssText = 'width:42%;background:#000;border-radius:2px 2px 0 0;height:' + hReg + '%;min-height:' + (reg[i] > 0 ? '2' : '0') + 'px;transition:opacity 200ms;cursor:pointer;position:relative';
                    b1.title = m + ' \u2013 \u0110\u0103ng k\u00FD: ' + reg[i];
                    if (reg[i] > 0) {
                        var v1 = document.createElement('div');
                        v1.textContent = reg[i];
                        v1.style.cssText = 'position:absolute;top:-16px;left:50%;transform:translateX(-50%);font-size:9px;font-weight:700;color:#000;font-family:var(--mono);white-space:nowrap';
                        b1.appendChild(v1);
                    }

                    var b2 = document.createElement('div');
                    b2.style.cssText = 'width:42%;background:#d4d4d4;border-radius:2px 2px 0 0;height:' + hAtt + '%;min-height:' + (att[i] > 0 ? '2' : '0') + 'px;transition:opacity 200ms;cursor:pointer;position:relative';
                    b2.title = m + ' \u2013 Th\u1EF1c d\u1EF1: ' + att[i];
                    if (att[i] > 0) {
                        var v2 = document.createElement('div');
                        v2.textContent = att[i];
                        v2.style.cssText = 'position:absolute;top:-16px;left:50%;transform:translateX(-50%);font-size:9px;font-weight:700;color:#737373;font-family:var(--mono);white-space:nowrap';
                        b2.appendChild(v2);
                    }

                    [b1, b2].forEach(function (b) { b.onmouseenter = function () { this.style.opacity = '.65' }; b.onmouseleave = function () { this.style.opacity = '1' }; });

                    var pair = document.createElement('div');
                    pair.style.cssText = 'width:100%;display:flex;justify-content:center;align-items:flex-end;gap:2px;height:100%';
                    pair.appendChild(b1); pair.appendChild(b2);

                    var grp = document.createElement('div');
                    grp.style.cssText = 'flex:1;display:flex;flex-direction:column;align-items:center;justify-content:flex-end;height:100%;position:relative';
                    grp.appendChild(pair);
                    barArea.appendChild(grp);

                    var xlbl = document.createElement('div');
                    xlbl.textContent = m;
                    xlbl.style.cssText = 'flex:1;text-align:center;font-size:10px;color:#737373;font-family:var(--mono);line-height:24px';
                    xAxis.appendChild(xlbl);
                });
            }

            /* DONUT CHART */
            var COLORS = ['#000', '#737373', '#d4d4d4', '#a3a3a3', '#404040'];
            var svg = document.getElementById('donutSvg');
            var legend = document.getElementById('donutLegend');
            var totalEl = document.getElementById('donutTotal');

            if (!dLabels.length) {
                dLabels = ['Team Building', 'Workshop', '\u0110\u00E0o t\u1EA1o', 'H\u1ED9i th\u1EA3o'];
                dVals = [40, 25, 21, 14];
            }
            if (totalEl) totalEl.textContent = dLabels.length;

            var R = 60, CX = 80, CY = 80, SW = 20;
            var circ = 2 * Math.PI * R, offset = 0;

            dVals.forEach(function (pct, i) {
                var dash = (pct / 100) * circ, gap = circ - dash;
                var c = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
                c.setAttribute('cx', CX); c.setAttribute('cy', CY); c.setAttribute('r', R);
                c.setAttribute('fill', 'none');
                c.setAttribute('stroke', COLORS[i % COLORS.length]);
                c.setAttribute('stroke-width', SW);
                c.setAttribute('stroke-dasharray', dash + ' ' + gap);
                c.setAttribute('stroke-dashoffset', -(offset / 100 * circ));
                c.setAttribute('transform', 'rotate(-90 ' + CX + ' ' + CY + ')');
                c.style.cursor = 'pointer';
                c.title = dLabels[i] + ': ' + pct + '%';
                svg.insertBefore(c, svg.querySelector('text'));
                offset += pct;

                if (legend) {
                    var row = document.createElement('div');
                    row.className = 'donut-legend-item';
                    row.innerHTML = '<div class="donut-legend-left"><div class="dl-dot" style="background:' + COLORS[i % COLORS.length] + '"></div>' + dLabels[i] + '</div><div class="dl-val">' + pct + '%</div>';
                    legend.appendChild(row);
                }
            });

        })();
    </script>
</asp:Content>
