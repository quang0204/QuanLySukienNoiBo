<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CaptchaList.aspx.cs" Inherits="QuanLySuKien.CaptchaList" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Quan ly ma xac nhan</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.2);
            padding: 32px;
        }
        h1 {
            color: #333;
            margin-bottom: 6px;
            font-size: 24px;
        }
        .subtitle {
            color: #777;
            margin-bottom: 24px;
            font-size: 13px;
        }
        .form-group { margin-bottom: 16px; }
        .form-group label {
            display: block;
            color: #444;
            font-weight: 600;
            font-size: 13px;
            margin-bottom: 6px;
        }
        .form-group input[type="text"] {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #d0d0d0;
            border-radius: 6px;
            font-size: 14px;
            font-family: 'Courier New', monospace;
            letter-spacing: 2px;
            text-transform: uppercase;
        }
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }
        .rule-text {
            font-size: 11px;
            color: #888;
            margin-top: 4px;
            font-style: italic;
        }
        .btn-add {
            background: #667eea;
            color: #fff;
            border: none;
            padding: 12px 24px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            margin-top: 8px;
        }
        .btn-add:hover { background: #5568d3; }

        .msg-error {
            background: #fee2e2;
            color: #c53030;
            padding: 10px 14px;
            border-radius: 6px;
            font-size: 13px;
            margin-bottom: 16px;
        }
        .msg-success {
            background: #d4edda;
            color: #155724;
            padding: 10px 14px;
            border-radius: 6px;
            font-size: 13px;
            margin-bottom: 16px;
        }

        /* Danh sach */
        .list-header {
            margin-top: 28px;
            padding-top: 20px;
            border-top: 2px dashed #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .list-title {
            font-size: 16px;
            color: #333;
            font-weight: 600;
        }
        .list-count {
            background: #667eea;
            color: #fff;
            padding: 3px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .item-row {
            display: flex;
            align-items: center;
            padding: 12px 14px;
            margin-top: 10px;
            background: #f8f8fc;
            border: 1px solid #e6e6f0;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .item-row:hover {
            background: #fff0f0;
            border-color: #f88;
        }
        .item-index {
            background: #667eea;
            color: #fff;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
            margin-right: 12px;
            flex-shrink: 0;
        }
        .item-code {
            flex: 1;
            font-family: 'Courier New', monospace;
            font-size: 18px;
            font-weight: bold;
            letter-spacing: 3px;
            color: #333;
        }
        .item-hint {
            color: #999;
            font-size: 11px;
            font-style: italic;
        }
        .item-row:hover .item-hint { color: #c00; }
        .empty-list {
            text-align: center;
            padding: 30px;
            color: #999;
            font-style: italic;
        }
        .clear-all {
            background: transparent;
            border: 1px solid #ccc;
            color: #666;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 11px;
            cursor: pointer;
            margin-left: 8px;
        }
        .clear-all:hover { border-color: #c00; color: #c00; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h1>Quan ly ma xac nhan</h1>
            <div class="subtitle">Nhap ma + Enter de them vao danh sach. Click 1 muc trong danh sach de an no di.</div>

            <%-- ═══ MESSAGE ═══ --%>
            <asp:Panel ID="pnlError" runat="server" CssClass="msg-error" Visible="false">
                <asp:Label ID="lblError" runat="server" />
            </asp:Panel>
            <asp:Panel ID="pnlSuccess" runat="server" CssClass="msg-success" Visible="false">
                <asp:Label ID="lblSuccess" runat="server" />
            </asp:Panel>

            <%-- ═══ FORM NHAP ═══ --%>
            <div class="form-group">
                <label for="<%= txtMa.ClientID %>">Ma xac nhan</label>
                <asp:TextBox ID="txtMa" runat="server" placeholder="Vi du: AB3C5@" MaxLength="10" />
                <div class="rule-text">
                    * Quy tac: 3 chu HOA + 2 chu so (khong ke thu tu) + ket thuc bang @
                </div>

                <asp:RequiredFieldValidator runat="server"
                    ControlToValidate="txtMa"
                    ErrorMessage="Vui long nhap ma!"
                    Display="Dynamic"
                    CssClass="rule-text"
                    ForeColor="Red" />

                <asp:RegularExpressionValidator runat="server"
                    ControlToValidate="txtMa"
                    ValidationExpression="^(?=(?:[^A-Z]*[A-Z]){3}[^A-Z]*$)(?=(?:[^0-9]*[0-9]){2}[^0-9]*$)[A-Z0-9]{5}@$"
                    ErrorMessage="Sai format! Phai co 3 chu HOA + 2 so + @"
                    Display="Dynamic"
                    CssClass="rule-text"
                    ForeColor="Red" />
            </div>

            <asp:Button ID="btnAdd" runat="server"
                Text="Them vao danh sach"
                CssClass="btn-add"
                OnClick="btnAdd_Click" />

            <%-- ═══ DANH SACH ═══ --%>
            <div class="list-header">
                <div class="list-title">
                    Danh sach ma da nhap
                    <span class="list-count"><asp:Label ID="lblCount" runat="server" Text="0" /></span>
                </div>
                <asp:Button ID="btnClearAll" runat="server"
                    Text="Xoa tat ca"
                    CssClass="clear-all"
                    CausesValidation="false"
                    OnClick="btnClearAll_Click" />
            </div>

            <%-- Repeater render danh sach co thu tu --%>
            <asp:Repeater ID="rptList" runat="server" OnItemCommand="rptList_ItemCommand">
                <ItemTemplate>
                    <asp:LinkButton runat="server"
                        CssClass="item-row"
                        CommandName="HideItem"
                        CommandArgument='<%# Container.ItemIndex %>'
                        CausesValidation="false">
                        <span class="item-index"><%# Container.ItemIndex + 1 %></span>
                        <span class="item-code"><%# Container.DataItem %></span>
                        <span class="item-hint">Click de an</span>
                    </asp:LinkButton>
                </ItemTemplate>
            </asp:Repeater>

            <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
                <div class="empty-list">Chua co ma nao. Hay nhap o tren!</div>
            </asp:PlaceHolder>
        </div>
    </form>
</body>
</html>
