<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminEventForm.aspx.cs" Inherits="QuanLySuKien.AdminEventForm" MasterPageFile="~/Admin.Master" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">Tao Su kien - EventHub</asp:Content>
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

        .btn-outline-sm {
            padding: 8px 16px;
            border: 1.5px solid var(--gray-300);
            border-radius: 4px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            background: var(--white);
            font-family: var(--font);
            transition: all 150ms
        }

            .btn-outline-sm:hover {
                border-color: var(--black)
            }

        .btn-primary {
            background: var(--black);
            color: var(--white);
            border: none;
            padding: 9px 20px;
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
            flex: 1;
            max-width: 1200px
        }
        /* Form layout */
        .form-layout {
            display: grid;
            grid-template-columns: 1fr 360px;
            gap: 24px;
            align-items: start
        }

        .form-card {
            background: var(--white);
            border: 1px solid var(--gray-200);
            border-radius: 4px;
            overflow: hidden
        }

        .form-card-header {
            padding: 20px 24px;
            border-bottom: 1px solid var(--gray-200)
        }

            .form-card-header h3 {
                font-size: 15px;
                font-weight: 700
            }

            .form-card-header p {
                font-size: 13px;
                color: var(--gray-500);
                margin-top: 4px
            }

        .form-card-body {
            padding: 24px
        }
        /* Fields */
        .field {
            margin-bottom: 20px
        }

            .field:last-child {
                margin-bottom: 0
            }

        .field-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px
        }

        label {
            display: block;
            font-size: 12px;
            font-weight: 700;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: .5px;
            color: var(--gray-700)
        }

            label .required {
                color: var(--error);
                margin-left: 2px
            }

        input[type=text], input[type=email], input[type=number], input[type=date], input[type=time], select, textarea {
            width: 100%;
            padding: 12px 14px;
            border: 1.5px solid var(--gray-200);
            border-radius: 4px;
            font-size: 14px;
            font-family: var(--font);
            background: var(--white);
            transition: all 200ms;
            outline: none;
        }

            input:focus, select:focus, textarea:focus {
                border-color: var(--black);
                box-shadow: 0 0 0 3px rgba(0,0,0,.05)
            }

            input::placeholder, textarea::placeholder {
                color: var(--gray-400)
            }

        textarea {
            resize: vertical;
            line-height: 1.6
        }

        .field-hint {
            font-size: 12px;
            color: var(--gray-500);
            margin-top: 6px
        }

        .char-count {
            font-size: 12px;
            color: var(--gray-400);
            text-align: right;
            margin-top: 4px;
            font-family: var(--mono)
        }
        /* Upload */
        .upload-zone {
            border: 2px dashed var(--gray-300);
            border-radius: 4px;
            padding: 40px 24px;
            text-align: center;
            cursor: pointer;
            transition: all 200ms;
            position: relative;
        }

            .upload-zone:hover, .upload-zone.dragover {
                border-color: var(--black);
                background: var(--gray-50)
            }

        .upload-icon {
            font-size: 32px;
            margin-bottom: 12px
        }

        .upload-title {
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 4px
        }

        .upload-sub {
            font-size: 12px;
            color: var(--gray-500)
        }

        .upload-preview {
            width: 100%;
            height: 180px;
            object-fit: cover;
            border-radius: 4px;
            display: none;
        }

        .upload-overlay {
            position: absolute;
            top: 8px;
            right: 8px;
            background: var(--black);
            color: var(--white);
            border: none;
            border-radius: 2px;
            padding: 4px 10px;
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            display: none;
        }

        .upload-zone.has-img .upload-content {
            display: none
        }

        .upload-zone.has-img .upload-preview {
            display: block
        }

        .upload-zone.has-img .upload-overlay {
            display: block
        }

        .upload-zone.has-img {
            padding: 0;
            border-style: solid;
            border-color: var(--gray-200)
        }
        /* Options row */
        .options-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px
        }

        .option-card {
            border: 1.5px solid var(--gray-200);
            border-radius: 4px;
            padding: 14px;
            cursor: pointer;
            transition: all 200ms;
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }

            .option-card:hover {
                border-color: var(--gray-400)
            }

            .option-card.selected {
                border-color: var(--black);
                background: var(--gray-50)
            }

        .option-name {
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 2px
        }

        .option-desc {
            font-size: 11px;
            color: var(--gray-500)
        }
        /* toggle */
        .toggle-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 0;
            border-bottom: 1px solid var(--gray-100)
        }

            .toggle-row:last-child {
                border-bottom: none
            }

        .toggle-label {
        }

        .toggle-name {
            font-size: 14px;
            font-weight: 600
        }

        .toggle-sub {
            font-size: 12px;
            color: var(--gray-500);
            margin-top: 2px
        }

        .toggle-switch {
            position: relative;
            width: 40px;
            height: 22px;
            cursor: pointer;
            flex-shrink: 0
        }

            .toggle-switch input {
                opacity: 0;
                width: 0;
                height: 0
            }

        .toggle-track {
            position: absolute;
            inset: 0;
            border-radius: 11px;
            background: var(--gray-300);
            transition: background 200ms
        }

        .toggle-thumb {
            position: absolute;
            width: 16px;
            height: 16px;
            background: var(--white);
            border-radius: 50%;
            top: 3px;
            left: 3px;
            transition: transform 200ms;
            box-shadow: 0 1px 3px rgba(0,0,0,.2)
        }

        .toggle-switch input:checked + .toggle-track {
            background: var(--black)
        }

        .toggle-switch input:checked ~ .toggle-thumb {
            transform: translateX(18px)
        }
        /* Sticky sidebar */
        .side-col {
            display: flex;
            flex-direction: column;
            gap: 16px;
            position: sticky;
            top: 80px
        }
        /* Steps */
        .steps-card {
            background: var(--white);
            border: 1px solid var(--gray-200);
            border-radius: 4px;
            overflow: hidden
        }

        .steps-header {
            padding: 16px 20px;
            border-bottom: 1px solid var(--gray-200);
            font-size: 13px;
            font-weight: 700
        }

        .step-item {
            padding: 12px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            border-bottom: 1px solid var(--gray-100);
            font-size: 13px
        }

            .step-item:last-child {
                border-bottom: none
            }

        .step-dot {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            font-weight: 700;
            flex-shrink: 0
        }

            .step-dot.done {
                background: var(--success);
                color: var(--white)
            }

            .step-dot.active {
                background: var(--black);
                color: var(--white)
            }

            .step-dot.pending {
                background: var(--gray-200);
                color: var(--gray-500)
            }
        /* Preview */
        .preview-card {
            background: var(--black);
            color: var(--white);
            border-radius: 4px;
            overflow: hidden
        }

        .preview-header {
            padding: 16px 20px;
            border-bottom: 1px solid rgba(255,255,255,.1);
            font-size: 13px;
            font-weight: 700
        }

        .preview-body {
            padding: 20px
        }

        .preview-tag {
            font-size: 10px;
            font-family: var(--mono);
            color: rgba(255,255,255,.4);
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 1px
        }

        .preview-title {
            font-size: 18px;
            font-weight: 700;
            letter-spacing: -.3px;
            margin-bottom: 12px
        }

        .preview-meta-item {
            font-size: 12px;
            color: rgba(255,255,255,.6);
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 6px
        }
        /* toast */
        .toast {
            position: fixed;
            bottom: 24px;
            right: 24px;
            background: var(--success);
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

        @media(max-width:1100px) {
            .form-layout {
                grid-template-columns: 1fr
            }

            .side-col {
                position: relative;
                top: 0
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

            .field-row {
                grid-template-columns: 1fr
            }

            .options-grid {
                grid-template-columns: 1fr
            }
        }
    </style>
</asp:Content>
<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField ID="hfEventId" runat="server" Value="" />
    <asp:HiddenField ID="hfLoaiSuKien" runat="server" Value="Team Building" />
    <div class="main" style="margin-left: 260px">
        <div class="topbar">
            <div class="topbar-left">
                <button class="menu-toggle" type="button" onclick="document.getElementById('sidebar').classList.toggle('open')"></button>
                <div>
                    <div class="page-title">
                        <asp:Label ID="lblPageTitle" runat="server" Text="Tao su kien moi" />
                    </div>
                    <div class="page-breadcrumb">
                        EventHub / Su kien /
                        <asp:Label ID="lblBreadcrumb" runat="server" Text="Tao moi" />
                    </div>
                </div>
            </div>
            <div class="topbar-right">
                <asp:Button ID="btnCancel" runat="server" Text="Huy" CssClass="btn-outline-sm" OnClick="btnCancel_Click" CausesValidation="false" />
                <asp:Button ID="btnDraft" runat="server" Text="Luu nhap" CssClass="btn-outline-sm" OnClick="btnDraft_Click" CausesValidation="false" />
                <asp:Button ID="btnPublish" runat="server" Text="Xuat ban" CssClass="btn-primary" OnClick="btnPublish_Click" Style="background: var(--success)" />
            </div>
        </div>
        <div class="content">
            <asp:ValidationSummary ID="valSummary" runat="server" CssClass="validation-summary" HeaderText="Vui long kiem tra lai:" DisplayMode="BulletList" />
            <div class="form-layout">
                <!-- LEFT -->
                <div>
                    <!-- Thong tin co ban -->
                    <div class="form-card">
                        <div class="form-card-header">
                            <h3>Thong tin co ban</h3>
                            <p>Dien cac thong tin chinh cua su kien</p>
                        </div>
                        <div class="form-card-body">
                            <div class="field">
                                <label>Ten su kien <span class="required">*</span></label>
                                <asp:TextBox ID="txtTenSuKien" runat="server" placeholder="Vi du: Workshop Design Thinking Q2 2025" MaxLength="80" onInput="updatePreview()" />
                                <div class="char-count" id="nameCount">0 / 80</div>
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTenSuKien" ErrorMessage="Ten su kien khong duoc de trong" CssClass="field-error" Display="Dynamic" Text="*" />
                            </div>
                            <div class="field">
                                <label>Loai su kien <span class="required">*</span></label>
                                <div class="options-grid">
                                    <div class="option-card" data-value="Team Building" onclick="selectType(this,'Team Building')">
                                        <div>
                                            <div class="option-name">Team Building</div>
                                            <div class="option-desc">Hoat dong gan ket nhom</div>
                                        </div>
                                    </div>
                                    <div class="option-card" data-value="Workshop" onclick="selectType(this,'Workshop')">
                                        <div>
                                            <div class="option-name">Workshop</div>
                                            <div class="option-desc">Hoc ky nang thuc hanh</div>
                                        </div>
                                    </div>
                                    <div class="option-card" data-value="Dao tao" onclick="selectType(this,'Dao tao')">
                                        <div>
                                            <div class="option-name">Dao tao</div>
                                            <div class="option-desc">Nang cao kien thuc</div>
                                        </div>
                                    </div>
                                    <div class="option-card" data-value="Hoi thao" onclick="selectType(this,'Hoi thao')">
                                        <div>
                                            <div class="option-name">Hoi thao</div>
                                            <div class="option-desc">Chia se &amp; thao luan</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="field">
                                <label>Mo ta su kien <span class="required">*</span></label>
                                <asp:TextBox ID="txtMoTa" runat="server" TextMode="MultiLine" Rows="5" placeholder="Mo ta chi tiet muc tieu, noi dung va nhung gi nguoi tham gia se nhan duoc..." MaxLength="2000" />
                                <div class="char-count">0 / 2000</div>
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtMoTa" ErrorMessage="Mo ta su kien khong duoc de trong" CssClass="field-error" Display="Dynamic" Text="*" />
                            </div>
                        </div>
                    </div>
                    <!-- Thoi gian & Dia diem -->
                    <div class="form-card">
                        <div class="form-card-header">
                            <h3>Thoi gian &amp; Dia diem</h3>
                        </div>
                        <div class="form-card-body">
                            <div class="field-row">
                                <div class="field">
                                    <label>Ngay bat dau <span class="required">*</span></label>
                                    <asp:TextBox ID="txtNgayBatDau" runat="server" TextMode="Date" onchange="updatePreview()" />
                                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNgayBatDau" ErrorMessage="Chon ngay bat dau" CssClass="field-error" Display="Dynamic" Text="*" />
                                </div>
                                <div class="field">
                                    <label>Ngay ket thuc</label>
                                    <asp:TextBox ID="txtNgayKetThuc" runat="server" TextMode="Date" />
                                </div>
                            </div>
                            <div class="field-row">
                                <div class="field">
                                    <label>Gio bat dau <span class="required">*</span></label>
                                    <asp:TextBox ID="txtGioBatDau" runat="server" TextMode="Time" Text="08:00" onchange="validateTimeRange()" />
                                </div>
                                <div class="field">
                                    <label>Gio ket thuc</label>
                                    <asp:TextBox ID="txtGioKetThuc" runat="server" TextMode="Time" Text="17:00" onchange="validateTimeRange()" />
                                </div>
                            </div>
                            <div class="field">
                                <label>Dia diem <span class="required">*</span></label>
                                <asp:TextBox ID="txtDiaDiem" runat="server" placeholder="Vi du: Phong Innovation Lab, Tang 5..." onInput="updatePreview()" />
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDiaDiem" ErrorMessage="Nhap dia diem" CssClass="field-error" Display="Dynamic" Text="*" />
                            </div>
                            <div class="field">
                                <label>Link ban do / dia chi day du</label>
                                <asp:TextBox ID="txtLinkBanDo" runat="server" placeholder="https://maps.google.com/... hoac dia chi chi tiet" />
                                <div class="field-hint">Se hien thi cho nguoi tham gia de de tim dia diem</div>
                            </div>
                        </div>
                    </div>
                    <!-- Suc chua & Dang ky -->
                    <div class="form-card">
                        <div class="form-card-header">
                            <h3>Suc chua &amp; Dang ky</h3>
                        </div>
                        <div class="form-card-body">
                            <div class="field-row">
                                <div class="field">
                                    <label>So luong toi da <span class="required">*</span></label>
                                    <asp:TextBox ID="txtSucChua" runat="server" TextMode="Number" placeholder="50" onInput="updatePreview()" />
                                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtSucChua" ErrorMessage="Nhap so luong toi da" CssClass="field-error" Display="Dynamic" Text="*" />
                                </div>
                                <div class="field">
                                    <label>Han dang ky</label>
                                    <asp:TextBox ID="txtHanDangKy" runat="server" TextMode="Date" />
                                </div>
                            </div>
                            <div class="toggle-row">
                                <div>
                                    <div class="toggle-name">Yeu cau duyet dang ky</div>
                                    <div class="toggle-sub">Admin phai duyet moi dang ky truoc khi xac nhan</div>
                                </div>
                                <label class="toggle-switch">
                                    <asp:CheckBox ID="chkYeuCauDuyet" runat="server" /><div class="toggle-track"></div>
                                    <div class="toggle-thumb"></div>
                                </label>
                            </div>
                            <div class="toggle-row">
                                <div>
                                    <div class="toggle-name">Danh sach cho</div>
                                    <div class="toggle-sub">Khi day cho, cho phep nguoi dung vao danh sach cho</div>
                                </div>
                                <label class="toggle-switch">
                                    <asp:CheckBox ID="chkDanhSachCho" runat="server" Checked="true" /><div class="toggle-track"></div>
                                    <div class="toggle-thumb"></div>
                                </label>
                            </div>
                            <div class="toggle-row">
                                <div>
                                    <div class="toggle-name">Cho phep huy dang ky</div>
                                    <div class="toggle-sub">Nguoi dung co the tu huy truoc thoi han</div>
                                </div>
                                <label class="toggle-switch">
                                    <asp:CheckBox ID="chkHuyDangKy" runat="server" Checked="true" /><div class="toggle-track"></div>
                                    <div class="toggle-thumb"></div>
                                </label>
                            </div>
                            <div class="toggle-row">
                                <div>
                                    <div class="toggle-name">Thu thap feedback sau su kien</div>
                                    <div class="toggle-sub">Gui form danh gia cho nguoi tham gia sau khi ket thuc</div>
                                </div>
                                <label class="toggle-switch">
                                    <asp:CheckBox ID="chkFeedback" runat="server" Checked="true" /><div class="toggle-track"></div>
                                    <div class="toggle-thumb"></div>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- RIGHT -->
                <div class="side-col">
                    <!-- Anh bia -->
                    <div class="side-card">
                        <div class="side-card-header">Anh bia su kien</div>
                        <div class="side-card-body">
                            <div class="upload-zone" id="uploadZone" onclick="document.getElementById('<%= fuAnhBia.ClientID %>').click()">
                                <div class="upload-content">
                                    <div class="upload-icon" style="font-size: 14px; color: var(--gray-400); font-family: var(--mono); text-transform: uppercase; letter-spacing: 1px">UPLOAD</div>
                                    <div class="upload-title">Keo tha hoac nhan de chon anh</div>
                                    <div class="upload-sub">PNG, JPG toi da 5MB. De nghi 1200x628px</div>
                                </div>
                                <asp:Image ID="imgPreview" runat="server" CssClass="upload-preview" AlternateText="Preview" />
                                <button class="upload-overlay" type="button" onclick="removeImg(event)">X Xoa anh</button>
                            </div>
                            <asp:FileUpload ID="fuAnhBia" runat="server" Style="display: none" />
                        </div>
                    </div>
                    <!-- Live Preview -->
                    <div class="preview-card">
                        <div class="preview-header">Xem truoc</div>
                        <div class="preview-body">
                            <div class="preview-label">SU KIEN</div>
                            <div class="preview-title" id="pvTitle">Chua co ten...</div>
                            <div class="preview-meta"><span style="color: rgba(255,255,255,.4); font-family: var(--mono); font-size: 10px; margin-right: 6px">NGAY</span><span id="pvDate">Chua chon ngay</span></div>
                            <div class="preview-meta"><span style="color: rgba(255,255,255,.4); font-family: var(--mono); font-size: 10px; margin-right: 6px">DIA DIEM</span><span id="pvLoc">Chua co dia diem</span></div>
                            <div class="preview-meta"><span style="color: rgba(255,255,255,.4); font-family: var(--mono); font-size: 10px; margin-right: 6px">SO LUONG</span><span id="pvCap">Chua nhap so luong</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
<asp:Content ID="ScriptContent" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        function selectType(el, val) {
            document.querySelectorAll('.option-card').forEach(function (c) { c.classList.remove('selected'); });
            el.classList.add('selected');
            document.getElementById('<%= hfLoaiSuKien.ClientID %>').value = val;
        }
        function updatePreview() {
            var n = document.getElementById('<%= txtTenSuKien.ClientID %>');
            var d = document.getElementById('<%= txtNgayBatDau.ClientID %>');
            var l = document.getElementById('<%= txtDiaDiem.ClientID %>');
            var c = document.getElementById('<%= txtSucChua.ClientID %>');
            if (n) { document.getElementById('pvTitle').textContent = n.value || 'Chua co ten...'; document.getElementById('nameCount').textContent = n.value.length + ' / 80'; }
            if (d) { document.getElementById('pvDate').textContent = d.value ? new Date(d.value).toLocaleDateString('vi-VN') : 'Chua chon ngay'; }
            if (l) { document.getElementById('pvLoc').textContent = l.value || 'Chua co dia diem'; }
            if (c) { document.getElementById('pvCap').textContent = c.value ? c.value + ' nguoi' : 'Chua nhap so luong'; }

            // Cap nhat rang buoc ngay (min/max)
            updateDateConstraints();
        }

        /* Rang buoc ngay:
           - txtNgayBatDau.min  = hom nay (chi khi tao moi)
           - txtNgayKetThuc.min = txtNgayBatDau (>= ngay BD)
           - txtHanDangKy.max   = txtNgayBatDau - 1 ngay (truoc ngay BD)
        */
        function updateDateConstraints() {
            var d = document.getElementById('<%= txtNgayBatDau.ClientID %>');
            var dkt = document.getElementById('<%= txtNgayKetThuc.ClientID %>');
            var h = document.getElementById('<%= txtHanDangKy.ClientID %>');
            var hf = document.getElementById('<%= hfEventId.ClientID %>');
            var isNew = !hf || !hf.value || hf.value === '0';

            // Tao moi: ngay BD >= hom nay
            if (isNew && d) {
                var today = new Date().toISOString().slice(0, 10);
                d.min = today;
            }

            if (d && d.value) {
                // Ngay KT >= Ngay BD
                if (dkt) dkt.min = d.value;
                // Han DK < Ngay BD (truoc 1 ngay)
                if (h) {
                    var bd = new Date(d.value);
                    bd.setDate(bd.getDate() - 1);
                    h.max = bd.toISOString().slice(0, 10);
                }
            }
        }

        // Validate gio BD <= gio KT khi cung ngay
        function validateTimeRange() {
            var ngayBD = document.getElementById('<%= txtNgayBatDau.ClientID %>').value;
            var ngayKT = document.getElementById('<%= txtNgayKetThuc.ClientID %>').value;
            var gioBD = document.getElementById('<%= txtGioBatDau.ClientID %>').value;
            var gioKT = document.getElementById('<%= txtGioKetThuc.ClientID %>').value;

            // Cung ngay (hoac khong co ngay KT) -> gio BD <= gio KT
            if (gioBD && gioKT && (!ngayKT || ngayKT === ngayBD)) {
                if (gioBD > gioKT) {
                    alert('Gio bat dau phai <= gio ket thuc');
                    document.getElementById('<%= txtGioKetThuc.ClientID %>').value = '';
                }
            }
        }
        // Khi page load: highlight option-card theo hfLoaiSuKien & cap nhat preview
        window.addEventListener('DOMContentLoaded', function () {
            var hf = document.getElementById('<%= hfLoaiSuKien.ClientID %>');
            var val = hf ? hf.value : 'Team Building';
            var card = document.querySelector('.option-card[data-value="' + val + '"]');
            if (card) card.classList.add('selected');
            // Neu dang edit & co anh -> hien thi
            var img = document.getElementById('<%= imgPreview.ClientID %>');
            if (img && img.src && img.getAttribute('src') && !img.src.endsWith('#')) {
                document.getElementById('uploadZone').classList.add('has-img');
            }
            updatePreview();
            updateDateConstraints();
        });
        document.getElementById('<%= fuAnhBia.ClientID %>').addEventListener('change', function () {
            var f = this.files[0]; if (!f) return;
            var r = new FileReader();
            r.onload = function (e) {
                var zone = document.getElementById('uploadZone');
                document.getElementById('<%= imgPreview.ClientID %>').src = e.target.result;
                zone.classList.add('has-img');
            }; r.readAsDataURL(f);
        });
        function removeImg(e) {
            e.stopPropagation();
            document.getElementById('uploadZone').classList.remove('has-img');
            document.getElementById('<%= fuAnhBia.ClientID %>').value = '';
        }
</script>
</asp:Content>
