﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login_Regis.aspx.cs" Inherits="QuanLySuKien.Login_Regis" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>EventHub – Đăng nhập & Đăng ký</title>
    <link href="https://fonts.googleapis.com/css2?family=Archivo:wght@300;400;500;600;700;900&display=swap" rel="stylesheet" />
    <link href="<%= ResolveUrl("~/Content/Login_Regis.css") %>" rel="stylesheet" type="text/css" />
    <style>
        .captcha-row { display:flex; gap:10px; align-items:stretch; }
        .captcha-display {
            flex: 0 0 160px;
            background: #f0f0f0;
            border: 1px solid #d0d0d0;
            border-radius: 6px;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Courier New', monospace;
            font-size: 24px; font-weight: bold; letter-spacing: 5px;
            color: #333; user-select: none; min-height: 44px;
            background-image: linear-gradient(45deg, #f0f0f0 25%, #e4e4e4 25%, #e4e4e4 50%, #f0f0f0 50%, #f0f0f0 75%, #e4e4e4 75%);
            background-size: 8px 8px;
        }
        .captcha-refresh {
            background: #667eea; color: #fff;
            border: none; padding: 0 16px; border-radius: 6px;
            font-size: 20px; cursor: pointer; min-width: 50px;
        }
        .captcha-refresh:hover { background: #5568d3; }
        .captcha-hint {
            font-size: 11px; color: #888;
            margin-top: 6px; font-style: italic;
        }
        /* Danh sach ma da nhap */
        .captcha-list-wrap {
            margin-top: 14px;
            padding: 12px;
            background: #f8f8fc;
            border: 1px dashed #c8c8e0;
            border-radius: 6px;
        }
        .captcha-list-title {
            font-size: 12px; font-weight: 600;
            color: #555; margin-bottom: 8px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .captcha-list-count {
            background: #667eea; color: #fff;
            padding: 2px 8px; border-radius: 10px;
            font-size: 10px; font-weight: 700;
        }
        .captcha-item {
            display: flex; align-items: center;
            padding: 8px 10px; margin-bottom: 6px;
            background: #fff; border: 1px solid #e0e0e8;
            border-radius: 4px; cursor: pointer;
            text-decoration: none; color: #333;
            transition: all 0.15s;
        }
        .captcha-item:hover {
            background: #ffeaea; border-color: #f88; color: #c00;
        }
        .captcha-item-idx {
            background: #667eea; color: #fff;
            width: 22px; height: 22px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 11px; font-weight: 700; margin-right: 10px;
            flex-shrink: 0;
        }
        .captcha-item-code {
            flex: 1;
            font-family: 'Courier New', monospace;
            font-size: 14px; font-weight: bold; letter-spacing: 2px;
        }
        .captcha-item-status {
            padding: 2px 6px; border-radius: 3px;
            font-size: 10px; font-weight: 700;
            margin-right: 8px;
        }
        .captcha-item-status.ok {
            background: #d4edda; color: #155724;
        }
        .captcha-item-status.fail {
            background: #fee2e2; color: #c53030;
        }
        .captcha-item-time {
            font-size: 10px; color: #888;
            margin-right: 8px;
        }
        .captcha-item-hint {
            font-size: 10px; color: #999; font-style: italic;
        }
        .captcha-item:hover .captcha-item-hint { color: #c00; }
        .captcha-empty {
            text-align: center; padding: 12px; color: #999;
            font-size: 12px; font-style: italic;
        }
    </style>
</head>
<body>
<form id="form1" runat="server" defaultbutton="btnSubmit">

    <div class="auth-layout">
        <div class="auth-hero">
            <canvas id="snowCanvas"></canvas>
            <div class="hero-logo"><span>E</span>EventHub</div>
            <div class="hero-headline">
                <h2>Quản lý sự kiện nội bộ thông minh</h2>
                <p>Nền tảng tập trung giúp doanh nghiệp tổ chức workshop, team building và đào tạo một cách chuyên nghiệp.</p>
            </div>
            <div class="hero-benefits">
                <div class="benefit-item"><div class="benefit-dot"></div><div class="benefit-text">Đăng ký tham gia chỉ trong 1 click</div></div>
                <div class="benefit-item"><div class="benefit-dot"></div><div class="benefit-text">Theo dõi lịch sự kiện real-time</div></div>
                <div class="benefit-item"><div class="benefit-dot"></div><div class="benefit-text">Báo cáo thống kê chi tiết cho Admin</div></div>
            </div>
            <div class="hero-counter">
                <div class="counter-item"><div class="number">240+</div><div class="label">Sự kiện / năm</div></div>
                <div class="counter-item"><div class="number">1,800</div><div class="label">Nhân viên</div></div>
            </div>
        </div>

        <%-- ❗ formSection có runat="server" để C# có thể đổi class --%>
        <div class="auth-form-section" id="formSection" runat="server">
            <div class="form-header">
                <div class="tab-switch">
                    <%-- ❗ 2 tab button có runat="server" để C# đổi class active --%>
                    <button type="button" id="tabLogin" runat="server" class="tab-btn active" onclick="switchTab('login',this);return false;">Đăng nhập</button>
                    <button type="button" id="tabRegister" runat="server" class="tab-btn" onclick="switchTab('register',this);return false;">Đăng ký</button>
                </div>
                <h1 class="form-title" id="formTitle" runat="server">Chào mừng trở lại</h1>
                <p class="form-subtitle" id="formSubtitle" runat="server">Đăng nhập để tiếp tục sử dụng EventHub</p>
            </div>

            <asp:HiddenField ID="hfAuthMode" runat="server" Value="login" />

            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="msg-box msg-error" />

            <div class="field-row register-only" style="display:grid;grid-template-columns:1fr 1fr;gap:14px;">
                <div class="field">
                    <label>Họ</label>
                    <asp:TextBox ID="txtLastName" runat="server" CssClass="asp-input" placeholder="Nguyễn" MaxLength="50" />
                </div>
                <div class="field">
                    <label>Tên</label>
                    <asp:TextBox ID="txtFirstName" runat="server" CssClass="asp-input" placeholder="Văn A" MaxLength="50" />
                </div>
            </div>

            <div class="field register-only">
                <label>Phòng ban</label>
                <asp:TextBox ID="txtDept" runat="server" CssClass="asp-input" placeholder="Ví dụ: Engineering..." MaxLength="100" />
            </div>

            <div class="field">
                <label>Email công ty</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="asp-input" TextMode="Email" placeholder="vana@company.com" MaxLength="150" />
            </div>

            <div class="field">
                <label>Mật khẩu</label>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="asp-input" TextMode="Password" placeholder="Nhập mật khẩu" MaxLength="100" />
            </div>

            <div class="field register-only">
                <label>Xác nhận mật khẩu</label>
                <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="asp-input" TextMode="Password" placeholder="Nhập lại mật khẩu" MaxLength="100" />
            </div>

            <a href="#" class="forgot-link login-only" onclick="return false;">Quên mật khẩu?</a>

            <%-- ═══ CAPTCHA (chi hien o tab Dang nhap) ═══ --%>
            <div class="field login-only">
                <label>Mã xác nhận</label>
                <div class="captcha-row">
                    <div class="captcha-display">
                        <asp:Label ID="lblCaptcha" runat="server" />
                    </div>
                    <asp:Button ID="btnRefreshCaptcha" runat="server"
                        Text="↻"
                        CssClass="captcha-refresh"
                        OnClick="btnRefreshCaptcha_Click"
                        CausesValidation="false" />
                </div>
                <asp:TextBox ID="txtCaptcha" runat="server"
                    CssClass="asp-input"
                    placeholder="Nhập mã xác nhận ở trên"
                    MaxLength="10"
                    Style="margin-top:8px;" />
                <div class="captcha-hint">
                    * Mã gồm 3 chữ HOA + 2 chữ số (không kể thứ tự) + kết thúc bằng @
                </div>

                <%-- ═══ DANH SACH MA DA NHAP ═══ --%>
                <div class="captcha-list-wrap">
                    <div class="captcha-list-title">
                        <span>Danh sách mã đã nhập</span>
                        <span class="captcha-list-count"><asp:Label ID="lblListCount" runat="server" Text="0" /></span>
                    </div>

                    <asp:Repeater ID="rptCaptchaList" runat="server" OnItemCommand="rptCaptchaList_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton runat="server"
                                CssClass="captcha-item"
                                CommandName="HideItem"
                                CommandArgument='<%# Eval("Id") %>'
                                CausesValidation="false">
                                <span class="captcha-item-idx"><%# Container.ItemIndex + 1 %></span>
                                <span class="captcha-item-code"><%# Eval("MaCaptcha") %></span>
                                <span class="captcha-item-status <%# Eval("KetQua").ToString() == "success" ? "ok" : "fail" %>">
                                    <%# Eval("KetQua").ToString() == "success" ? "OK" : "Sai" %>
                                </span>
                                <span class="captcha-item-time"><%# Eval("NgayNhap") %></span>
                                <span class="captcha-item-hint">Click để ẩn</span>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>

                    <asp:PlaceHolder ID="phEmptyList" runat="server" Visible="false">
                        <div class="captcha-empty">Chưa có mã nào được nhập</div>
                    </asp:PlaceHolder>
                </div>
            </div>

            <asp:Button ID="btnSubmit" runat="server"
                Text="Đăng nhập"
                CssClass="btn-submit"
                OnClick="btnSubmit_Click" />

            <div class="form-footer" id="formFooter" runat="server">
                Chưa có tài khoản?
                <a href="#" onclick="switchTab('register',null);return false;">Đăng ký ngay</a>
            </div>
        </div>
    </div>

    <div class="toast" id="toast">
        <div class="toast-dot"></div>
        <span id="toastMsg">Thành công!</span>
    </div>
   
</form>
<script src="<%= ResolveUrl("~/Scripts/Login_Regis.js") %>" type="text/javascript"></script>
</body>
</html>
