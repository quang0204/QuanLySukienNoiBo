<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminEvents.aspx.cs"
    Inherits="QuanLySuKien.AdminEvents" MasterPageFile="~/Admin.Master"
    ResponseEncoding="UTF-8" %>

<%-- &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; TITLE &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; --%>
<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    Qu&#7843;n l&#253; s&#7921; ki&#7879;n - EventHub Admin
</asp:Content>

<%-- &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; HEAD / CSS &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; --%>
<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* -- MAIN & TOPBAR -- */
.main{margin-left:var(--sidebar);flex:1;display:flex;flex-direction:column;min-height:100vh}
.topbar{height:var(--navbar);background:var(--white);border-bottom:1px solid var(--gray-200);display:flex;align-items:center;justify-content:space-between;padding:0 32px;position:sticky;top:0;z-index:50}
.topbar-left{display:flex;align-items:center;gap:16px}
.page-title{font-size:18px;font-weight:700;letter-spacing:-.3px}
.page-breadcrumb{font-size:12px;color:var(--gray-500);font-family:var(--mono)}
.topbar-right{display:flex;align-items:center;gap:16px}
.topbar-btn{width:36px;height:36px;border:1px solid var(--gray-200);border-radius:4px;display:flex;align-items:center;justify-content:center;cursor:pointer;background:var(--white);font-size:16px;transition:all 200ms;position:relative}
.topbar-btn:hover{border-color:var(--black)}
.menu-toggle{display:none;background:none;border:none;cursor:pointer;font-size:20px;padding:4px}
@media(max-width:900px){
  .sidebar{transform:translateX(-100%)}
  .sidebar.open{transform:translateX(0)}
  .main{margin-left:0!important}
  .menu-toggle{display:block}
}

/* &#9472;&#9472; STAT CARDS &#9472;&#9472; */
.stat-row{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px}
.stat-card{background:var(--white);border:1px solid var(--gray-200);padding:20px 22px;display:flex;align-items:center;gap:16px}
.stat-icon-box{width:44px;height:44px;display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0}
.stat-val{font-size:26px;font-weight:900;letter-spacing:-1px;line-height:1;font-family:var(--font)}
.stat-lbl{font-size:11px;font-family:var(--mono);color:var(--gray-500);text-transform:uppercase;letter-spacing:.5px;margin-top:3px}
.stat-delta{font-size:11px;font-weight:700;font-family:var(--mono);margin-top:4px}
.delta-up{color:var(--success)}
.delta-down{color:var(--error)}

/* &#9472;&#9472; FILTER BAR &#9472;&#9472; */
.filter-bar{background:var(--white);border:1px solid var(--gray-200);padding:16px 20px;margin-bottom:0;display:flex;align-items:center;gap:12px;flex-wrap:wrap}
.search-box{display:flex;align-items:center;gap:8px;border:1.5px solid var(--gray-200);padding:9px 14px;background:var(--white);min-width:280px;flex:1;max-width:360px;transition:border-color 150ms}
.search-box:focus-within{border-color:var(--black)}
.search-box input[type="text"]{border:none;background:transparent;font-size:14px;font-family:var(--font);outline:none;width:100%;color:var(--black)}
.search-box input[type="text"]::placeholder{color:var(--gray-400)}
.filter-sep{width:1px;height:28px;background:var(--gray-200);flex-shrink:0}
.fselect,select.fselect{padding:9px 12px;border:1.5px solid var(--gray-200);font-size:13px;font-family:var(--font);background:var(--white);cursor:pointer;outline:none;transition:border-color 150ms;color:var(--black)}
.fselect:focus{border-color:var(--black)}
.filter-tags{display:flex;gap:6px;flex-wrap:wrap;margin-left:auto}
.ftag{padding:5px 12px;font-size:12px;font-weight:700;font-family:var(--mono);cursor:pointer;border:1.5px solid var(--gray-200);background:var(--white);transition:all 150ms;text-transform:uppercase;letter-spacing:.3px;color:var(--black)}
.ftag:hover{border-color:var(--black)}
.ftag.active-all{background:var(--black);color:var(--white);border-color:var(--black)}
.ftag.active-open{background:#dcfce7;color:#15803d;border-color:#bbf7d0}
.ftag.active-upcoming{background:#fef3c7;color:#d97706;border-color:#fde68a}
.ftag.active-closed{background:#fee2e2;color:#dc2626;border-color:#fecaca}
.ftag.active-draft{background:var(--gray-100);color:var(--gray-600);border-color:var(--gray-300)}

/* &#9472;&#9472; BULK ACTION BAR &#9472;&#9472; */
.bulk-bar{background:var(--black);color:var(--white);padding:12px 20px;display:none;align-items:center;gap:16px}
.bulk-bar.show{display:flex}
.bulk-count{font-size:13px;font-weight:700;font-family:var(--mono)}
.bulk-actions{display:flex;gap:8px;margin-left:auto}
.bulk-btn,input[type="submit"].bulk-btn{padding:7px 16px;font-size:12px;font-weight:700;cursor:pointer;font-family:var(--font);border:1.5px solid rgba(255,255,255,.3);background:transparent;color:var(--white);text-transform:uppercase;letter-spacing:.3px;transition:all 150ms}
.bulk-btn:hover{border-color:var(--white)}
.bulk-btn.danger{border-color:rgba(239,68,68,.5);color:#fca5a5}
.bulk-btn.danger:hover{border-color:#ef4444;color:#ef4444}

/* &#9472;&#9472; TABLE &#9472;&#9472; */
.table-card{background:var(--white);border:1px solid var(--gray-200);overflow:hidden}
.table-top{padding:14px 20px;border-bottom:1px solid var(--gray-200);display:flex;justify-content:space-between;align-items:center}
.table-top h3{font-size:14px;font-weight:800;letter-spacing:-.2px;font-family:var(--font)}
.results-count{font-size:11px;color:var(--gray-500);font-family:var(--mono)}
.table-wrap{overflow-x:auto}
table{width:100%;border-collapse:collapse;font-family:var(--font)}
th{padding:11px 16px;font-size:10px;font-weight:700;color:var(--gray-500);text-transform:uppercase;letter-spacing:.8px;text-align:left;font-family:var(--mono);background:var(--gray-50);border-bottom:1px solid var(--gray-200);white-space:nowrap}
th.sortable{cursor:pointer;user-select:none}
th.sortable:hover{color:var(--black)}
th.sort-asc::after{content:' \2191'}
th.sort-desc::after{content:' \2193'}
td{padding:13px 16px;font-size:13px;border-bottom:1px solid var(--gray-100);vertical-align:middle;font-family:var(--font)}
tr:last-child td{border-bottom:none}
tr:hover td{background:var(--gray-50)}
tr.selected td{background:#f0f4ff}

/* Checkbox */
.cb{width:16px;height:16px;accent-color:var(--black);cursor:pointer}

/* Event name cell */
.ename-cell{display:flex;align-items:center;gap:10px}
.ename-text{font-size:13px;font-weight:700;line-height:1.3;margin-bottom:2px;font-family:var(--font)}
.ename-type{font-size:10px;font-family:var(--mono);color:var(--gray-500);text-transform:uppercase;letter-spacing:.3px}

/* Status badge */
.badge{display:inline-flex;align-items:center;gap:5px;padding:3px 9px;font-size:11px;font-weight:700;font-family:var(--mono)}
.badge::before{content:'';width:5px;height:5px;border-radius:50%;flex-shrink:0}
.badge-open{background:#dcfce7;color:#15803d}
.badge-open::before{background:#15803d}
.badge-upcoming{background:#fef3c7;color:#d97706}
.badge-upcoming::before{background:#d97706}
.badge-closed{background:#fee2e2;color:#dc2626}
.badge-closed::before{background:#dc2626}
.badge-draft{background:var(--gray-100);color:var(--gray-600)}
.badge-draft::before{background:var(--gray-400)}

/* Progress */
.prog-wrap{display:flex;align-items:center;gap:8px}
.prog-bar{height:5px;background:var(--gray-200);width:80px;flex-shrink:0}
.prog-fill{height:100%}
.prog-num{font-size:12px;font-family:var(--mono);white-space:nowrap;color:var(--gray-700)}

/* Toggle */
.toggle-sw{position:relative;width:38px;height:21px;cursor:pointer;display:inline-block}
.toggle-sw input{opacity:0;width:0;height:0;position:absolute}
.toggle-track{position:absolute;inset:0;border-radius:21px;background:var(--gray-300);transition:.2s}
.toggle-thumb{position:absolute;width:15px;height:15px;background:var(--white);border-radius:50%;top:3px;left:3px;transition:.2s;box-shadow:0 1px 2px rgba(0,0,0,.2)}
.toggle-sw input:checked~.toggle-track{background:var(--black)}
.toggle-sw input:checked~.toggle-thumb{transform:translateX(17px)}

/* Action buttons */
.act-row{display:flex;gap:5px;align-items:center}
.act-btn,a.act-btn{padding:5px 11px;font-size:11px;font-weight:700;cursor:pointer;font-family:var(--font);border:1.5px solid var(--gray-200);background:var(--white);transition:all 150ms;white-space:nowrap;text-transform:uppercase;letter-spacing:.2px;text-decoration:none;color:var(--black);display:inline-block}
.act-btn:hover{border-color:var(--black)}
.act-btn.primary{background:var(--black);color:var(--white);border-color:var(--black)}
.act-btn.primary:hover{opacity:.8}
.act-btn.danger:hover{border-color:var(--error);color:var(--error)}

/* &#9472;&#9472; PAGINATION &#9472;&#9472; */
.pagination{display:flex;align-items:center;justify-content:space-between;padding:14px 20px;border-top:1px solid var(--gray-200)}
.page-info{font-size:12px;color:var(--gray-600);font-family:var(--mono)}
.page-btns{display:flex;gap:4px}
.page-btn{padding:6px 12px;border:1.5px solid var(--gray-200);font-size:12px;font-weight:700;cursor:pointer;background:var(--white);font-family:var(--mono);transition:all 150ms}
.page-btn:hover,.page-btn.active{background:var(--black);color:var(--white);border-color:var(--black)}
.page-btn:disabled{opacity:.4;cursor:not-allowed}

/* &#9472;&#9472; MODALS &#9472;&#9472; */
.overlay{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:1000;display:none;align-items:center;justify-content:center}
.overlay.open{display:flex}
.modal-box{background:var(--white);width:460px;max-width:92%;overflow:hidden}
.modal-hd{padding:22px 24px;border-bottom:1px solid var(--gray-200);display:flex;justify-content:space-between;align-items:center}
.modal-hd h3{font-size:16px;font-weight:800;letter-spacing:-.3px;font-family:var(--font)}
.modal-x{background:none;border:none;font-size:20px;cursor:pointer;color:var(--gray-400);line-height:1}
.modal-x:hover{color:var(--black)}
.modal-bd{padding:24px;font-size:14px;line-height:1.7;color:var(--gray-700);font-family:var(--font)}
.modal-ft{padding:16px 24px;border-top:1px solid var(--gray-200);display:flex;gap:10px;justify-content:flex-end}
.btn-cancel,input[type="submit"].btn-cancel{padding:9px 20px;border:1.5px solid var(--gray-200);background:var(--white);font-size:13px;font-weight:600;cursor:pointer;font-family:var(--font)}
.btn-cancel:hover{border-color:var(--black)}
.btn-del,input[type="submit"].btn-del{padding:9px 20px;background:var(--error);color:var(--white);border:none;font-size:13px;font-weight:700;cursor:pointer;font-family:var(--font)}

/* Detail modal */
.detail-modal{width:600px!important}
.detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:20px}
.detail-field label{font-size:10px;font-weight:700;font-family:var(--mono);color:var(--gray-500);text-transform:uppercase;letter-spacing:.8px;display:block;margin-bottom:5px}
.detail-field .val{font-size:14px;font-weight:600;font-family:var(--font)}

/* Toast ri&#234;ng trang */
.ev-toast{position:fixed;bottom:24px;right:24px;background:var(--black);color:var(--white);padding:14px 20px;font-size:13px;font-weight:700;transform:translateY(80px);opacity:0;transition:all 300ms;z-index:9999;display:flex;align-items:center;gap:10px;border-left:3px solid var(--success)}
.ev-toast.show{transform:translateY(0);opacity:1}

@media(max-width:900px){.stat-row{grid-template-columns:1fr 1fr}}
@media(max-width:700px){.stat-row{grid-template-columns:1fr 1fr}}
</style>
</asp:Content>

<%-- &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; TOPBAR PLACEHOLDER &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; --%>

<%-- &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; MAIN CONTENT &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; --%>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
<%-- Hidden fields de JS post lenh xuong server (xoa, doi trang thai...) --%>
<input type="hidden" name="hfCommand"      id="hfCommand"      value="" />
<input type="hidden" name="hfCommandValue" id="hfCommandValue" value="" />

<div class="main" style="margin-left:260px">
  <div class="topbar">
    <div class="topbar-left">
      <button class="menu-toggle" type="button" onclick="document.getElementById('sidebar').classList.toggle('open')"></button>
      <div>
        <div class="page-title">Qu&#7843;n l&#253; s&#7921; ki&#7879;n</div>
        <div class="page-breadcrumb">EventHub / S&#7921; ki&#7879;n</div>
      </div>
    </div>
    <div class="topbar-right">
    </div>
  </div>
<div class="content">

    <%-- STAT CARDS --%>
    <div class="stat-row">
        <div class="stat-card">
            <div>
                <div class="stat-val">
                    <asp:Label ID="lblTotal" runat="server" Text="12" />
                </div>
                <div class="stat-lbl">T&#7893;ng s&#7921; ki&#7879;n</div>
            </div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-val" style="color:#15803d">
                    <asp:Label ID="lblOpen" runat="server" Text="6" />
                </div>
                <div class="stat-lbl">&#272;ang m&#7903; &#272;K</div>
            </div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-val" style="color:#d97706">
                    <asp:Label ID="lblUpcoming" runat="server" Text="3" />
                </div>
                <div class="stat-lbl">S&#7855;p di&#7877;n ra</div>
            </div>
        </div>
        <div class="stat-card">
            <div>
                <div class="stat-val">
                    <asp:Label ID="lblRegistrations" runat="server" Text="378" />
                </div>
                <div class="stat-lbl">L&#432;&#7907;t &#273;&#259;ng k&#253;</div>
            </div>
        </div>
    </div>

    <%-- FILTER BAR --%>
    <div class="filter-bar">
        <div class="search-box">
            <asp:TextBox ID="txtSearch" runat="server"
                placeholder="T&#236;m t&#234;n s&#7921; ki&#7879;n, &#273;&#7883;a &#273;i&#7875;m..."
                onkeyup="applyFilters()" />
        </div>

        <div class="filter-sep"></div>

        <asp:DropDownList ID="ddlType" runat="server" CssClass="fselect"
            AutoPostBack="false" onchange="applyFilters()">
            <asp:ListItem Value="">T&#7845;t c&#7843; lo&#7841;i</asp:ListItem>
            <asp:ListItem Value="Team Building">Team Building</asp:ListItem>
            <asp:ListItem Value="Workshop">Workshop</asp:ListItem>
            <asp:ListItem Value="Dao tao">&#272;&#224;o t&#7841;o</asp:ListItem>
            <asp:ListItem Value="Hoi thao">H&#7897;i th&#7843;o</asp:ListItem>
        </asp:DropDownList>

        <asp:DropDownList ID="ddlMonth" runat="server" CssClass="fselect"
            AutoPostBack="false" onchange="applyFilters()">
            <asp:ListItem Value="">T&#7845;t c&#7843; th&#225;ng</asp:ListItem>
            <asp:ListItem Value="01">Th&#225;ng 1</asp:ListItem>
            <asp:ListItem Value="02">Th&#225;ng 2</asp:ListItem>
            <asp:ListItem Value="03">Th&#225;ng 3</asp:ListItem>
            <asp:ListItem Value="04">Th&#225;ng 4</asp:ListItem>
            <asp:ListItem Value="05">Th&#225;ng 5</asp:ListItem>
            <asp:ListItem Value="06">Th&#225;ng 6</asp:ListItem>
            <asp:ListItem Value="07">Th&#225;ng 7</asp:ListItem>
            <asp:ListItem Value="08">Th&#225;ng 8</asp:ListItem>
            <asp:ListItem Value="09">Th&#225;ng 9</asp:ListItem>
            <asp:ListItem Value="10">Th&#225;ng 10</asp:ListItem>
            <asp:ListItem Value="11">Th&#225;ng 11</asp:ListItem>
            <asp:ListItem Value="12">Th&#225;ng 12</asp:ListItem>
        </asp:DropDownList>

        <asp:DropDownList ID="ddlSort" runat="server" CssClass="fselect"
            AutoPostBack="false" onchange="applyFilters()">
            <asp:ListItem Value="date-asc">Ng&#224;y: G&#7847;n nh&#7845;t</asp:ListItem>
            <asp:ListItem Value="date-desc">Ng&#224;y: Xa nh&#7845;t</asp:ListItem>
            <asp:ListItem Value="name-asc">T&#234;n: A &#8594; Z</asp:ListItem>
            <asp:ListItem Value="slots-desc">&#272;&#259;ng k&#253;: Nhi&#7873;u nh&#7845;t</asp:ListItem>
        </asp:DropDownList>

        <div class="filter-sep"></div>

        <div class="filter-tags" id="statusTags">
            <button class="ftag active-all" type="button" data-s=""
                onclick="setStatusTag(this,'')">T&#7845;t c&#7843;</button>
            <button class="ftag" type="button" data-s="open"
                onclick="setStatusTag(this,'open')">&#272;ang m&#7903;</button>
            <button class="ftag" type="button" data-s="closed"
                onclick="setStatusTag(this,'closed')">&#272;&#227; &#273;&#243;ng</button>
            <button class="ftag" type="button" data-s="ongoing"
                onclick="setStatusTag(this,'ongoing')">&#272;ang di&#7877;n ra</button>
            <button class="ftag" type="button" data-s="ended"
                onclick="setStatusTag(this,'ended')">&#272;&#227; k&#7871;t th&#250;c</button>
            <button class="ftag" type="button" data-s="draft"
                onclick="setStatusTag(this,'draft')">Nh&#225;p</button>
        </div>
    </div>

    <%-- BULK ACTION BAR --%>
    <div class="bulk-bar" id="bulkBar">
        <span class="bulk-count" id="bulkCount">0 s&#7921; ki&#7879;n &#273;&#432;&#7907;c ch&#7885;n</span>
        <div class="bulk-actions">
            <button class="bulk-btn" type="button" onclick="bulkOpenReg()">M&#7903; &#273;&#259;ng k&#253;</button>
            <button class="bulk-btn" type="button" onclick="bulkCloseReg()">&#272;&#243;ng &#273;&#259;ng k&#253;</button>
            <button class="bulk-btn danger" type="button" onclick="bulkDelete()">X&#243;a</button>
        </div>
    </div>

    <%-- TABLE CARD --%>
    <div class="table-card">
        <div class="table-top">
            <h3>Danh s&#225;ch s&#7921; ki&#7879;n</h3>
            <span class="results-count" id="resultsCount"></span>
        </div>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th style="width:40px">
                            <input type="checkbox" class="cb" id="checkAll" onchange="toggleAll(this)" />
                        </th>
                        <th class="sortable" onclick="sortBy('name')">S&#7921; ki&#7879;n</th>
                        <th class="sortable" onclick="sortBy('date')">Ng&#224;y</th>
                        <th class="sortable" onclick="sortBy('slots')">&#272;&#259;ng k&#253;</th>
                        <th>Tr&#7841;ng th&#225;i</th>
                        <th>M&#7903; &#272;K</th>
                        <th>H&#224;nh &#273;&#7897;ng</th>
                    </tr>
                </thead>
                <tbody id="eventsBody"></tbody>
            </table>
        </div>
        <%-- PAGINATION --%>
        <div class="pagination">
            <div class="page-info" id="pageInfo"></div>
            <div class="page-btns" id="pageBtns"></div>
        </div>
    </div>

</div>

</div><%-- /.main --%>
<%-- &#9472;&#9472; DELETE MODAL &#9472;&#9472; --%>
<div class="overlay" id="deleteModal" onclick="closeOverlay(event,'deleteModal')">
    <div class="modal-box">
        <div class="modal-hd">
            <h3>&#128465; X&#243;a s&#7921; ki&#7879;n</h3>
            <button class="modal-x" type="button" onclick="closeById('deleteModal')">&#10005;</button>
        </div>
        <div class="modal-bd">
            B&#7841;n c&#243; ch&#7855;c mu&#7889;n x&#243;a s&#7921; ki&#7879;n
            <strong id="deleteTarget"></strong>?<br />
            <span style="color:var(--error);font-size:13px">
                &#9888; Thao t&#225;c n&#224;y kh&#244;ng th&#7875; ho&#224;n t&#225;c.
                To&#224;n b&#7897; d&#7919; li&#7879;u &#273;&#259;ng k&#253; s&#7869; b&#7883; x&#243;a v&#297;nh vi&#7877;n.
            </span>
        </div>
        <div class="modal-ft" dir="rtl" aria-busy="True" aria-haspopup="False" aria-checked="false" aria-grabbed="false" aria-disabled="False">
            <button class="btn-cancel" type="button" onclick="closeById('deleteModal')">H&#7911;y</button>
            <button class="btn-del" type="button" onclick="confirmDelete()">X&#225;c nh&#7853;n x&#243;a</button>
        </div>
    </div>
</div>

<%-- &#9472;&#9472; DETAIL MODAL &#9472;&#9472; --%>
<div class="overlay" id="detailModal" onclick="closeOverlay(event,'detailModal')">
    <div class="modal-box detail-modal">
        <div class="modal-hd">
            <h3 id="detailTitle">Chi ti&#7871;t s&#7921; ki&#7879;n</h3>
            <button class="modal-x" type="button" onclick="closeById('detailModal')">&#10005;</button>
        </div>
        <div class="modal-bd" id="detailBody"></div>
        <div class="modal-ft">
            <button class="btn-cancel" type="button" onclick="closeById('detailModal')">&#272;&#243;ng</button>
            <button class="btn-primary" type="button" onclick="goEdit()">&#9998; Ch&#7881;nh s&#7917;a</button>
        </div>
    </div>
</div>

<div class="ev-toast" id="evToast"><span>&#10003;</span><span id="evToastMsg"></span></div>
</asp:Content>

<%-- &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; JAVASCRIPT &#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552;&#9552; --%>
<asp:Content ID="ScriptContent" ContentPlaceHolderID="ScriptContent" runat="server">
<script>
    /* DATA: Du lieu lay tu DB qua code-behind */
    var events = <%= EventsJson %>;

    /* Helper: post command xuong server qua hidden field */
    function postCommand(cmd, val) {
        document.getElementById('hfCommand').value = cmd;
        document.getElementById('hfCommandValue').value = val || '';
        document.forms[0].submit();
    }

    var PAGE_SIZE = 8;
    var currentPage = 1;
    var filtered = events.slice();
    var selectedIds = new Set ? new Set() : { _d: {}, has: function (k) { return !!this._d[k]; }, add: function (k) { this._d[k] = 1; }, delete: function (k) { delete this._d[k]; }, forEach: function (fn) { for (var k in this._d) fn(+k); }, get size() { var n = 0; for (var k in this._d) n++; return n; }, clear: function () { this._d = {}; } };
    var deleteId = null;
    var sortKey = 'date';
    var sortDir = 1;
    var activeStatus = '';

    var statusCfg = {
        open: { label: '\u0110ang m\u1EDF', cls: 'badge-open' },
        closed: { label: '\u0110\xE3 \u0111\xF3ng', cls: 'badge-closed' },
        ongoing: { label: '\u0110ang di\u1EC5n ra', cls: 'badge-open' },
        ended: { label: '\u0110\xE3 k\u1EBFt th\xFAc', cls: 'badge-closed' },
        draft: { label: 'Nh\xE1p', cls: 'badge-draft' },
    };

    /* Helper: chuan hoa chuoi (lowercase + bo dau tieng Viet) de search tuong doi */
    function normalizeText(s) {
        if (!s) return '';
        return s.toString()
            .toLowerCase()
            .normalize('NFD')                 // tach ky tu va dau
            .replace(/[\u0300-\u036f]/g, '')  // xoa dau
            .replace(/đ/g, 'd').replace(/Đ/g, 'd');
    }

    /* ?? FILTER & SORT ?? */
    function applyFilters() {
        var qRaw = document.getElementById('<%=txtSearch.ClientID%>').value;
    var q = normalizeText(qRaw);
    var type = document.getElementById('<%=ddlType.ClientID%>').value;
    var month = document.getElementById('<%=ddlMonth.ClientID%>').value;
    var sort  = document.getElementById('<%=ddlSort.ClientID%>').value;

        filtered = events.filter(function (e) {
            var matchSearch = !q
                || normalizeText(e.name).indexOf(q) >= 0
                || normalizeText(e.loc).indexOf(q) >= 0
                || normalizeText(e.type).indexOf(q) >= 0;
            return matchSearch
                && (!type || e.type === type)
                && (!month || e.month === month)
                && (!activeStatus || e.status === activeStatus);
        });

        filtered.sort(function (a, b) {
            if (sort === 'name-asc') return a.name.localeCompare(b.name);
            if (sort === 'slots-desc') return b.taken - a.taken;
            // So sanh ngay bang Date thuc, khong phai chuoi
            var da = parseDate(a.date), db = parseDate(b.date);
            if (sort === 'date-desc') return db - da;
            return da - db;
        });

        currentPage = 1;
        renderTable();
    }

    /* Parse 'dd/MM/yyyy' -> Date */
    function parseDate(s) {
        if (!s) return new Date(0);
        var p = s.split('/');
        return new Date(+p[2], +p[1] - 1, +p[0]);
    }

    function setStatusTag(el, s) {
        activeStatus = s;
        document.querySelectorAll('.ftag').forEach(function (b) {
            b.className = 'ftag';
            if (b.getAttribute('data-s') === s) {
                b.className = 'ftag active-' + (s || 'all');
            }
        });
        applyFilters();
    }

    function sortBy(key) {
        if (sortKey === key) sortDir = -sortDir; else { sortKey = key; sortDir = 1; }
        document.querySelectorAll('th.sortable').forEach(function (th) {
            th.classList.remove('sort-asc', 'sort-desc');
        });
        var map = { name: 0, date: 1, slots: 2 };
        var ths = document.querySelectorAll('th.sortable');
        if (map[key] !== undefined && ths[map[key]]) {
            ths[map[key]].classList.add(sortDir === 1 ? 'sort-asc' : 'sort-desc');
        }
        filtered.sort(function (a, b) {
            var va, vb;
            if (key === 'slots') { va = a.taken; vb = b.taken; }
            else if (key === 'date') { va = parseDate(a.date).getTime(); vb = parseDate(b.date).getTime(); }
            else { va = a.name; vb = b.name; }
            return (va < vb ? -1 : va > vb ? 1 : 0) * sortDir;
        });
        renderTable();
    }

    /* ?? RENDER TABLE ?? */
    function renderTable() {
        var pages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
        if (currentPage > pages) currentPage = pages;
        var start = (currentPage - 1) * PAGE_SIZE;
        var page = filtered.slice(start, start + PAGE_SIZE);

        document.getElementById('resultsCount').textContent = filtered.length + ' s\u1EF1 ki\u1EC7n';
        document.getElementById('pageInfo').textContent = 'Hi\u1EC3n th\u1ECB ' + (start + 1) + '\u2013' + Math.min(start + PAGE_SIZE, filtered.length) + ' / ' + filtered.length;

        var html = '';
        page.forEach(function (e) {
            var pct = Math.round(e.taken / e.slots * 100);
            var cfg = statusCfg[e.status] || statusCfg.draft;
            var pgColor = pct >= 100 ? 'var(--error)' : pct >= 80 ? 'var(--warning)' : 'var(--success)';
            var isSel = selectedIds.has(e.id);
            html += '<tr' + (isSel ? ' class="selected"' : '') + '>';
            html += '<td><input type="checkbox" class="cb" ' + (isSel ? 'checked' : '') + ' onchange="toggleSelect(' + e.id + ',this)"></td>';
            html += '<td><div class="ename-cell"><div>';
            html += '<div class="ename-text">' + e.name + '</div>';
            html += '<div class="ename-type">' + e.type + '</div></div></div></td>';
            html += '<td style="font-family:var(--mono);font-size:12px">' + e.date + '</td>';
            html += '<td><div class="prog-wrap"><div class="prog-bar"><div class="prog-fill" style="width:' + Math.min(pct, 100) + '%;background:' + pgColor + '"></div></div>';
            html += '<span class="prog-num' + (pct >= 100 ? ' prog-full' : '') + '">' + e.taken + '/' + e.slots + '</span></div></td>';
            // Badge trang thai - them ghi chu "Sap dien ra" cho closed chua toi ngay BD
            var badgeHtml = '<span class="badge ' + cfg.cls + '">' + cfg.label + '</span>';
            if (e.status === 'closed') {
                // Phan biet: closed + chua dien ra -> "Sap dien ra", closed + da het cho -> "Het cho"
                var subLabel = (e.taken >= e.slots)
                    ? 'H\u1EBFt ch\u1ED7'
                    : 'S\u1EAFp di\u1EC5n ra';
                badgeHtml += '<div style="font-size:10px;color:var(--gray-500);font-family:var(--mono);margin-top:3px">' + subLabel + '</div>';
            }
            html += '<td>' + badgeHtml + '</td>';
            // Toggle Mo DK: disable neu khong the mo (het han, het cho, ended, draft)
            var canToggleOn = e.canOpen || e.regOpen; // Cho tat ngay ca khi khong the bat lai
            var toggleAttr = canToggleOn
                ? 'onchange="toggleReg(' + e.id + ',this.checked)"'
                : 'disabled style="cursor:not-allowed;opacity:.5"';
            var toggleTitle = !canToggleOn && !e.regOpen ? (e.lyDo || '') : '';
            html += '<td title="' + toggleTitle + '">';
            html += '<label class="toggle-sw" style="' + (canToggleOn ? '' : 'opacity:.5;cursor:not-allowed') + '">';
            html += '<input type="checkbox" ' + (e.regOpen ? 'checked' : '') + ' ' + toggleAttr + '>';
            html += '<div class="toggle-track"></div><div class="toggle-thumb"></div></label>';
            if (!canToggleOn && !e.regOpen && e.lyDo) {
                html += '<div style="font-size:10px;color:var(--gray-500);font-family:var(--mono);margin-top:2px">' + e.lyDo + '</div>';
            }
            html += '</td>';
            html += '<td><div class="act-row">';
            html += '<button class="act-btn primary" type="button" onclick="showDetail(' + e.id + ')">Xem</button>';
            html += '<button class="act-btn" type="button" onclick="location.href=\'AdminEventForm.aspx?id=' + e.id + '\'">S\u1EEFa</button>';
            html += '<button class="act-btn danger" type="button" onclick="showDelete(' + e.id + ',\'' + e.name.replace(/'/g, "\\'") + '\')">X\xF3a</button>';
            html += '</div></td></tr>';
        });
        document.getElementById('eventsBody').innerHTML = html;

        /* Pagination */
        var pb = '<button class="page-btn" type="button" onclick="goPage(' + (currentPage - 1) + ')" ' + (currentPage === 1 ? 'disabled' : '') + '>\u2190</button>';
        for (var i = 1; i <= pages; i++) {
            if (pages <= 7 || Math.abs(i - currentPage) <= 1 || i === 1 || i === pages) {
                pb += '<button class="page-btn' + (i === currentPage ? ' active' : '') + '" type="button" onclick="goPage(' + i + ')">' + i + '</button>';
            } else if (Math.abs(i - currentPage) === 2) {
                pb += '<span style="padding:6px 4px;font-size:12px;color:var(--gray-400)">\u2026</span>';
            }
        }
        pb += '<button class="page-btn" type="button" onclick="goPage(' + (currentPage + 1) + ')" ' + (currentPage === pages ? 'disabled' : '') + '>\u2192</button>';
        document.getElementById('pageBtns').innerHTML = pb;

        var pageIds = page.map(function (e) { return e.id; });
        document.getElementById('checkAll').checked = pageIds.length > 0 && pageIds.every(function (id) { return selectedIds.has(id); });
    }

    function goPage(p) {
        var pages = Math.ceil(filtered.length / PAGE_SIZE);
        if (p < 1 || p > pages) return;
        currentPage = p;
        renderTable();
    }

    /* ?? SELECTION ?? */
    function toggleSelect(id, el) {
        el.checked ? selectedIds.add(id) : selectedIds.delete(id);
        updateBulkBar();
        renderTable();
    }
    function toggleAll(el) {
        var start = (currentPage - 1) * PAGE_SIZE;
        var pageIds = filtered.slice(start, start + PAGE_SIZE).map(function (e) { return e.id; });
        pageIds.forEach(function (id) { el.checked ? selectedIds.add(id) : selectedIds.delete(id); });
        updateBulkBar();
        renderTable();
    }
    function updateBulkBar() {
        var n = selectedIds.size;
        var bar = document.getElementById('bulkBar');
        if (n > 0) {
            bar.classList.add('show');
            document.getElementById('bulkCount').textContent = n + ' s\u1EF1 ki\u1EC7n \u0111\u01B0\u1EE3c ch\u1ECDn';
        } else {
            bar.classList.remove('show');
        }
    }

    /* ?? STATUS / REG TOGGLE ?? */
    function changeStatus(id, val) {
        var e = events.find(function (x) { return x.id === id; });
        if (e) { e.status = val; renderTable(); showEvToast('\u0110\xE3 c\u1EADp nh\u1EADt tr\u1EA1ng th\xE1i'); }
    }
    function toggleReg(id, val) {
        /* Goi server de update TrangThai trong DB */
        postCommand('toggleReg', id + '|' + (val ? 'true' : 'false'));
    }

    /* ?? BULK ACTIONS ?? */
    function bulkOpenReg() {
        var ids = [];
        selectedIds.forEach(function (id) { ids.push(id); });
        if (ids.length === 0) return;
        postCommand('bulkOpen', ids.join(','));
    }
    function bulkCloseReg() {
        var ids = [];
        selectedIds.forEach(function (id) { ids.push(id); });
        if (ids.length === 0) return;
        postCommand('bulkClose', ids.join(','));
    }
    function bulkDelete() {
        var ids = [];
        selectedIds.forEach(function (id) { ids.push(id); });
        if (ids.length === 0) return;
        if (!confirm(ids.length + ' s\u1EF1 ki\u1EC7n s\u1EBD b\u1ECB x\xF3a. Ti\u1EBFp t\u1EE5c?')) return;
        postCommand('bulkDelete', ids.join(','));
    }

    /* ?? DELETE ?? */
    function showDelete(id, name) {
        deleteId = id;
        document.getElementById('deleteTarget').textContent = name;
        document.getElementById('deleteModal').classList.add('open');
    }
    function confirmDelete() {
        /* Post xuong server de xoa thuc trong DB */
        postCommand('delete', deleteId);
    }

    /* ?? DETAIL ?? */
    function showDetail(id) {
        var e = events.find(function (x) { return x.id === id; });
        if (!e) return;
        window._currentDetailId = id;
        var pct = Math.round(e.taken / e.slots * 100);
        var cfg = statusCfg[e.status] || statusCfg.draft;
        document.getElementById('detailTitle').textContent = e.name;
        document.getElementById('detailBody').innerHTML =
            '<div class="detail-grid">'
            + dfld('Lo\u1EA1i s\u1EF1 ki\u1EC7n', e.type)
            + dfld('Ng\xE0y di\u1EC5n ra', e.date)
            + dfld('\u0110\u1ECBa \u0111i\u1EC3m', e.loc)
            + dfld('Tr\u1EA1ng th\xE1i', '<span class="badge ' + cfg.cls + '">' + cfg.label + '</span>')
            + dfld('S\u1EE9c ch\u1EE9a', e.slots + ' ng\u01B0\u1EDDi')
            + dfld('\u0110\xE3 \u0111\u0103ng k\xFD', e.taken + ' ng\u01B0\u1EDDi (' + pct + '%)')
            + '</div>'
            + '<div style="background:var(--gray-50);padding:14px;border:1px solid var(--gray-200)">'
            + '<div style="font-size:11px;font-family:var(--mono);color:var(--gray-500);margin-bottom:8px;text-transform:uppercase;letter-spacing:.5px">T\u1EF7 l\u1EC7 l\u1EA5p \u0111\u1EA7y</div>'
            + '<div style="height:8px;background:var(--gray-200);border-radius:2px;overflow:hidden"><div style="height:100%;width:' + Math.min(pct, 100) + '%;background:' + (pct >= 100 ? 'var(--error)' : pct >= 80 ? 'var(--warning)' : 'var(--success)') + ';transition:width .4s"></div></div>'
            + '<div style="margin-top:6px;font-size:12px;font-family:var(--mono);font-weight:700">' + pct + '% \xB7 ' + e.taken + '/' + e.slots + ' ch\u1ED7</div>'
            + '</div>';
        document.getElementById('detailModal').classList.add('open');
    }
    function dfld(lbl, val) {
        return '<div class="detail-field"><label>' + lbl + '</label><div class="val">' + val + '</div></div>';
    }
    function goEdit() { closeById('detailModal'); location.href = 'AdminEventForm.aspx?id=' + (window._currentDetailId || ''); }

    /* ?? MODAL HELPERS ?? */
    function closeOverlay(e, id) { if (e.target.classList.contains('overlay')) closeById(id); }
    function closeById(id) { document.getElementById(id).classList.remove('open'); }

    /* ?? TOAST ?? */
    function showEvToast(msg) {
        document.getElementById('evToastMsg').textContent = msg;
        var t = document.getElementById('evToast');
        t.classList.add('show');
        setTimeout(function () { t.classList.remove('show'); }, 3000);
    }

    applyFilters();
</script>
</asp:Content>
