-- ╔══════════════════════════════════════════════════════════════════╗
-- ║       EventHub  –  Hệ thống Quản lý Sự kiện Nội bộ            ║
-- ║       T-SQL  ·  SQL Server 2019+  ·  SSMS                     ║
-- ╚══════════════════════════════════════════════════════════════════╝

-- ════════════════════════════════════════════════════════════════════
-- BƯỚC 1: Tạo Database
-- ════════════════════════════════════════════════════════════════════
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'EventHub')
BEGIN
    CREATE DATABASE EventHub
    COLLATE Vietnamese_CI_AS;
END
GO

USE EventHub;
GO

-- ════════════════════════════════════════════════════════════════════
-- BƯỚC 2: Xóa bảng cũ nếu tồn tại (theo thứ tự FK)
-- ════════════════════════════════════════════════════════════════════
IF OBJECT_ID('dbo.CaiDatThongBao', 'U') IS NOT NULL  DROP TABLE dbo.CaiDatThongBao;
IF OBJECT_ID('dbo.ThongBao',        'U') IS NOT NULL  DROP TABLE dbo.ThongBao;
IF OBJECT_ID('dbo.Feedback',        'U') IS NOT NULL  DROP TABLE dbo.Feedback;
IF OBJECT_ID('dbo.DanhSachCho',     'U') IS NOT NULL  DROP TABLE dbo.DanhSachCho;
IF OBJECT_ID('dbo.DangKy',          'U') IS NOT NULL  DROP TABLE dbo.DangKy;
IF OBJECT_ID('dbo.SuKien',          'U') IS NOT NULL  DROP TABLE dbo.SuKien;
IF OBJECT_ID('dbo.CaiDatHeThong',   'U') IS NOT NULL  DROP TABLE dbo.CaiDatHeThong;
IF OBJECT_ID('dbo.Users',           'U') IS NOT NULL  DROP TABLE dbo.Users;
GO

-- ════════════════════════════════════════════════════════════════════
-- BẢNG 1: Users
-- Phân quyền: VaiTro = 'admin' | 'user'
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE dbo.Users (
    UserID          INT             NOT NULL IDENTITY(1,1),
    Ho              NVARCHAR(50)    NOT NULL,
    Ten             NVARCHAR(50)    NOT NULL,
    Email           NVARCHAR(150)   NOT NULL,
    MatKhau         NVARCHAR(255)   NOT NULL,
    SoDienThoai     NVARCHAR(20)    NULL,
    PhongBan        NVARCHAR(100)   NULL,
    ChucVu          NVARCHAR(100)   NULL,
    VanPhong        NVARCHAR(50)    NULL,
    CapBac          NVARCHAR(50)    NULL,
    NamVaoLam       SMALLINT        NULL,
    Avatar          NVARCHAR(500)   NULL,
    VaiTro          NVARCHAR(10)    NOT NULL DEFAULT 'user'
        CONSTRAINT chk_users_vaitro    CHECK (VaiTro IN ('admin','user')),
    TrangThai       NVARCHAR(20)    NOT NULL DEFAULT 'active'
        CONSTRAINT chk_users_trangthai CHECK (TrangThai IN ('active','inactive','banned')),
    NgayTao         DATETIME        NOT NULL DEFAULT GETDATE(),
    NgayCapNhat     DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_users       PRIMARY KEY (UserID),
    CONSTRAINT uq_users_email UNIQUE      (Email)
);
GO

-- ════════════════════════════════════════════════════════════════════
-- BẢNG 2: SuKien
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE dbo.SuKien (
    SuKienID        INT             NOT NULL IDENTITY(1,1),
    TenSuKien       NVARCHAR(200)   NOT NULL,
    MoTa            NVARCHAR(MAX)   NULL,
    LoaiSuKien      NVARCHAR(30)    NOT NULL
        CONSTRAINT chk_sk_loai CHECK (LoaiSuKien IN ('Team Building','Workshop','Dao tao','Hoi thao')),
    NgayBatDau      DATE            NOT NULL,
    NgayKetThuc     DATE            NULL,
    GioBatDau       TIME(0)         NOT NULL DEFAULT '08:00:00',
    GioKetThuc      TIME(0)         NULL     DEFAULT '17:00:00',
    DiaDiem         NVARCHAR(300)   NOT NULL,
    LinkBanDo       NVARCHAR(500)   NULL,
    SucChua         INT             NOT NULL DEFAULT 50,
    HanDangKy       DATE            NULL,
    AnhBia          NVARCHAR(500)   NULL,
    TrangThai       NVARCHAR(20)    NOT NULL DEFAULT 'draft'
        CONSTRAINT chk_sk_trangthai CHECK (TrangThai IN ('draft','upcoming','open','closed','ended')),
    YeuCauDuyet     BIT             NOT NULL DEFAULT 0,
    DanhSachCho     BIT             NOT NULL DEFAULT 1,
    ChoPhepHuy      BIT             NOT NULL DEFAULT 1,
    BatFeedback     BIT             NOT NULL DEFAULT 1,
    NguoiTaoID      INT             NOT NULL,
    NgayTao         DATETIME        NOT NULL DEFAULT GETDATE(),
    NgayCapNhat     DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_sukien         PRIMARY KEY (SuKienID),
    CONSTRAINT fk_sk_nguoitao    FOREIGN KEY (NguoiTaoID)
        REFERENCES dbo.Users(UserID)
);
GO

-- ════════════════════════════════════════════════════════════════════
-- BẢNG 3: DangKy
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE dbo.DangKy (
    DangKyID        INT             NOT NULL IDENTITY(1,1),
    UserID          INT             NOT NULL,
    SuKienID        INT             NOT NULL,
    TrangThai       NVARCHAR(20)    NOT NULL DEFAULT 'pending'
        CONSTRAINT chk_dk_trangthai CHECK (TrangThai IN ('pending','approved','rejected','cancelled')),
    DaDiemDanh      BIT             NOT NULL DEFAULT 0,
    NgayDangKy      DATETIME        NOT NULL DEFAULT GETDATE(),
    NgayCapNhat     DATETIME        NOT NULL DEFAULT GETDATE(),
    GhiChu          NVARCHAR(MAX)   NULL,
    NguoiDuyetID    INT             NULL,
    NgayDuyet       DATETIME        NULL,

    CONSTRAINT pk_dangky            PRIMARY KEY (DangKyID),
    CONSTRAINT uq_dk_user_sukien    UNIQUE (UserID, SuKienID),
    CONSTRAINT fk_dk_user           FOREIGN KEY (UserID)
        REFERENCES dbo.Users(UserID),
    CONSTRAINT fk_dk_sukien         FOREIGN KEY (SuKienID)
        REFERENCES dbo.SuKien(SuKienID),
    CONSTRAINT fk_dk_duyet          FOREIGN KEY (NguoiDuyetID)
        REFERENCES dbo.Users(UserID)
);
GO

-- ════════════════════════════════════════════════════════════════════
-- BẢNG 4: DanhSachCho
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE dbo.DanhSachCho (
    WaitlistID      INT             NOT NULL IDENTITY(1,1),
    UserID          INT             NOT NULL,
    SuKienID        INT             NOT NULL,
    ViTri           INT             NOT NULL,
    TrangThai       NVARCHAR(20)    NOT NULL DEFAULT 'waiting'
        CONSTRAINT chk_wait_trangthai CHECK (TrangThai IN ('waiting','promoted','expired')),
    NgayThem        DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_danhsachcho       PRIMARY KEY (WaitlistID),
    CONSTRAINT uq_wait_user_sk      UNIQUE (UserID, SuKienID),
    CONSTRAINT fk_wait_user         FOREIGN KEY (UserID)
        REFERENCES dbo.Users(UserID),
    CONSTRAINT fk_wait_sukien       FOREIGN KEY (SuKienID)
        REFERENCES dbo.SuKien(SuKienID)
);
GO

-- ════════════════════════════════════════════════════════════════════
-- BẢNG 5: Feedback
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE dbo.Feedback (
    FeedbackID      INT             NOT NULL IDENTITY(1,1),
    UserID          INT             NOT NULL,
    SuKienID        INT             NOT NULL,
    Diem            TINYINT         NOT NULL
        CONSTRAINT chk_fb_diem CHECK (Diem BETWEEN 1 AND 5),
    NoiDung         NVARCHAR(MAX)   NULL,
    NgayGui         DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_feedback          PRIMARY KEY (FeedbackID),
    CONSTRAINT uq_fb_user_sk        UNIQUE (UserID, SuKienID),
    CONSTRAINT fk_fb_user           FOREIGN KEY (UserID)
        REFERENCES dbo.Users(UserID),
    CONSTRAINT fk_fb_sukien         FOREIGN KEY (SuKienID)
        REFERENCES dbo.SuKien(SuKienID)
);
GO

-- ════════════════════════════════════════════════════════════════════
-- BẢNG 6: ThongBao
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE dbo.ThongBao (
    ThongBaoID      INT             NOT NULL IDENTITY(1,1),
    UserID          INT             NOT NULL,
    SuKienID        INT             NULL,
    TieuDe          NVARCHAR(200)   NOT NULL,
    NoiDung         NVARCHAR(MAX)   NOT NULL,
    LoaiThongBao    NVARCHAR(20)    NOT NULL DEFAULT 'he_thong'
        CONSTRAINT chk_tb_loai CHECK (LoaiThongBao IN
            ('dang_ky','nhac_nho','duyet','huy','he_thong','feedback')),
    DaDoc           BIT             NOT NULL DEFAULT 0,
    NgayTao         DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_thongbao          PRIMARY KEY (ThongBaoID),
    CONSTRAINT fk_tb_user           FOREIGN KEY (UserID)
        REFERENCES dbo.Users(UserID),
    CONSTRAINT fk_tb_sukien         FOREIGN KEY (SuKienID)
        REFERENCES dbo.SuKien(SuKienID)
);
GO

-- ════════════════════════════════════════════════════════════════════
-- BẢNG 7: CaiDatThongBao  (1-1 với Users)
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE dbo.CaiDatThongBao (
    CaiDatTBID          INT         NOT NULL IDENTITY(1,1),
    UserID              INT         NOT NULL,
    NhanKhiDangKyMoi    BIT         NOT NULL DEFAULT 1,
    NhanNhacNho         BIT         NOT NULL DEFAULT 1,
    NhanKetQuaDuyet     BIT         NOT NULL DEFAULT 1,
    NhanSuKienMoi       BIT         NOT NULL DEFAULT 1,
    NhanEmailTongHop    BIT         NOT NULL DEFAULT 0,
    NgayCapNhat         DATETIME    NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_caidattb          PRIMARY KEY (CaiDatTBID),
    CONSTRAINT uq_cdtb_user         UNIQUE (UserID),
    CONSTRAINT fk_cdtb_user         FOREIGN KEY (UserID)
        REFERENCES dbo.Users(UserID)
);
GO

-- ════════════════════════════════════════════════════════════════════
-- BẢNG 8: CaiDatHeThong  (key-value, không FK)
-- ════════════════════════════════════════════════════════════════════
CREATE TABLE dbo.CaiDatHeThong (
    CaiDatID        INT             NOT NULL IDENTITY(1,1),
    KhoaCaiDat      NVARCHAR(100)   NOT NULL,
    GiaTri          NVARCHAR(MAX)   NOT NULL,
    MoTa            NVARCHAR(300)   NULL,
    NgayCapNhat     DATETIME        NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_caidathethong     PRIMARY KEY (CaiDatID),
    CONSTRAINT uq_cdht_khoa         UNIQUE (KhoaCaiDat)
);
GO

-- ════════════════════════════════════════════════════════════════════
-- INDEX bổ sung
-- ════════════════════════════════════════════════════════════════════
CREATE INDEX idx_users_vaitro       ON dbo.Users     (VaiTro);
CREATE INDEX idx_users_phongban     ON dbo.Users     (PhongBan);
CREATE INDEX idx_sk_trangthai       ON dbo.SuKien    (TrangThai);
CREATE INDEX idx_sk_ngaybatdau      ON dbo.SuKien    (NgayBatDau);
CREATE INDEX idx_sk_loai            ON dbo.SuKien    (LoaiSuKien);
CREATE INDEX idx_dk_trangthai       ON dbo.DangKy    (TrangThai);
CREATE INDEX idx_dk_diemdanh        ON dbo.DangKy    (DaDiemDanh);
CREATE INDEX idx_tb_user            ON dbo.ThongBao  (UserID);
CREATE INDEX idx_tb_daDoc           ON dbo.ThongBao  (DaDoc);
GO

-- ════════════════════════════════════════════════════════════════════
-- DỮ LIỆU MẪU
-- ════════════════════════════════════════════════════════════════════

-- ── Users ──────────────────────────────────────────────────────────
SET IDENTITY_INSERT dbo.Users ON;
INSERT INTO dbo.Users
    (UserID,Ho,Ten,Email,MatKhau,PhongBan,ChucVu,VanPhong,CapBac,NamVaoLam,VaiTro,TrangThai)
VALUES
(1,N'Nguyễn',N'Admin',    N'admin@company.com',    N'$2b$12$HASH_ADMIN',  N'IT',          N'System Administrator',N'HCM',N'Lead',  2020,'admin','active'),
(2,N'Trần',  N'HR Manager',N'hr@company.com',      N'$2b$12$HASH_HR',    N'HR',           N'HR Manager',         N'HCM',N'Senior',2019,'admin','active'),
(3,N'Nguyễn',N'Văn An',   N'vana@company.com',     N'$2b$12$HASH_U1',    N'Engineering',  N'Software Engineer',  N'HCM',N'Senior',2021,'user', 'active'),
(4,N'Lê',    N'Thành',    N'lethanh@company.com',  N'$2b$12$HASH_U2',    N'Engineering',  N'Backend Developer',  N'HCM',N'Junior',2023,'user', 'active'),
(5,N'Phạm',  N'Thu',      N'phamthu@company.com',  N'$2b$12$HASH_U3',    N'Design',       N'UI/UX Designer',     N'HCM',N'Senior',2020,'user', 'active'),
(6,N'Hoàng', N'Nam',      N'hoangnam@company.com', N'$2b$12$HASH_U4',    N'Product',      N'Product Manager',    N'HN', N'Lead',  2018,'user', 'active'),
(7,N'Vũ',    N'Khánh',    N'vukhanh@company.com',  N'$2b$12$HASH_U5',    N'Marketing',    N'Marketing Specialist',N'HCM',N'Junior',2022,'user','active');
SET IDENTITY_INSERT dbo.Users OFF;
GO

-- ── SuKien ─────────────────────────────────────────────────────────
SET IDENTITY_INSERT dbo.SuKien ON;
INSERT INTO dbo.SuKien
    (SuKienID,TenSuKien,MoTa,LoaiSuKien,
     NgayBatDau,NgayKetThuc,GioBatDau,GioKetThuc,
     DiaDiem,LinkBanDo,SucChua,HanDangKy,
     TrangThai,YeuCauDuyet,DanhSachCho,ChoPhepHuy,BatFeedback,NguoiTaoID)
VALUES
(1,N'Team Building Q2 2025',
 N'Hoạt động gắn kết đội nhóm quý 2. Trò chơi ngoài trời và giao lưu văn hóa.',
 N'Team Building',
 '2025-04-28','2025-04-30','08:00','17:00',
 N'Đà Lạt, Lâm Đồng',N'https://maps.google.com/?q=Da+Lat',
 120,'2025-04-20','open',0,1,1,1,1),

(2,N'Workshop UX Research & User Testing Q2 2025',
 N'Workshop chuyên sâu về nghiên cứu và kiểm thử người dùng.',
 N'Workshop',
 '2025-04-23',NULL,'09:00','17:00',
 N'Innovation Lab, Tầng 12, Tòa A',NULL,
 50,'2025-04-18','open',1,1,1,1,1),

(3,N'Đào tạo An toàn Thông tin 2025',
 N'Khóa đào tạo bắt buộc về an toàn bảo mật cho toàn bộ nhân viên.',
 N'Dao tao',
 '2025-05-10',NULL,'09:00','16:00',
 N'Hội trường A, Tầng 3',NULL,
 200,'2025-05-05','upcoming',0,0,0,1,1),

(4,N'Hội thảo Leadership Excellence',
 N'Hội thảo kỹ năng lãnh đạo dành cho cấp quản lý và nhân viên tiềm năng.',
 N'Hoi thao',
 '2025-05-05',NULL,'08:30','17:30',
 N'Hội trường lớn, Tầng 1',NULL,
 130,'2025-04-28','open',1,1,1,1,1),

(5,N'Workshop Design Thinking',
 N'Áp dụng tư duy thiết kế để giải quyết vấn đề kinh doanh thực tế.',
 N'Workshop',
 '2025-04-15',NULL,'09:00','17:00',
 N'Phòng Training, Tầng 5',NULL,
 40,'2025-04-10','ended',0,1,1,1,1);
SET IDENTITY_INSERT dbo.SuKien OFF;
GO

-- ── DangKy ─────────────────────────────────────────────────────────
INSERT INTO dbo.DangKy (UserID,SuKienID,TrangThai,DaDiemDanh) VALUES
(3,1,'approved',0),(4,1,'approved',0),(5,1,'approved',0),
(6,1,'pending', 0),(7,1,'approved',0),
(3,2,'approved',0),(5,2,'approved',0),(6,2,'pending',0),
(3,4,'pending', 0),
-- Sự kiện đã kết thúc – đã điểm danh
(3,5,'approved',1),(4,5,'approved',1),(5,5,'approved',1);
GO

-- ── Feedback ───────────────────────────────────────────────────────
INSERT INTO dbo.Feedback (UserID,SuKienID,Diem,NoiDung) VALUES
(3,5,5,N'Rất bổ ích! Giảng viên nhiệt tình, nội dung thực tế dễ áp dụng ngay.'),
(4,5,4,N'Nội dung tốt nhưng thời gian hơi ngắn, muốn thực hành nhiều hơn.'),
(5,5,5,N'Tuyệt vời! Học được nhiều kỹ năng áp dụng ngay vào công việc.');
GO

-- ── ThongBao ───────────────────────────────────────────────────────
INSERT INTO dbo.ThongBao (UserID,SuKienID,TieuDe,NoiDung,LoaiThongBao,DaDoc) VALUES
(3,1,N'Đăng ký Team Building Q2 thành công',
 N'Bạn đã đăng ký thành công sự kiện Team Building Q2 2025.',
 'dang_ky',0),
(3,3,N'Sự kiện sắp diễn ra: Đào tạo ATTT',
 N'Nhắc nhở: Đào tạo An toàn Thông tin diễn ra vào ngày 10/05.',
 'nhac_nho',0),
(3,5,N'Workshop Design Thinking – Đã kết thúc',
 N'Cảm ơn bạn đã tham dự! Đừng quên để lại đánh giá.',
 'feedback',1),
(4,1,N'Đăng ký Team Building Q2 thành công',
 N'Bạn đã đăng ký thành công sự kiện Team Building Q2 2025.',
 'dang_ky',1);
GO

-- ── CaiDatThongBao ─────────────────────────────────────────────────
INSERT INTO dbo.CaiDatThongBao
    (UserID,NhanKhiDangKyMoi,NhanNhacNho,NhanKetQuaDuyet,NhanSuKienMoi,NhanEmailTongHop)
VALUES
(3,1,1,1,1,0),(4,1,1,1,0,0),(5,1,1,1,1,1),(6,1,0,1,1,0),(7,1,1,0,1,0);
GO

-- ── CaiDatHeThong ──────────────────────────────────────────────────
INSERT INTO dbo.CaiDatHeThong (KhoaCaiDat,GiaTri,MoTa) VALUES
(N'ten_cong_ty',           N'Cong ty TNHH Tech Solutions',  N'txtTenCongTy'),
(N'ten_he_thong',          N'EventHub',                     N'txtTenHeThong'),
(N'email_lien_he',         N'hr@techsols.vn',               N'txtEmail'),
(N'so_dien_thoai',         N'024 3898 xxxx',                N'txtPhone'),
(N'dia_chi',               N'123 Nguyen Hue, Q1, TP.HCM',  N'txtDiaChi'),
(N'suc_chua_mac_dinh',     N'50',                           N'txtSucChuaMacDinh'),
(N'dong_dky_truoc_gio',    N'24',                           N'ddlDongTruoc'),
(N'yeu_cau_duyet_mac_dinh',N'0',                            N'chkYeuCauDuyet'),
(N'bat_danh_sach_cho',     N'1',                            N'chkDanhSachCho'),
(N'cho_phep_huy_dky',      N'1',                            N'chkHuyDangKy'),
(N'yeu_cau_dang_nhap',     N'1',                            N'chkYeuCauDangNhap'),
(N'cho_phep_tu_dky',       N'1',                            N'chkTuDangKy');
GO

-- ════════════════════════════════════════════════════════════════════
-- VIEWS
-- ════════════════════════════════════════════════════════════════════

-- ── AdminDashboard: lblTotalEvents, lblTotalParticipants...
CREATE OR ALTER VIEW dbo.v_Dashboard AS
SELECT
    (SELECT COUNT(*) FROM dbo.SuKien WHERE TrangThai IN ('open','upcoming'))     AS SuKienDangMo,
    (SELECT COUNT(*) FROM dbo.SuKien)                                             AS TongSuKien,
    (SELECT COUNT(*) FROM dbo.DangKy WHERE TrangThai = 'approved')                AS TongDaDuyet,
    (SELECT COUNT(*) FROM dbo.DangKy WHERE TrangThai = 'pending')                 AS TongChoDuyet,
    (SELECT COUNT(*) FROM dbo.DangKy WHERE DaDiemDanh = 1)                        AS TongDaDiemDanh,
    (SELECT COUNT(*) FROM dbo.Users  WHERE VaiTro='user' AND TrangThai='active')  AS TongNguoiDung,
    (SELECT ROUND(AVG(CAST(Diem AS FLOAT)),1) FROM dbo.Feedback)                  AS DiemFeedbackTB,
    (SELECT COUNT(*) FROM dbo.SuKien
     WHERE MONTH(NgayBatDau)=MONTH(GETDATE())
       AND YEAR(NgayBatDau)=YEAR(GETDATE()))                                       AS SuKienThangNay;
GO

-- ── AdminEvents gvEvents
CREATE OR ALTER VIEW dbo.v_SuKien_DayDu AS
SELECT
    s.SuKienID, s.TenSuKien, s.LoaiSuKien,
    s.NgayBatDau, s.GioBatDau, s.GioKetThuc, s.DiaDiem,
    s.SucChua, s.TrangThai, s.YeuCauDuyet, s.DanhSachCho, s.ChoPhepHuy, s.BatFeedback,
    ISNULL(dk.SoDaDangKy, 0)                                     AS SoDaDangKy,
    s.SucChua - ISNULL(dk.SoDaDangKy, 0)                        AS ConLai,
    ISNULL(att.SoThamDu, 0)                                      AS SoThamDu,
    ISNULL(fb.DiemTB, 0)                                         AS DiemHaiLong,
    u.Ho + N' ' + u.Ten                                          AS NguoiTao
FROM dbo.SuKien s
LEFT JOIN (SELECT SuKienID, COUNT(*) AS SoDaDangKy
           FROM dbo.DangKy WHERE TrangThai='approved' GROUP BY SuKienID) dk
       ON s.SuKienID = dk.SuKienID
LEFT JOIN (SELECT SuKienID, COUNT(*) AS SoThamDu
           FROM dbo.DangKy WHERE DaDiemDanh=1 GROUP BY SuKienID) att
       ON s.SuKienID = att.SuKienID
LEFT JOIN (SELECT SuKienID, ROUND(AVG(CAST(Diem AS FLOAT)),1) AS DiemTB
           FROM dbo.Feedback GROUP BY SuKienID) fb
       ON s.SuKienID = fb.SuKienID
LEFT JOIN dbo.Users u ON s.NguoiTaoID = u.UserID;
GO

-- ── AdminParticipants gvParticipants
CREATE OR ALTER VIEW dbo.v_Participants AS
SELECT
    dk.DangKyID,
    dk.UserID                           AS MaNguoiDung,
    dk.SuKienID,
    u.Ho + N' ' + u.Ten                 AS HoTen,
    LEFT(u.Ho,1) + LEFT(u.Ten,1)        AS TenVietTat,
    u.Email, u.PhongBan,
    dk.TrangThai, dk.DaDiemDanh,
    dk.NgayDangKy, dk.GhiChu,
    ad.Ho + N' ' + ad.Ten               AS NguoiDuyet,
    dk.NgayDuyet
FROM dbo.DangKy dk
JOIN  dbo.Users  u  ON dk.UserID      = u.UserID
JOIN  dbo.SuKien s  ON dk.SuKienID    = s.SuKienID
LEFT JOIN dbo.Users ad ON dk.NguoiDuyetID = ad.UserID;
GO

-- ── AdminReports gvReport
CREATE OR ALTER VIEW dbo.v_Report_SuKien AS
SELECT
    s.SuKienID, s.TenSuKien, s.LoaiSuKien,
    s.NgayBatDau                                                  AS NgayToChuc,
    ISNULL(dk.SoDangKy,0)                                        AS SoDangKy,
    ISNULL(att.SoThamDu,0)                                       AS SoThamDu,
    CASE WHEN ISNULL(dk.SoDangKy,0)>0
         THEN ROUND(CAST(ISNULL(att.SoThamDu,0) AS FLOAT)
                   /dk.SoDangKy*100, 0) ELSE 0 END               AS TyLe,
    ISNULL(fb.DiemTB,0)                                          AS DiemHaiLong
FROM dbo.SuKien s
LEFT JOIN (SELECT SuKienID, COUNT(*) AS SoDangKy
           FROM dbo.DangKy WHERE TrangThai='approved' GROUP BY SuKienID) dk
       ON s.SuKienID = dk.SuKienID
LEFT JOIN (SELECT SuKienID, COUNT(*) AS SoThamDu
           FROM dbo.DangKy WHERE DaDiemDanh=1 GROUP BY SuKienID) att
       ON s.SuKienID = att.SuKienID
LEFT JOIN (SELECT SuKienID, ROUND(AVG(CAST(Diem AS FLOAT)),1) AS DiemTB
           FROM dbo.Feedback GROUP BY SuKienID) fb
       ON s.SuKienID = fb.SuKienID;
GO

-- ── AdminReports: top phòng ban
CREATE OR ALTER VIEW dbo.v_Report_PhongBan AS
SELECT u.PhongBan, COUNT(*) AS SoLuotDangKy
FROM dbo.DangKy dk
JOIN dbo.Users u ON dk.UserID = u.UserID
WHERE dk.TrangThai = 'approved'
GROUP BY u.PhongBan;
GO

-- ── AdminReports: xu hướng theo tháng
CREATE OR ALTER VIEW dbo.v_Report_TheoThang AS
SELECT
    YEAR(dk.NgayDangKy)   AS Nam,
    MONTH(dk.NgayDangKy)  AS Thang,
    COUNT(*)              AS SoDangKy,
    SUM(CAST(dk.DaDiemDanh AS INT)) AS SoThamDu
FROM dbo.DangKy dk
WHERE dk.TrangThai = 'approved'
GROUP BY YEAR(dk.NgayDangKy), MONTH(dk.NgayDangKy);
GO

-- ── UserProfile + UserCalendar
-- Tạo lại: tách subquery "sự kiện sắp tới" ra CTE riêng
-- thay vì lồng IN (SELECT...) bên trong SUM()
CREATE VIEW dbo.v_User_ThongKe AS
 
WITH SapToi_CTE AS (
    -- Danh sách DangKyID của sự kiện chưa diễn ra
    SELECT dk.UserID, dk.DangKyID
    FROM dbo.DangKy dk
    JOIN dbo.SuKien s ON dk.SuKienID = s.SuKienID
    WHERE dk.TrangThai = 'approved'
      AND s.NgayBatDau >= CAST(GETDATE() AS DATE)
),
Stats_CTE AS (
    SELECT
        dk.UserID,
        COUNT(*)                        AS TongDK,
        SUM(CAST(dk.DaDiemDanh AS INT)) AS DaThamDu,
        COUNT(st.DangKyID)              AS SapToi   -- đếm join thay vì SUM(CASE IN subquery)
    FROM dbo.DangKy dk
    LEFT JOIN SapToi_CTE st ON dk.DangKyID = st.DangKyID
    WHERE dk.TrangThai IN ('approved','pending')
    GROUP BY dk.UserID
)
 
SELECT
    u.UserID,
    u.Ho + N' ' + u.Ten             AS HoTen,
    u.PhongBan, u.ChucVu,
    u.VanPhong, u.CapBac, u.NamVaoLam,
    ISNULL(s.DaThamDu, 0)           AS DaThamDu,
    ISNULL(s.SapToi,   0)           AS SapToi,
    ISNULL(fb.DiemTB,  0)           AS DiemFeedbackTB,
    CASE
        WHEN ISNULL(s.TongDK, 0) > 0
        THEN ROUND(CAST(ISNULL(s.DaThamDu,0) AS FLOAT) / s.TongDK * 100, 0)
        ELSE 0
    END                             AS TyLeThamDu
FROM dbo.Users u
LEFT JOIN Stats_CTE s  ON u.UserID = s.UserID
LEFT JOIN (
    SELECT UserID,
           ROUND(AVG(CAST(Diem AS FLOAT)), 1) AS DiemTB
    FROM dbo.Feedback
    GROUP BY UserID
) fb ON u.UserID = fb.UserID
WHERE u.VaiTro = 'user';
GO
 
-- Kiểm tra
SELECT TOP 5 * FROM dbo.v_User_ThongKe;
GO

-- ════════════════════════════════════════════════════════════════════
-- STORED PROCEDURES  (T-SQL syntax)
-- ════════════════════════════════════════════════════════════════════

-- ── sp_DangKySuKien ────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.sp_DangKySuKien
    @p_UserID    INT,
    @p_SuKienID  INT,
    @p_GhiChu    NVARCHAR(MAX),
    @p_KetQua    NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TrangThaiSK  NVARCHAR(20),
            @SucChua      INT,
            @DanhSachCho  BIT,
            @YeuCauDuyet  BIT,
            @DaDuyet      INT,
            @DaDangKy     INT,
            @MaxViTri     INT;

    SELECT @TrangThaiSK = TrangThai, @SucChua = SucChua,
           @DanhSachCho = DanhSachCho, @YeuCauDuyet = YeuCauDuyet
    FROM dbo.SuKien WHERE SuKienID = @p_SuKienID;

    IF @TrangThaiSK <> 'open'
    BEGIN
        SET @p_KetQua = 'KHONG_MO'; RETURN;
    END

    SELECT @DaDangKy = COUNT(*) FROM dbo.DangKy
    WHERE UserID=@p_UserID AND SuKienID=@p_SuKienID;

    IF @DaDangKy > 0
    BEGIN
        SET @p_KetQua = 'DA_DANG_KY'; RETURN;
    END

    SELECT @DaDuyet = COUNT(*) FROM dbo.DangKy
    WHERE SuKienID=@p_SuKienID AND TrangThai='approved';

    IF @DaDuyet < @SucChua
    BEGIN
        IF @YeuCauDuyet = 1
        BEGIN
            INSERT INTO dbo.DangKy(UserID,SuKienID,TrangThai,GhiChu)
            VALUES(@p_UserID,@p_SuKienID,'pending',@p_GhiChu);
            SET @p_KetQua = 'CHO_DUYET';
        END
        ELSE
        BEGIN
            INSERT INTO dbo.DangKy(UserID,SuKienID,TrangThai,GhiChu)
            VALUES(@p_UserID,@p_SuKienID,'approved',@p_GhiChu);
            SET @p_KetQua = 'THANH_CONG';
        END
    END
    ELSE IF @DanhSachCho = 1
    BEGIN
        SELECT @MaxViTri = ISNULL(MAX(ViTri),0)+1
        FROM dbo.DanhSachCho WHERE SuKienID=@p_SuKienID AND TrangThai='waiting';

        INSERT INTO dbo.DanhSachCho(UserID,SuKienID,ViTri)
        VALUES(@p_UserID,@p_SuKienID,@MaxViTri);
        SET @p_KetQua = 'VAO_HANG_CHO';
    END
    ELSE
    BEGIN
        SET @p_KetQua = 'HET_CHO';
    END
END;
GO

-- ── sp_DuyetDangKy ─────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.sp_DuyetDangKy
    @p_DangKyID  INT,
    @p_AdminID   INT,
    @p_TrangThai NVARCHAR(20),   -- 'approved' hoặc 'rejected'
    @p_KetQua    NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.DangKy
       SET TrangThai=@p_TrangThai, NguoiDuyetID=@p_AdminID, NgayDuyet=GETDATE()
     WHERE DangKyID=@p_DangKyID;

    SET @p_KetQua = CASE WHEN @@ROWCOUNT > 0 THEN 'OK' ELSE 'NOT_FOUND' END;
END;
GO

-- ── sp_DiemDanh ────────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.sp_DiemDanh
    @p_DangKyID  INT,
    @p_KetQua    NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.DangKy SET DaDiemDanh=1
    WHERE DangKyID=@p_DangKyID AND TrangThai='approved';

    SET @p_KetQua = CASE WHEN @@ROWCOUNT > 0 THEN 'OK' ELSE 'FAIL' END;
END;
GO

-- ── sp_HuyDangKy ───────────────────────────────────────────────────
CREATE OR ALTER PROCEDURE dbo.sp_HuyDangKy
    @p_UserID    INT,
    @p_SuKienID  INT,
    @p_KetQua    NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ChoPhepHuy BIT;

    SELECT @ChoPhepHuy = ChoPhepHuy FROM dbo.SuKien WHERE SuKienID=@p_SuKienID;

    IF @ChoPhepHuy = 0
    BEGIN
        SET @p_KetQua = 'KHONG_CHO_HUY'; RETURN;
    END

    UPDATE dbo.DangKy SET TrangThai='cancelled'
    WHERE UserID=@p_UserID AND SuKienID=@p_SuKienID
      AND TrangThai IN ('pending','approved');

    SET @p_KetQua = CASE WHEN @@ROWCOUNT > 0 THEN 'OK' ELSE 'NOT_FOUND' END;
END;
GO

-- ════════════════════════════════════════════════════════════════════
-- KIỂM TRA – chạy sau khi import xong
-- ════════════════════════════════════════════════════════════════════
SELECT 'Users'           AS [Bang], COUNT(*) AS [SoBan] FROM dbo.Users
UNION ALL
SELECT 'SuKien',                    COUNT(*) FROM dbo.SuKien
UNION ALL
SELECT 'DangKy',                    COUNT(*) FROM dbo.DangKy
UNION ALL
SELECT 'Feedback',                  COUNT(*) FROM dbo.Feedback
UNION ALL
SELECT 'ThongBao',                  COUNT(*) FROM dbo.ThongBao
UNION ALL
SELECT 'CaiDatThongBao',            COUNT(*) FROM dbo.CaiDatThongBao
UNION ALL
SELECT 'CaiDatHeThong',             COUNT(*) FROM dbo.CaiDatHeThong;
GO
select* from dbo.Users;
select* from dbo.DangKy;
select* from dbo.Feedback;
select* from dbo.DanhSachCho;
select* from dbo.SuKien;
select* from dbo.CaiDatThongBao;
select* from dbo.CaiDatHeThong;
select* from dbo.ThongBao;
select* from dbo.Users;
USE EventHub;
GO
 
UPDATE dbo.Users SET MatKhau = N'Admin@123'   WHERE Email = N'admin@company.com';
UPDATE dbo.Users SET MatKhau = N'Admin@123'   WHERE Email = N'hr@company.com';
UPDATE dbo.Users SET MatKhau = N'User@123'    WHERE Email = N'vana@company.com';
UPDATE dbo.Users SET MatKhau = N'User@123'    WHERE Email = N'lethanh@company.com';
UPDATE dbo.Users SET MatKhau = N'User@123'    WHERE Email = N'phamthu@company.com';
UPDATE dbo.Users SET MatKhau = N'User@123'    WHERE Email = N'hoangnam@company.com';
UPDATE dbo.Users SET MatKhau = N'User@123'    WHERE Email = N'vukhanh@company.com';
GO
 
-- Kiểm tra
SELECT UserID, Ho, Ten, Email, MatKhau, VaiTro, TrangThai
FROM dbo.Users;
GO
USE EventHub;
GO
-- Đổi mật khẩu data mẫu về plaintext để test login
UPDATE dbo.Users SET MatKhau = 'Admin@123' WHERE Email = 'admin@company.com';
UPDATE dbo.Users SET MatKhau = 'Admin@123' WHERE Email = 'hr@company.com';
UPDATE dbo.Users SET MatKhau = 'User@123'  WHERE Email = 'vana@company.com';
UPDATE dbo.Users SET MatKhau = 'User@123'  WHERE Email = 'lethanh@company.com';
UPDATE dbo.Users SET MatKhau = 'User@123'  WHERE Email = 'phamthu@company.com';
UPDATE dbo.Users SET MatKhau = 'User@123'  WHERE Email = 'hoangnam@company.com';
UPDATE dbo.Users SET MatKhau = 'User@123'  WHERE Email = 'vukhanh@company.com';
GO
SELECT UserID, Email, MatKhau, VaiTro FROM dbo.Users;
GO
USE EventHub;
GO
 
CREATE OR ALTER PROCEDURE dbo.sp_DuyetDangKy
    @p_DangKyID  INT,
    @p_AdminID   INT,
    @p_TrangThai NVARCHAR(20),   -- 'approved' hoặc 'rejected'
    @p_KetQua    NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @SuKienID INT, @SucChua INT, @DaDuyet INT, @TrangThaiSK NVARCHAR(20);
 
    -- 1. Cập nhật trạng thái đăng ký
    UPDATE dbo.DangKy
       SET TrangThai = @p_TrangThai,
           NguoiDuyetID = @p_AdminID,
           NgayDuyet = GETDATE(),
           NgayCapNhat = GETDATE()
     WHERE DangKyID = @p_DangKyID;
 
    IF @@ROWCOUNT = 0
    BEGIN
        SET @p_KetQua = 'NOT_FOUND';
        RETURN;
    END
 
    -- 2. Nếu là 'approved', kiểm tra xem sự kiện đã full chưa
    IF @p_TrangThai = 'approved'
    BEGIN
        SELECT @SuKienID = SuKienID FROM dbo.DangKy WHERE DangKyID = @p_DangKyID;
 
        SELECT @SucChua = SucChua, @TrangThaiSK = TrangThai
        FROM dbo.SuKien
        WHERE SuKienID = @SuKienID;
 
        SELECT @DaDuyet = COUNT(*)
        FROM dbo.DangKy
        WHERE SuKienID = @SuKienID AND TrangThai = 'approved';
 
        -- Nếu đã đầy chỗ và đang 'open' -> chuyển sang 'closed'
        IF @DaDuyet >= @SucChua AND @TrangThaiSK = 'open'
        BEGIN
            UPDATE dbo.SuKien
               SET TrangThai = 'closed', NgayCapNhat = GETDATE()
             WHERE SuKienID = @SuKienID;
        END
    END
 
    SET @p_KetQua = 'OK';
END;
GO
 
-- ════════════════════════════════════════════════════════════════════
-- (Tùy chọn) Trigger tự động đóng sự kiện khi DangKy được approve
-- Dùng cho trường hợp duyệt đăng ký không qua sp_DuyetDangKy
-- ════════════════════════════════════════════════════════════════════
 
IF OBJECT_ID('dbo.tr_DangKy_AutoCloseEvent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DangKy_AutoCloseEvent;
GO
 
CREATE TRIGGER dbo.tr_DangKy_AutoCloseEvent
ON dbo.DangKy
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
 
    -- Lấy danh sách SuKienID bị ảnh hưởng và đang ở trạng thái 'open'
    UPDATE s
       SET s.TrangThai = 'closed', s.NgayCapNhat = GETDATE()
      FROM dbo.SuKien s
     WHERE s.TrangThai = 'open'
       AND s.SuKienID IN (SELECT DISTINCT SuKienID FROM inserted)
       AND s.SucChua <= (
            SELECT COUNT(*) FROM dbo.DangKy d
             WHERE d.SuKienID = s.SuKienID AND d.TrangThai = 'approved'
       );
END;
GO
 
PRINT 'Da cap nhat sp_DuyetDangKy va tao trigger tr_DangKy_AutoCloseEvent';
USE EventHub;
GO
 
-- ════════════════════════════════════════════════════════════════════
-- sp_DuyetDangKy: Sau khi approve, auto-close neu het cho hoac het han
-- ════════════════════════════════════════════════════════════════════
CREATE OR ALTER PROCEDURE dbo.sp_DuyetDangKy
    @p_DangKyID  INT,
    @p_AdminID   INT,
    @p_TrangThai NVARCHAR(20),   -- 'approved' hoac 'rejected'
    @p_KetQua    NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @SuKienID INT, @SucChua INT, @DaDuyet INT, @TrangThaiSK NVARCHAR(20),
            @HanDangKy DATE, @NgayBatDau DATE;
 
    UPDATE dbo.DangKy
       SET TrangThai    = @p_TrangThai,
           NguoiDuyetID = @p_AdminID,
           NgayDuyet    = GETDATE(),
           NgayCapNhat  = GETDATE()
     WHERE DangKyID = @p_DangKyID;
 
    IF @@ROWCOUNT = 0
    BEGIN
        SET @p_KetQua = 'NOT_FOUND';
        RETURN;
    END
 
    SELECT @SuKienID = SuKienID FROM dbo.DangKy WHERE DangKyID = @p_DangKyID;
 
    SELECT @SucChua    = SucChua,
           @TrangThaiSK= TrangThai,
           @HanDangKy  = HanDangKy,
           @NgayBatDau = NgayBatDau
      FROM dbo.SuKien
     WHERE SuKienID = @SuKienID;
 
    SELECT @DaDuyet = COUNT(*)
      FROM dbo.DangKy
     WHERE SuKienID = @SuKienID AND TrangThai = 'approved';
 
    -- Khong dong neu da ended/draft
    IF @TrangThaiSK NOT IN ('ended','draft')
    BEGIN
        -- Het cho hoac het han -> dong dang ky
        IF @DaDuyet >= @SucChua
            OR (@HanDangKy IS NOT NULL AND @HanDangKy < CAST(GETDATE() AS DATE))
        BEGIN
            IF @TrangThaiSK <> 'closed'
                UPDATE dbo.SuKien
                   SET TrangThai = 'closed', NgayCapNhat = GETDATE()
                 WHERE SuKienID = @SuKienID;
        END
        -- Con cho + con han -> mo lai (truong hop truoc do dong vi het cho, sau bi reject)
        ELSE IF @DaDuyet < @SucChua
            AND (@HanDangKy IS NULL OR @HanDangKy >= CAST(GETDATE() AS DATE))
        BEGIN
            DECLARE @NewStatus NVARCHAR(20) =
                CASE WHEN @NgayBatDau > CAST(GETDATE() AS DATE) THEN 'upcoming'
                     ELSE 'open' END;
            IF @TrangThaiSK <> @NewStatus
                UPDATE dbo.SuKien
                   SET TrangThai = @NewStatus, NgayCapNhat = GETDATE()
                 WHERE SuKienID = @SuKienID;
        END
    END
 
    SET @p_KetQua = 'OK';
END;
GO
 
-- ════════════════════════════════════════════════════════════════════
-- TRIGGER: Tu dong cap nhat trang thai SuKien khi DangKy thay doi
-- (insert, update trang thai, delete)
-- Logic 2 chieu: het cho -> dong, con cho/con han -> mo lai
-- ════════════════════════════════════════════════════════════════════
 
IF OBJECT_ID('dbo.tr_DangKy_AutoCloseEvent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DangKy_AutoCloseEvent;
GO
 
IF OBJECT_ID('dbo.tr_DangKy_AutoUpdateEvent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DangKy_AutoUpdateEvent;
GO
 
CREATE TRIGGER dbo.tr_DangKy_AutoUpdateEvent
ON dbo.DangKy
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
 
    -- Lay danh sach SuKienID bi anh huong (insert, update, delete)
    DECLARE @AffectedSK TABLE (SuKienID INT PRIMARY KEY);
    INSERT INTO @AffectedSK
    SELECT DISTINCT SuKienID FROM inserted
    UNION
    SELECT DISTINCT SuKienID FROM deleted;
 
    -- Cap nhat trang thai cho cac su kien bi anh huong (tru draft/ended)
    UPDATE s
       SET s.TrangThai = CASE
            -- Het cho -> closed
            WHEN ISNULL(d.SoDuyet,0) >= s.SucChua THEN 'closed'
            -- Het han -> closed
            WHEN s.HanDangKy IS NOT NULL AND s.HanDangKy < CAST(GETDATE() AS DATE) THEN 'closed'
            -- Chua toi ngay bat dau -> upcoming
            WHEN s.NgayBatDau > CAST(GETDATE() AS DATE) THEN 'upcoming'
            -- Con lai (con cho, con han, da toi ngay) -> open
            ELSE 'open'
       END,
           s.NgayCapNhat = GETDATE()
      FROM dbo.SuKien s
     INNER JOIN @AffectedSK a ON s.SuKienID = a.SuKienID
      LEFT JOIN (
          SELECT SuKienID, COUNT(*) AS SoDuyet
          FROM dbo.DangKy
          WHERE TrangThai = 'approved'
          GROUP BY SuKienID
      ) d ON s.SuKienID = d.SuKienID
     WHERE s.TrangThai NOT IN ('draft','ended')
       AND s.TrangThai <> CASE
            WHEN ISNULL(d.SoDuyet,0) >= s.SucChua THEN 'closed'
            WHEN s.HanDangKy IS NOT NULL AND s.HanDangKy < CAST(GETDATE() AS DATE) THEN 'closed'
            WHEN s.NgayBatDau > CAST(GETDATE() AS DATE) THEN 'upcoming'
            ELSE 'open'
       END;
END;
GO
 
PRINT 'Da cap nhat sp_DuyetDangKy va trigger tr_DangKy_AutoUpdateEvent';
GO
USE EventHub;
GO
USE EventHub;
GO
 
-- ════════════════════════════════════════════════════════════════════
-- BUOC 1: BO COT TrangThaiDangKy (neu da them tu script truoc)
-- ════════════════════════════════════════════════════════════════════
 
IF EXISTS (
    SELECT 1 FROM sys.columns
     WHERE Name = N'TrangThaiDangKy'
       AND Object_ID = Object_ID(N'dbo.SuKien')
)
BEGIN
    -- Bo CHECK constraint cua TrangThaiDangKy (neu co)
    IF EXISTS (SELECT 1 FROM sys.check_constraints
                WHERE name = 'CK_SuKien_TrangThaiDangKy')
        ALTER TABLE dbo.SuKien DROP CONSTRAINT CK_SuKien_TrangThaiDangKy;
 
    -- Bo DEFAULT constraint
    DECLARE @df NVARCHAR(200);
    SELECT @df = dc.name
      FROM sys.default_constraints dc
      JOIN sys.columns c ON c.default_object_id = dc.object_id
     WHERE c.object_id = OBJECT_ID('dbo.SuKien')
       AND c.name = 'TrangThaiDangKy';
    IF @df IS NOT NULL
        EXEC('ALTER TABLE dbo.SuKien DROP CONSTRAINT ' + @df);
 
    ALTER TABLE dbo.SuKien DROP COLUMN TrangThaiDangKy;
    PRINT '[1] Da bo cot TrangThaiDangKy';
END
ELSE
    PRINT '[1] Cot TrangThaiDangKy chua ton tai, bo qua';
GO
 
-- ════════════════════════════════════════════════════════════════════
-- BUOC 2: BO CHECK CONSTRAINT CU CUA TrangThai (de mo rong gia tri)
-- ════════════════════════════════════════════════════════════════════
 
DECLARE @ck NVARCHAR(200);
SELECT @ck = name FROM sys.check_constraints
 WHERE parent_object_id = OBJECT_ID('dbo.SuKien')
   AND definition LIKE '%TrangThai%';
IF @ck IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.SuKien DROP CONSTRAINT ' + @ck);
    PRINT '[2] Da bo CHECK constraint cu: ' + @ck;
END
ELSE
    PRINT '[2] Khong tim thay CHECK constraint cu';
GO
 
-- ════════════════════════════════════════════════════════════════════
-- BUOC 3: THEM CHECK CONSTRAINT MOI (5 gia tri)
-- ════════════════════════════════════════════════════════════════════
 
ALTER TABLE dbo.SuKien WITH NOCHECK
    ADD CONSTRAINT CK_SuKien_TrangThai
        CHECK (TrangThai IN ('draft','upcoming','open','closed','ended'));
 
PRINT '[3] Da them CHECK constraint moi (5 gia tri)';
GO
 
-- ════════════════════════════════════════════════════════════════════
-- BUOC 4: FUNCTION TINH TrangThai DUNG
-- Logic:
--   draft       -> giu nguyen (admin tu quan ly)
--   Da qua KT   -> ended
--   Het han DK  -> closed  (chua qua KT)
--   Het cho     -> closed
--   Trong khoang BD-KT + con han + con cho -> open
--   Truoc BD    + con han + con cho        -> upcoming
-- ════════════════════════════════════════════════════════════════════
 
IF OBJECT_ID('dbo.fn_TinhTrangThai', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_TinhTrangThai;
GO
 
CREATE FUNCTION dbo.fn_TinhTrangThai
(
    @TrangThaiHienTai NVARCHAR(20),
    @NgayBatDau       DATE,
    @NgayKetThuc      DATE,
    @HanDangKy        DATE,
    @SucChua          INT,
    @SoDuyet          INT
)
RETURNS NVARCHAR(20)
AS
BEGIN
    -- draft: admin tu quan ly
    IF @TrangThaiHienTai = 'draft' RETURN 'draft';
 
    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    DECLARE @NgayKt DATE = ISNULL(@NgayKetThuc, @NgayBatDau);
 
    -- 1. Da qua ngay ket thuc -> ended
    IF @NgayKt < @Today RETURN 'ended';
 
    -- 2. Het han DK -> closed
    IF @HanDangKy IS NOT NULL AND @HanDangKy < @Today RETURN 'closed';
 
    -- 3. Het cho -> closed
    IF @SoDuyet >= @SucChua RETURN 'closed';
 
    -- 4. Chua toi ngay BD + con han + con cho -> upcoming
    IF @NgayBatDau > @Today RETURN 'upcoming';
 
    -- 5. Trong khoang BD-KT + con han + con cho -> open
    RETURN 'open';
END;
GO
 
PRINT '[4] Da tao fn_TinhTrangThai';
GO
 
-- ════════════════════════════════════════════════════════════════════
-- BUOC 5: TRIGGER tren bang SuKien
-- Khi admin sua HanDangKy / SucChua / NgayBatDau / NgayKetThuc
-- -> tu dong tinh lai TrangThai
-- ════════════════════════════════════════════════════════════════════
 
IF OBJECT_ID('dbo.tr_SuKien_AutoUpdateStatus', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_SuKien_AutoUpdateStatus;
GO
 
CREATE TRIGGER dbo.tr_SuKien_AutoUpdateStatus
ON dbo.SuKien
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
 
    -- Chi chay khi co thay doi cot lien quan (tranh de quy)
    IF NOT (UPDATE(HanDangKy) OR UPDATE(SucChua) OR UPDATE(NgayBatDau) OR UPDATE(NgayKetThuc))
        RETURN;
 
    UPDATE s
       SET s.TrangThai = dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            ),
           s.NgayCapNhat = GETDATE()
      FROM dbo.SuKien s
     INNER JOIN inserted i ON s.SuKienID = i.SuKienID
      LEFT JOIN (
          SELECT SuKienID, COUNT(*) AS SoDuyet
          FROM dbo.DangKy
          WHERE TrangThai = 'approved'
          GROUP BY SuKienID
      ) d ON s.SuKienID = d.SuKienID
     WHERE s.TrangThai <> dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            );
END;
GO
 
PRINT '[5] Da tao tr_SuKien_AutoUpdateStatus';
GO
 
-- ════════════════════════════════════════════════════════════════════
-- BUOC 6: TRIGGER tren bang DangKy
-- Khi co dang ky moi / duyet / huy -> tinh lai TrangThai cua SuKien
-- ════════════════════════════════════════════════════════════════════
 
IF OBJECT_ID('dbo.tr_DangKy_AutoCloseEvent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DangKy_AutoCloseEvent;
GO
IF OBJECT_ID('dbo.tr_DangKy_AutoUpdateEvent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DangKy_AutoUpdateEvent;
GO
 
CREATE TRIGGER dbo.tr_DangKy_AutoUpdateEvent
ON dbo.DangKy
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @AffectedSK TABLE (SuKienID INT PRIMARY KEY);
    INSERT INTO @AffectedSK
    SELECT DISTINCT SuKienID FROM inserted
    UNION
    SELECT DISTINCT SuKienID FROM deleted;
 
    UPDATE s
       SET s.TrangThai = dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            ),
           s.NgayCapNhat = GETDATE()
      FROM dbo.SuKien s
     INNER JOIN @AffectedSK a ON s.SuKienID = a.SuKienID
      LEFT JOIN (
          SELECT SuKienID, COUNT(*) AS SoDuyet
          FROM dbo.DangKy
          WHERE TrangThai = 'approved'
          GROUP BY SuKienID
      ) d ON s.SuKienID = d.SuKienID
     WHERE s.TrangThai <> dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            );
END;
GO
 
PRINT '[6] Da tao tr_DangKy_AutoUpdateEvent';
GO
 
-- ════════════════════════════════════════════════════════════════════
-- BUOC 7: sp_DuyetDangKy
-- ════════════════════════════════════════════════════════════════════
 
CREATE OR ALTER PROCEDURE dbo.sp_DuyetDangKy
    @p_DangKyID  INT,
    @p_AdminID   INT,
    @p_TrangThai NVARCHAR(20),
    @p_KetQua    NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
 
    UPDATE dbo.DangKy
       SET TrangThai    = @p_TrangThai,
           NguoiDuyetID = @p_AdminID,
           NgayDuyet    = GETDATE(),
           NgayCapNhat  = GETDATE()
     WHERE DangKyID = @p_DangKyID;
 
    IF @@ROWCOUNT = 0
    BEGIN
        SET @p_KetQua = 'NOT_FOUND';
        RETURN;
    END
 
    -- Trigger tr_DangKy_AutoUpdateEvent tu lo cap nhat TrangThai SuKien
    SET @p_KetQua = 'OK';
END;
GO
 
PRINT '[7] Da tao sp_DuyetDangKy';
PRINT '';
PRINT '====================================';
PRINT 'HOAN TAT!';
PRINT '  - 1 function: fn_TinhTrangThai';
PRINT '  - 2 trigger: tr_SuKien_AutoUpdateStatus, tr_DangKy_AutoUpdateEvent';
PRINT '  - sp_DuyetDangKy';
PRINT '====================================';
GO
 
-- ════════════════════════════════════════════════════════════════════
-- LOGIC TU DONG - KHONG GHI DE LUA CHON CUA ADMIN
-- Gia tri TrangThai: draft / upcoming / open / closed / ended
-- Quy tac:
--   - Trigger CHI DONG khi bat buoc (het han / het cho / qua KT)
--   - Trigger KHONG TU MO khi co dieu kien (admin tu mo)
-- ════════════════════════════════════════════════════════════════════
USE EventHub;
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 1: BO COT TrangThaiDangKy (neu da them tu script truoc)
-- ════════════════════════════════════════════════════════════════════

IF EXISTS (
    SELECT 1 FROM sys.columns
     WHERE Name = N'TrangThaiDangKy'
       AND Object_ID = Object_ID(N'dbo.SuKien')
)
BEGIN
    IF EXISTS (SELECT 1 FROM sys.check_constraints
                WHERE name = 'CK_SuKien_TrangThaiDangKy')
        ALTER TABLE dbo.SuKien DROP CONSTRAINT CK_SuKien_TrangThaiDangKy;

    DECLARE @df NVARCHAR(200);
    SELECT @df = dc.name
      FROM sys.default_constraints dc
      JOIN sys.columns c ON c.default_object_id = dc.object_id
     WHERE c.object_id = OBJECT_ID('dbo.SuKien')
       AND c.name = 'TrangThaiDangKy';
    IF @df IS NOT NULL
        EXEC('ALTER TABLE dbo.SuKien DROP CONSTRAINT ' + @df);

    ALTER TABLE dbo.SuKien DROP COLUMN TrangThaiDangKy;
    PRINT '[1] Da bo cot TrangThaiDangKy';
END
ELSE
    PRINT '[1] Cot TrangThaiDangKy chua ton tai, bo qua';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 2: BO CHECK CONSTRAINT CU CUA TrangThai
-- ════════════════════════════════════════════════════════════════════

DECLARE @ck NVARCHAR(200);
SELECT @ck = name FROM sys.check_constraints
 WHERE parent_object_id = OBJECT_ID('dbo.SuKien')
   AND definition LIKE '%TrangThai%';
IF @ck IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.SuKien DROP CONSTRAINT ' + @ck);
    PRINT '[2] Da bo CHECK constraint cu: ' + @ck;
END
ELSE
    PRINT '[2] Khong tim thay CHECK constraint cu';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 3: THEM CHECK CONSTRAINT MOI (5 gia tri)
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE dbo.SuKien WITH NOCHECK
    ADD CONSTRAINT CK_SuKien_TrangThai
        CHECK (TrangThai IN ('draft','upcoming','open','closed','ended'));

PRINT '[3] Da them CHECK constraint moi';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 4: FUNCTION TINH TrangThai
-- Logic moi (TON TRONG lua chon cua admin):
--   draft       -> giu nguyen
--   Da qua KT   -> ENDED (bat buoc)
--   Het han DK  -> CLOSED (bat buoc)
--   Het cho     -> CLOSED (bat buoc)
--   Con han + con cho:
--      Neu hien tai la 'closed'/'ended' do dieu kien cu khong con,
--      GIU NGUYEN 'closed' (admin tu mo) THAY VI tu chuyen sang open/upcoming.
--      Neu hien tai la 'open' hoac 'upcoming' -> giu lai 'open'/'upcoming'
--      tuong ung voi ngay BD (admin da chu dong mo truoc do)
-- ════════════════════════════════════════════════════════════════════

IF OBJECT_ID('dbo.fn_TinhTrangThai', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_TinhTrangThai;
GO

CREATE FUNCTION dbo.fn_TinhTrangThai
(
    @TrangThaiHienTai NVARCHAR(20),
    @NgayBatDau       DATE,
    @NgayKetThuc      DATE,
    @HanDangKy        DATE,
    @SucChua          INT,
    @SoDuyet          INT
)
RETURNS NVARCHAR(20)
AS
BEGIN
    -- draft: admin tu quan ly
    IF @TrangThaiHienTai = 'draft' RETURN 'draft';

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    DECLARE @NgayKt DATE = ISNULL(@NgayKetThuc, @NgayBatDau);

    -- ===== CAC TRUONG HOP BAT BUOC =====
    -- 1. Da qua ngay ket thuc -> ended (bat buoc)
    IF @NgayKt < @Today RETURN 'ended';

    -- 2. Het han DK -> closed (bat buoc)
    IF @HanDangKy IS NOT NULL AND @HanDangKy < @Today RETURN 'closed';

    -- 3. Het cho -> closed (bat buoc)
    IF @SoDuyet >= @SucChua RETURN 'closed';

    -- ===== CON HAN + CON CHO: TON TRONG LUA CHON ADMIN =====
    -- Neu admin dang dat 'closed' (chu dong dong) -> giu 'closed'
    IF @TrangThaiHienTai = 'closed' RETURN 'closed';

    -- Neu admin dang dat 'open' nhung sau khi sua ngay -> dieu chinh open/upcoming theo ngay
    IF @NgayBatDau > @Today RETURN 'upcoming';
    RETURN 'open';
END;
GO

PRINT '[4] Da tao fn_TinhTrangThai';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 5: TRIGGER tren bang SuKien
-- ════════════════════════════════════════════════════════════════════

IF OBJECT_ID('dbo.tr_SuKien_AutoUpdateStatus', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_SuKien_AutoUpdateStatus;
GO

CREATE TRIGGER dbo.tr_SuKien_AutoUpdateStatus
ON dbo.SuKien
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Chi chay khi sua HanDangKy / SucChua / NgayBatDau / NgayKetThuc
    -- (KHONG tu chay khi admin sua TrangThai - de tranh ghi de)
    IF NOT (UPDATE(HanDangKy) OR UPDATE(SucChua) OR UPDATE(NgayBatDau) OR UPDATE(NgayKetThuc))
        RETURN;

    UPDATE s
       SET s.TrangThai = dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            ),
           s.NgayCapNhat = GETDATE()
      FROM dbo.SuKien s
     INNER JOIN inserted i ON s.SuKienID = i.SuKienID
      LEFT JOIN (
          SELECT SuKienID, COUNT(*) AS SoDuyet
          FROM dbo.DangKy
          WHERE TrangThai = 'approved'
          GROUP BY SuKienID
      ) d ON s.SuKienID = d.SuKienID
     WHERE s.TrangThai <> dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            );
END;
GO

PRINT '[5] Da tao tr_SuKien_AutoUpdateStatus';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 6: TRIGGER tren bang DangKy
-- ════════════════════════════════════════════════════════════════════

IF OBJECT_ID('dbo.tr_DangKy_AutoCloseEvent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DangKy_AutoCloseEvent;
GO
IF OBJECT_ID('dbo.tr_DangKy_AutoUpdateEvent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DangKy_AutoUpdateEvent;
GO

CREATE TRIGGER dbo.tr_DangKy_AutoUpdateEvent
ON dbo.DangKy
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AffectedSK TABLE (SuKienID INT PRIMARY KEY);
    INSERT INTO @AffectedSK
    SELECT DISTINCT SuKienID FROM inserted
    UNION
    SELECT DISTINCT SuKienID FROM deleted;

    UPDATE s
       SET s.TrangThai = dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            ),
           s.NgayCapNhat = GETDATE()
      FROM dbo.SuKien s
     INNER JOIN @AffectedSK a ON s.SuKienID = a.SuKienID
      LEFT JOIN (
          SELECT SuKienID, COUNT(*) AS SoDuyet
          FROM dbo.DangKy
          WHERE TrangThai = 'approved'
          GROUP BY SuKienID
      ) d ON s.SuKienID = d.SuKienID
     WHERE s.TrangThai <> dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            );
END;
GO

PRINT '[6] Da tao tr_DangKy_AutoUpdateEvent';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 7: sp_DuyetDangKy
-- ════════════════════════════════════════════════════════════════════

CREATE OR ALTER PROCEDURE dbo.sp_DuyetDangKy
    @p_DangKyID  INT,
    @p_AdminID   INT,
    @p_TrangThai NVARCHAR(20),
    @p_KetQua    NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.DangKy
       SET TrangThai    = @p_TrangThai,
           NguoiDuyetID = @p_AdminID,
           NgayDuyet    = GETDATE(),
           NgayCapNhat  = GETDATE()
     WHERE DangKyID = @p_DangKyID;

    IF @@ROWCOUNT = 0
    BEGIN
        SET @p_KetQua = 'NOT_FOUND';
        RETURN;
    END

    SET @p_KetQua = 'OK';
END;
GO

PRINT '[7] Da tao sp_DuyetDangKy';
PRINT '';
PRINT '====================================';
PRINT 'HOAN TAT!';
PRINT 'Quy tac:';
PRINT '  - Het han / Het cho / Qua KT  -> TU DONG dong (bat buoc)';
PRINT '  - Con han + con cho           -> ADMIN tu quyet open/closed';
PRINT '====================================';
GO
-- ════════════════════════════════════════════════════════════════════
-- LOGIC 5 TRANG THAI:
--   draft    : nhap (admin tu quan ly)
--   open     : now <= HanDangKy (con han DK, chua qua ngay BD)
--   closed   : HanDangKy < now < NgayBatDau (het han DK, chua dien ra)
--   ongoing  : NgayBatDau <= now <= NgayKetThuc (dang dien ra)
--   ended    : now > NgayKetThuc (da ket thuc)
-- Bo sung: het cho thi cung -> closed (du con han)
-- Chay trong SSMS tren DB EventHub
-- ════════════════════════════════════════════════════════════════════
USE EventHub;
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 1: BO COT TrangThaiDangKy (neu da them tu script truoc)
-- ════════════════════════════════════════════════════════════════════

IF EXISTS (SELECT 1 FROM sys.columns
            WHERE Name = N'TrangThaiDangKy'
              AND Object_ID = Object_ID(N'dbo.SuKien'))
BEGIN
    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_SuKien_TrangThaiDangKy')
        ALTER TABLE dbo.SuKien DROP CONSTRAINT CK_SuKien_TrangThaiDangKy;

    DECLARE @df NVARCHAR(200);
    SELECT @df = dc.name FROM sys.default_constraints dc
      JOIN sys.columns c ON c.default_object_id = dc.object_id
     WHERE c.object_id = OBJECT_ID('dbo.SuKien') AND c.name = 'TrangThaiDangKy';
    IF @df IS NOT NULL EXEC('ALTER TABLE dbo.SuKien DROP CONSTRAINT ' + @df);

    ALTER TABLE dbo.SuKien DROP COLUMN TrangThaiDangKy;
    PRINT '[1] Da bo cot TrangThaiDangKy';
END
ELSE
    PRINT '[1] Khong co cot TrangThaiDangKy, bo qua';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 2: BO COT NgayMoDangKy (neu da them tu script truoc)
-- ════════════════════════════════════════════════════════════════════

IF EXISTS (SELECT 1 FROM sys.columns
            WHERE Name = N'NgayMoDangKy'
              AND Object_ID = Object_ID(N'dbo.SuKien'))
BEGIN
    ALTER TABLE dbo.SuKien DROP COLUMN NgayMoDangKy;
    PRINT '[2] Da bo cot NgayMoDangKy';
END
ELSE
    PRINT '[2] Khong co cot NgayMoDangKy, bo qua';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 3: BO CHECK CONSTRAINT CU CUA TrangThai
-- ════════════════════════════════════════════════════════════════════

DECLARE @ck NVARCHAR(200);
SELECT @ck = name FROM sys.check_constraints
 WHERE parent_object_id = OBJECT_ID('dbo.SuKien')
   AND definition LIKE '%TrangThai%';
IF @ck IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.SuKien DROP CONSTRAINT ' + @ck);
    PRINT '[3] Da bo CHECK constraint cu: ' + @ck;
END
ELSE
    PRINT '[3] Khong co CHECK constraint cu';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 4: MIGRATE TrangThai 'upcoming' (cu) -> 'open' (moi)
-- ════════════════════════════════════════════════════════════════════

UPDATE dbo.SuKien SET TrangThai = 'open' WHERE TrangThai = 'upcoming';
PRINT '[4] Da migrate upcoming -> open';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 5: THEM CHECK CONSTRAINT MOI (5 gia tri)
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE dbo.SuKien WITH NOCHECK
    ADD CONSTRAINT CK_SuKien_TrangThai
        CHECK (TrangThai IN ('draft','open','closed','ongoing','ended'));

PRINT '[5] Da them CHECK constraint moi';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 6: FUNCTION TINH TrangThai
-- Logic:
--   draft         -> giu nguyen (admin tu quan ly)
--   now > KT      -> ended  (bat buoc)
--   BD <= now<=KT -> ongoing (bat buoc)
--   Het cho       -> closed (bat buoc, du con han)
--   now > HanDK   -> closed (bat buoc)
--   now <= HanDK:
--     Neu admin chu dong dat closed -> giu closed (ton trong)
--     Nguoc lai -> open
-- ════════════════════════════════════════════════════════════════════

IF OBJECT_ID('dbo.fn_TinhTrangThai', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_TinhTrangThai;
GO

CREATE FUNCTION dbo.fn_TinhTrangThai
(
    @TrangThaiHienTai NVARCHAR(20),
    @NgayBatDau       DATE,
    @NgayKetThuc      DATE,
    @HanDangKy        DATE,
    @SucChua          INT,
    @SoDuyet          INT
)
RETURNS NVARCHAR(20)
AS
BEGIN
    -- draft: admin tu quan ly
    IF @TrangThaiHienTai = 'draft' RETURN 'draft';

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    DECLARE @NgayKt DATE = ISNULL(@NgayKetThuc, @NgayBatDau);

    -- 1. Da qua ngay ket thuc -> ended (bat buoc)
    IF @NgayKt < @Today RETURN 'ended';

    -- 2. Trong khoang BD-KT -> ongoing (bat buoc)
    IF @NgayBatDau <= @Today AND @NgayKt >= @Today RETURN 'ongoing';

    -- ===== Cac TH duoi day deu chua toi NgayBatDau =====

    -- 3. Het cho -> closed (bat buoc, du con han DK)
    IF @SoDuyet >= @SucChua RETURN 'closed';

    -- 4. Het han DK -> closed (bat buoc)
    IF @HanDangKy IS NOT NULL AND @HanDangKy < @Today RETURN 'closed';

    -- 5. Con han + con cho:
    --    Neu admin chu dong dat 'closed' -> giu 'closed' (ton trong)
    IF @TrangThaiHienTai = 'closed' RETURN 'closed';

    -- 6. Mac dinh -> open
    RETURN 'open';
END;
GO

PRINT '[6] Da tao fn_TinhTrangThai';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 7: TRIGGER tren bang SuKien
-- ════════════════════════════════════════════════════════════════════

IF OBJECT_ID('dbo.tr_SuKien_AutoUpdateStatus', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_SuKien_AutoUpdateStatus;
GO

CREATE TRIGGER dbo.tr_SuKien_AutoUpdateStatus
ON dbo.SuKien
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT (UPDATE(HanDangKy) OR UPDATE(SucChua) OR UPDATE(NgayBatDau) OR UPDATE(NgayKetThuc))
        RETURN;

    UPDATE s
       SET s.TrangThai = dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            ),
           s.NgayCapNhat = GETDATE()
      FROM dbo.SuKien s
     INNER JOIN inserted i ON s.SuKienID = i.SuKienID
      LEFT JOIN (
          SELECT SuKienID, COUNT(*) AS SoDuyet
          FROM dbo.DangKy WHERE TrangThai = 'approved'
          GROUP BY SuKienID
      ) d ON s.SuKienID = d.SuKienID
     WHERE s.TrangThai <> dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            );
END;
GO

PRINT '[7] Da tao tr_SuKien_AutoUpdateStatus';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 8: TRIGGER tren bang DangKy
-- ════════════════════════════════════════════════════════════════════

IF OBJECT_ID('dbo.tr_DangKy_AutoCloseEvent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DangKy_AutoCloseEvent;
GO
IF OBJECT_ID('dbo.tr_DangKy_AutoUpdateEvent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DangKy_AutoUpdateEvent;
GO

CREATE TRIGGER dbo.tr_DangKy_AutoUpdateEvent
ON dbo.DangKy
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AffectedSK TABLE (SuKienID INT PRIMARY KEY);
    INSERT INTO @AffectedSK
    SELECT DISTINCT SuKienID FROM inserted
    UNION
    SELECT DISTINCT SuKienID FROM deleted;

    UPDATE s
       SET s.TrangThai = dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            ),
           s.NgayCapNhat = GETDATE()
      FROM dbo.SuKien s
     INNER JOIN @AffectedSK a ON s.SuKienID = a.SuKienID
      LEFT JOIN (
          SELECT SuKienID, COUNT(*) AS SoDuyet
          FROM dbo.DangKy WHERE TrangThai = 'approved'
          GROUP BY SuKienID
      ) d ON s.SuKienID = d.SuKienID
     WHERE s.TrangThai <> dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0)
            );
END;
GO

PRINT '[8] Da tao tr_DangKy_AutoUpdateEvent';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 9: sp_DuyetDangKy
-- ════════════════════════════════════════════════════════════════════

CREATE OR ALTER PROCEDURE dbo.sp_DuyetDangKy
    @p_DangKyID  INT,
    @p_AdminID   INT,
    @p_TrangThai NVARCHAR(20),
    @p_KetQua    NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.DangKy
       SET TrangThai = @p_TrangThai, NguoiDuyetID = @p_AdminID,
           NgayDuyet = GETDATE(), NgayCapNhat = GETDATE()
     WHERE DangKyID = @p_DangKyID;

    IF @@ROWCOUNT = 0 BEGIN SET @p_KetQua = 'NOT_FOUND'; RETURN; END
    SET @p_KetQua = 'OK';
END;
GO

PRINT '[9] Da tao sp_DuyetDangKy';
PRINT '';
PRINT '====================================';
PRINT 'HOAN TAT! Trang thai: draft / open / closed / ongoing / ended';
PRINT '====================================';
GO
select*from dbo.Users
select*from dbo.DanhSachCho
select*from dbo.DangKy
select*from dbo.SuKien
-- Query 1: Kiểm tra cột bảng SuKien
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SuKien'
ORDER BY ORDINAL_POSITION;

-- Query 2: Kiểm tra tham số function
SELECT p.name AS ParamName, t.name AS DataType, p.parameter_id
FROM sys.parameters p
INNER JOIN sys.types t ON p.user_type_id = t.user_type_id
WHERE p.object_id = OBJECT_ID('dbo.fn_TinhTrangThai')
ORDER BY p.parameter_id;
USE EventHub;
GO

-- ============================================================
-- BƯỚC 1: Cập nhật CHECK constraint (thêm 'ongoing', 'upcoming')
-- ============================================================

-- Xóa constraint cũ
DECLARE @ck NVARCHAR(200);
SELECT @ck = name FROM sys.check_constraints
 WHERE parent_object_id = OBJECT_ID('dbo.SuKien')
   AND definition LIKE '%TrangThai%';
IF @ck IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.SuKien DROP CONSTRAINT ' + @ck);
END

-- Thêm constraint mới (bao gồm cả 'ongoing', 'upcoming')
ALTER TABLE dbo.SuKien WITH NOCHECK
    ADD CONSTRAINT CK_SuKien_TrangThai
        CHECK (TrangThai IN ('draft','upcoming','open','closed','ongoing','ended'));

PRINT '[OK] Da cap nhat CHECK constraint';
GO

-- ============================================================
-- BƯỚC 2: Tạo function fn_TinhTrangThai với 8 tham số
-- ============================================================

IF OBJECT_ID('dbo.fn_TinhTrangThai', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_TinhTrangThai;
GO

CREATE FUNCTION dbo.fn_TinhTrangThai
(
    @TrangThaiHienTai NVARCHAR(20),
    @NgayBatDau       DATE,
    @NgayKetThuc      DATE,
    @HanDangKy        DATE,
    @SucChua          INT,
    @SoDuyet          INT,
    @GioBatDau        TIME(0) = '08:00:00',
    @GioKetThuc       TIME(0) = '17:00:00'
)
RETURNS NVARCHAR(20)
AS
BEGIN
    -- draft: admin tự quản lý
    IF @TrangThaiHienTai = 'draft' RETURN 'draft';

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    DECLARE @Now DATETIME = GETDATE();
    DECLARE @NgayKt DATE = ISNULL(@NgayKetThuc, @NgayBatDau);

    -- Tính thời điểm bắt đầu kết thúc chính xác (ngày + giờ)
    DECLARE @Start DATETIME = DATEADD(MINUTE, 
        DATEPART(HOUR, @GioBatDau) * 60 + DATEPART(MINUTE, @GioBatDau),
        CAST(@NgayBatDau AS DATETIME));
    DECLARE @End DATETIME = DATEADD(MINUTE,
        DATEPART(HOUR, @GioKetThuc) * 60 + DATEPART(MINUTE, @GioKetThuc),
        CAST(@NgayKt AS DATETIME));

    -- 1. Đã qua ngày kết thúc -> ended (bắt buộc)
    IF @End < @Now RETURN 'ended';

    -- 2. Trong khoảng BD-KT -> ongoing (bắt buộc)
    IF @Start <= @Now AND @End >= @Now RETURN 'ongoing';

    -- ==== Các TH chưa tới NgayBatDau ====

    -- 3. Hết chỗ -> closed (bắt buộc, dù còn hạn)
    IF @SoDuyet >= @SucChua RETURN 'closed';

    -- 4. Hết hạn DK -> closed (bắt buộc)
    IF @HanDangKy IS NOT NULL AND @HanDangKy < @Today RETURN 'closed';

    -- 5. Còn hạn + còn chỗ:
    --    Nếu admin chủ động đặt 'closed' -> giữ 'closed' (tôn trọng)
    IF @TrangThaiHienTai = 'closed' RETURN 'closed';

    -- 6. Chưa tới ngày BD -> upcoming, ngược lại -> open
    IF @NgayBatDau > @Today RETURN 'upcoming';
    RETURN 'open';
END;
GO

-- ============================================================
-- BƯỚC 3: TEST
-- ============================================================

-- Test các trường hợp
SELECT 
    'Test 1: Qua KT' AS TestCase,
    dbo.fn_TinhTrangThai('open', '2025-04-01', '2025-04-02', '2025-04-10', 50, 10, '08:00', '17:00') AS Result
UNION ALL
SELECT 
    'Test 2: Dang ongoing',
    dbo.fn_TinhTrangThai('open', CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 50, 10, '08:00', '18:00')
UNION ALL
SELECT 
    'Test 3: Het cho',
    dbo.fn_TinhTrangThai('open', '2025-05-01', '2025-05-02', '2025-04-20', 50, 50, '08:00', '17:00')
UNION ALL
SELECT 
    'Test 4: Het han',
    dbo.fn_TinhTrangThai('upcoming', '2025-05-01', '2025-05-02', CAST(GETDATE() - 1 AS DATE), 50, 10, '08:00', '17:00')
UNION ALL
SELECT 
    'Test 5: Closed by admin',
    dbo.fn_TinhTrangThai('closed', '2025-05-01', '2025-05-02', '2025-06-01', 50, 10, '08:00', '17:00')
UNION ALL
SELECT 
    'Test 6: Upcoming',
    dbo.fn_TinhTrangThai('open', DATEADD(DAY, 5, CAST(GETDATE() AS DATE)), DATEADD(DAY, 7, CAST(GETDATE() AS DATE)), DATEADD(DAY, 3, CAST(GETDATE() AS DATE)), 50, 10, '08:00', '17:00')
UNION ALL
SELECT 
    'Test 7: Open',
    dbo.fn_TinhTrangThai('closed', CAST(GETDATE() AS DATE), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), DATEADD(DAY, 3, CAST(GETDATE() AS DATE)), 50, 10, '08:00', '17:00');

PRINT '';
PRINT '====================================';
PRINT 'HOAN TAT! Da fix fn_TinhTrangThai';
PRINT '====================================';
GO
USE EventHub;
GO

-- ============================================================
-- BƯỚC 1: DROP hoàn toàn function cũ
-- ============================================================

IF OBJECT_ID('dbo.fn_TinhTrangThai', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_TinhTrangThai;

PRINT '[1] Da xoa function cu';
GO

-- ============================================================
-- BƯỚC 2: Tạo function mới với ĐỦ 8 THAM SỐ (không default)
-- ============================================================

CREATE FUNCTION dbo.fn_TinhTrangThai
(
    @TrangThaiHienTai NVARCHAR(20),
    @NgayBatDau       DATE,
    @NgayKetThuc      DATE,
    @HanDangKy        DATE,
    @SucChua          INT,
    @SoDuyet          INT,
    @GioBatDau        TIME(0),
    @GioKetThuc       TIME(0)
)
RETURNS NVARCHAR(20)
AS
BEGIN
    -- draft: admin tự quản lý
    IF @TrangThaiHienTai = 'draft' RETURN 'draft';

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    DECLARE @Now DATETIME = GETDATE();
    DECLARE @NgayKt DATE = ISNULL(@NgayKetThuc, @NgayBatDau);

    -- Tính thời điểm bắt đầu & kết thúc chính xác
    DECLARE @Start DATETIME = DATEADD(MINUTE, 
        DATEPART(HOUR, @GioBatDau) * 60 + DATEPART(MINUTE, @GioBatDau),
        CAST(@NgayBatDau AS DATETIME));
    DECLARE @End DATETIME = DATEADD(MINUTE,
        DATEPART(HOUR, @GioKetThuc) * 60 + DATEPART(MINUTE, @GioKetThuc),
        CAST(@NgayKt AS DATETIME));

    -- 1. Đã qua ngày kết thúc -> ended
    IF @End < @Now RETURN 'ended';

    -- 2. Trong khoảng BD-KT -> ongoing
    IF @Start <= @Now AND @End >= @Now RETURN 'ongoing';

    -- 3. Hết chỗ -> closed
    IF @SoDuyet >= @SucChua RETURN 'closed';

    -- 4. Hết hạn DK -> closed
    IF @HanDangKy IS NOT NULL AND @HanDangKy < @Today RETURN 'closed';

    -- 5. Admin đặt closed -> giữ closed
    IF @TrangThaiHienTai = 'closed' RETURN 'closed';

    -- 6. Chưa tới ngày BD -> upcoming, ngược lại -> open
    IF @NgayBatDau > @Today RETURN 'upcoming';
    RETURN 'open';
END;
GO

PRINT '[2] Da tao function moi';
GO

-- ============================================================
-- BƯỚC 3: Xóa cached plans để SQL Server dùng function mới
-- ============================================================

DBCC FREEPROCCACHE;
PRINT '[3] Da clear cache';
GO

-- ============================================================
-- BƯỚC 4: TEST thủ công
-- ============================================================

SELECT 
    dbo.fn_TinhTrangThai(
        'open',                          -- TrangThaiHienTai
        '2025-12-31',                    -- NgayBatDau
        '2025-12-31',                    -- NgayKetThuc
        '2025-12-30',                    -- HanDangKy
        50,                             -- SucChua
        10,                             -- SoDuyet
        '08:00:00',                     -- GioBatDau
        '17:00:00'                      -- GioKetThuc
    ) AS TestResult;

PRINT '';
PRINT '====================================';
PRINT 'TEST: Neu hien thi ket qua -> OK !';
PRINT '====================================';
GO
USE EventHub;
GO

-- ============================================================
-- Kiểm tra xem function có tồn tại không và kiểu gì
-- ============================================================

SELECT 
    o.type_desc,
    o.name AS ObjectName
FROM sys.objects o
WHERE o.name = 'fn_TinhTrangThai'
  AND o.type IN ('FN', 'IF', 'TF', 'AF');  -- các loại function

PRINT '';
PRINT '====================================';
USE EventHub;
GO

DECLARE @TrangThai NVARCHAR(20) = 'open';
DECLARE @NgayBatDau DATE = '2025-12-31';
DECLARE @NgayKetThuc DATE = '2025-12-31';
DECLARE @HanDangKy DATE = '2025-12-30';
DECLARE @SucChua INT = 50;
DECLARE @SoDuyet INT = 10;
DECLARE @GioBatDau TIME = '08:00:00';
DECLARE @GioKetThuc TIME = '17:00:00';

SELECT dbo.fn_TinhTrangThai(
    @TrangThai, @NgayBatDau, @NgayKetThuc, @HanDangKy, 
    @SucChua, @SoDuyet, @GioBatDau, @GioKetThuc
) AS KetQua;
USE EventHub;
GO

-- Kiểm tra cột GioBatDau, GioKetThuc có trong bảng SuKien
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SuKien'
  AND COLUMN_NAME IN ('GioBatDau', 'GioKetThuc');
  USE EventHub;
GO

-- Xem function có tồn tại và có bao nhiêu tham số
SELECT 
    o.type_desc,
    p.name AS ParamName,
    TYPE_NAME(p.system_type_id) AS DataType
FROM sys.parameters p
JOIN sys.objects o ON p.object_id = o.object_id
WHERE o.name = 'fn_TinhTrangThai'
ORDER BY p.parameter_id;
USE EventHub;
GO
BEGIN TRY
    SELECT dbo.fn_TinhTrangThai('open','2025-12-31','2025-12-31','2025-12-30',50,10,'08:00:00','17:00:00')
END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS ErrorNum,
        ERROR_MESSAGE() AS ErrorMsg,
        ERROR_PROCEDURE() AS ErrorProc;
END CATCH
USE EventHub;
GO

-- ============================================================
-- BƯỚC 1: XÓA TẤT CẢ các phiên bản function
-- ============================================================

DECLARE @obj_id INT;
WHILE OBJECT_ID('dbo.fn_TinhTrangThai', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION dbo.fn_TinhTrangThai;
END

PRINT '[1] Da xoa toan bo function cu';
GO

-- ============================================================
-- BƯỚC 2: TẠO MỚI với ĐÚNG 8 THAM SỐ
-- ============================================================

CREATE FUNCTION dbo.fn_TinhTrangThai
(
    @TrangThai NVARCHAR(20),
    @NgayBatDau DATE,
    @NgayKetThuc DATE,
    @HanDangKy DATE,
    @SucChua INT,
    @SoDuyet INT,
    @GioBatDau TIME(0),
    @GioKetThuc TIME(0)
)
RETURNS NVARCHAR(20)
AS
BEGIN
    IF @TrangThai = 'draft' RETURN 'draft';

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    DECLARE @Now DATETIME = GETDATE();
    DECLARE @NgayKt DATE = ISNULL(@NgayKetThuc, @NgayBatDau);

    DECLARE @Start DATETIME = DATEADD(MINUTE, 
        DATEPART(HOUR, @GioBatDau) * 60 + DATEPART(MINUTE, @GioBatDau),
        CAST(@NgayBatDau AS DATETIME));
    DECLARE @End DATETIME = DATEADD(MINUTE,
        DATEPART(HOUR, @GioKetThuc) * 60 + DATEPART(MINUTE, @GioKetThuc),
        CAST(@NgayKt AS DATETIME));

    IF @End < @Now RETURN 'ended';
    IF @Start <= @Now AND @End >= @Now RETURN 'ongoing';
    
    IF @SoDuyet >= @SucChua RETURN 'closed';
    IF @HanDangKy IS NOT NULL AND @HanDangKy < @Today RETURN 'closed';
    IF @TrangThai = 'closed' RETURN 'closed';
    
    IF @NgayBatDau > @Today RETURN 'upcoming';
    RETURN 'open';
END;
GO

-- ============================================================
-- BƯỚC 3: CLEAR CACHE
-- ============================================================

DBCC FREEPROCCACHE;
PRINT '[3] Da clear cache';
GO

-- ============================================================
-- BƯỚC 4: TEST với 8 tham số
-- ============================================================

SELECT 
    dbo.fn_TinhTrangThai(
        'open',
        '2025-12-31',
        '2025-12-31',
        '2025-12-30',
        50,
        10,
        '08:00:00',
        '17:00:00'
    ) AS KetQua;

-- ============================================================
-- BƯỚC 5: XÁC NHẬN có 8 tham số
-- ============================================================

SELECT name, type_desc
FROM sys.objects 
WHERE name = 'fn_TinhTrangThai';

SELECT p.name AS ParamName
FROM sys.parameters p
WHERE p.object_id = OBJECT_ID('dbo.fn_TinhTrangThai')
ORDER BY p.parameter_id;

PRINT '';
PRINT '====================================';
PRINT 'Neu hien thi "open" va 8 dong tham so -> OK!';
PRINT '====================================';
GO
SELECT 
    PARAMETER_NAME, 
    DATA_TYPE, 
    ORDINAL_POSITION
FROM INFORMATION_SCHEMA.PARAMETERS
WHERE SPECIFIC_NAME = 'fn_TinhTrangThai'
ORDER BY ORDINAL_POSITION;
ALTER FUNCTION dbo.fn_TinhTrangThai
(
    @TrangThai NVARCHAR(20),
    @NgayBatDau DATE,
    @NgayKetThuc DATE,
    @HanDangKy DATE,
    @SucChua INT,
    @SoDuyet INT,
    @GioBatDau TIME = '00:00:00',  -- Đặt mặc định nếu gọi thiếu
    @GioKetThuc TIME = '23:59:59'  -- Đặt mặc định nếu gọi thiếu
)
RETURNS NVARCHAR(20)
AS
BEGIN
    -- Giữ nguyên đoạn code logic xử lý bên trong hàm của bạn ở đây
    
    -- Ví dụ minh họa logic trả về:
    RETURN @TrangThai; 
END
select*from dbo.Users
-- ════════════════════════════════════════════════════════════════════
-- FIX TONG THE: fn_TinhTrangThai + 2 TRIGGERS
-- ════════════════════════════════════════════════════════════════════
-- VAN DE: Triggers tr_SuKien_AutoUpdateStatus va tr_DangKy_AutoUpdateEvent
--          dang goi fn_TinhTrangThai voi 6 tham so cu, nhung function
--          bay gio co 8 tham so -> SqlException "insufficient arguments"
-- GIAI PHAP: Drop & tao lai function + 2 triggers voi 8 tham so
-- ════════════════════════════════════════════════════════════════════

USE EventHub;
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 1: DROP triggers truoc (vi triggers tham chieu function)
-- ════════════════════════════════════════════════════════════════════

IF OBJECT_ID('dbo.tr_SuKien_AutoUpdateStatus', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_SuKien_AutoUpdateStatus;
GO

IF OBJECT_ID('dbo.tr_DangKy_AutoUpdateEvent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DangKy_AutoUpdateEvent;
GO

IF OBJECT_ID('dbo.tr_DangKy_AutoCloseEvent', 'TR') IS NOT NULL
    DROP TRIGGER dbo.tr_DangKy_AutoCloseEvent;
GO

PRINT '[1] Da drop 3 triggers cu';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 2: DROP & CREATE LAI FUNCTION voi 8 tham so
-- ════════════════════════════════════════════════════════════════════

IF OBJECT_ID('dbo.fn_TinhTrangThai', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_TinhTrangThai;
GO

CREATE FUNCTION dbo.fn_TinhTrangThai
(
    @TrangThaiHienTai NVARCHAR(20),
    @NgayBatDau       DATE,
    @NgayKetThuc      DATE,
    @HanDangKy        DATE,
    @SucChua          INT,
    @SoDuyet          INT,
    @GioBatDau        TIME = NULL,
    @GioKetThuc       TIME = NULL
)
RETURNS NVARCHAR(20)
AS
BEGIN
    -- draft: admin tu quan ly
    IF @TrangThaiHienTai = 'draft' RETURN 'draft';

    DECLARE @Now DATETIME = GETDATE();
    DECLARE @Today DATE = CAST(@Now AS DATE);
    DECLARE @NowTime TIME = CAST(@Now AS TIME);
    DECLARE @NgayKt DATE = ISNULL(@NgayKetThuc, @NgayBatDau);

    -- 1. Da qua ngay ket thuc -> ended
    IF @NgayKt < @Today RETURN 'ended';

    -- 1b. Cung ngay ket thuc + qua gio ket thuc -> ended (FIX MOI)
    IF @NgayKt = @Today AND @GioKetThuc IS NOT NULL AND @NowTime > @GioKetThuc
        RETURN 'ended';

    -- 2. Dang trong khoang BD-KT -> ongoing
    IF @NgayBatDau <= @Today AND @NgayKt >= @Today
    BEGIN
        DECLARE @DaBatDau BIT = 1;
        DECLARE @ChuaKetThuc BIT = 1;

        IF @Today = @NgayBatDau AND @GioBatDau IS NOT NULL AND @NowTime < @GioBatDau
            SET @DaBatDau = 0;

        IF @Today = @NgayKt AND @GioKetThuc IS NOT NULL AND @NowTime > @GioKetThuc
            SET @ChuaKetThuc = 0;

        IF @DaBatDau = 1 AND @ChuaKetThuc = 1
            RETURN 'ongoing';
    END

    -- 3. Het cho -> closed
    IF @SoDuyet >= @SucChua AND @SucChua > 0 RETURN 'closed';

    -- 4. Het han DK -> closed
    IF @HanDangKy IS NOT NULL AND @HanDangKy < @Today RETURN 'closed';

    -- 5. Admin chu dong dat closed -> giu closed
    IF @TrangThaiHienTai = 'closed' RETURN 'closed';

    -- 6. Default -> open
    RETURN 'open';
END;
GO

PRINT '[2] Da tao fn_TinhTrangThai (8 tham so, co check gio)';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 3: TAO LAI TRIGGER tren bang SuKien (8 params)
-- ════════════════════════════════════════════════════════════════════

CREATE TRIGGER dbo.tr_SuKien_AutoUpdateStatus
ON dbo.SuKien
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Chi chay khi sua HanDangKy / SucChua / NgayBatDau / NgayKetThuc / GioBatDau / GioKetThuc
    IF NOT (UPDATE(HanDangKy) OR UPDATE(SucChua) OR UPDATE(NgayBatDau)
            OR UPDATE(NgayKetThuc) OR UPDATE(GioBatDau) OR UPDATE(GioKetThuc))
        RETURN;

    UPDATE s
       SET s.TrangThai = dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0),
                s.GioBatDau, s.GioKetThuc
            ),
           s.NgayCapNhat = GETDATE()
      FROM dbo.SuKien s
     INNER JOIN inserted i ON s.SuKienID = i.SuKienID
      LEFT JOIN (
          SELECT SuKienID, COUNT(*) AS SoDuyet
          FROM dbo.DangKy WHERE TrangThai = 'approved'
          GROUP BY SuKienID
      ) d ON s.SuKienID = d.SuKienID
     WHERE s.TrangThai <> dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0),
                s.GioBatDau, s.GioKetThuc
            );
END;
GO

PRINT '[3] Da tao tr_SuKien_AutoUpdateStatus';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 4: TAO LAI TRIGGER tren bang DangKy (8 params)
-- ════════════════════════════════════════════════════════════════════

CREATE TRIGGER dbo.tr_DangKy_AutoUpdateEvent
ON dbo.DangKy
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AffectedSK TABLE (SuKienID INT PRIMARY KEY);
    INSERT INTO @AffectedSK
    SELECT DISTINCT SuKienID FROM inserted
    UNION
    SELECT DISTINCT SuKienID FROM deleted;

    UPDATE s
       SET s.TrangThai = dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0),
                s.GioBatDau, s.GioKetThuc
            ),
           s.NgayCapNhat = GETDATE()
      FROM dbo.SuKien s
     INNER JOIN @AffectedSK a ON s.SuKienID = a.SuKienID
      LEFT JOIN (
          SELECT SuKienID, COUNT(*) AS SoDuyet
          FROM dbo.DangKy WHERE TrangThai = 'approved'
          GROUP BY SuKienID
      ) d ON s.SuKienID = d.SuKienID
     WHERE s.TrangThai <> dbo.fn_TinhTrangThai(
                s.TrangThai, s.NgayBatDau, s.NgayKetThuc, s.HanDangKy,
                s.SucChua, ISNULL(d.SoDuyet, 0),
                s.GioBatDau, s.GioKetThuc
            );
END;
GO

PRINT '[4] Da tao tr_DangKy_AutoUpdateEvent';
GO

-- ════════════════════════════════════════════════════════════════════
-- BUOC 5: VERIFY
-- ════════════════════════════════════════════════════════════════════

-- Kiem tra so tham so function
SELECT
    'Function fn_TinhTrangThai co ' + CAST(COUNT(*) AS VARCHAR) + ' tham so' AS Result
FROM sys.parameters
WHERE object_id = OBJECT_ID('dbo.fn_TinhTrangThai')
  AND parameter_id > 0;

-- Test
SELECT
    'Test 17/05/2026 08-09h luc 14h cung ngay -> ' +
    dbo.fn_TinhTrangThai(
        'open', '2026-05-17', '2026-05-17', '2026-05-16',
        10, 0, '08:00', '09:00'
    ) AS Result;

-- Kiem tra triggers
SELECT name AS TriggerName, is_disabled
FROM sys.triggers
WHERE name IN ('tr_SuKien_AutoUpdateStatus', 'tr_DangKy_AutoUpdateEvent')
ORDER BY name;

PRINT '';
PRINT '====================================';
PRINT 'HOAN TAT FIX!';
PRINT '  - fn_TinhTrangThai: 8 tham so (co GioBatDau, GioKetThuc)';
PRINT '  - tr_SuKien_AutoUpdateStatus: goi function 8 params';
PRINT '  - tr_DangKy_AutoUpdateEvent: goi function 8 params';
PRINT '====================================';
GO
select*from dbo.Users
-- ════════════════════════════════════════════════════════════════════
-- AdminDashboard Stored Procedures  –  EventHub
-- Thêm vào database EventHub
-- ════════════════════════════════════════════════════════════════════

USE EventHub;
GO

-- ─────────────────────────────────────────────────────────────────────
-- SP 1: usp_Dashboard_GetStats
-- Trả 6 resultset cho 4 stat card + 2 delta
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.usp_Dashboard_GetStats','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Dashboard_GetStats;
GO

CREATE PROCEDURE dbo.usp_Dashboard_GetStats
AS
BEGIN
    SET NOCOUNT ON;

    -- [1] Tổng sự kiện
    SELECT COUNT(*) AS TongSuKien FROM dbo.SuKien;

    -- [2] Tổng người đã được duyệt (approved)
    SELECT COUNT(*) AS TongNguoiThamGia
    FROM dbo.DangKy WHERE TrangThai = 'approved';

    -- [3] Tỉ lệ điểm danh (%)
    SELECT
        CASE WHEN COUNT(*) = 0 THEN 0
             ELSE CAST(
                 SUM(CASE WHEN DaDiemDanh = 1 THEN 1 ELSE 0 END) * 100.0
                 / COUNT(*) AS INT)
        END AS TyLeThamDu
    FROM dbo.DangKy WHERE TrangThai = 'approved';

    -- [4] Sự kiện tháng này
    SELECT COUNT(*) AS SuKienThangNay
    FROM dbo.SuKien
    WHERE MONTH(NgayBatDau) = MONTH(GETDATE())
      AND YEAR(NgayBatDau)  = YEAR(GETDATE());

    -- [5] Delta sự kiện (tháng này - tháng trước)
    DECLARE @skNay    INT = (SELECT COUNT(*) FROM dbo.SuKien
        WHERE MONTH(NgayBatDau)=MONTH(GETDATE()) AND YEAR(NgayBatDau)=YEAR(GETDATE()));
    DECLARE @skTruoc  INT = (SELECT COUNT(*) FROM dbo.SuKien
        WHERE MONTH(NgayBatDau)=MONTH(DATEADD(MONTH,-1,GETDATE()))
          AND YEAR(NgayBatDau) =YEAR(DATEADD(MONTH,-1,GETDATE())));
    SELECT @skNay - @skTruoc AS DeltaSuKien;

    -- [6] % delta người tham gia (approved theo tháng)
    DECLARE @nguoiNay   INT = (
        SELECT COUNT(*) FROM dbo.DangKy dk
        INNER JOIN dbo.SuKien sk ON dk.SuKienID = sk.SuKienID
        WHERE dk.TrangThai = 'approved'
          AND MONTH(sk.NgayBatDau) = MONTH(GETDATE())
          AND YEAR(sk.NgayBatDau)  = YEAR(GETDATE()));
    DECLARE @nguoiTruoc INT = (
        SELECT COUNT(*) FROM dbo.DangKy dk
        INNER JOIN dbo.SuKien sk ON dk.SuKienID = sk.SuKienID
        WHERE dk.TrangThai = 'approved'
          AND MONTH(sk.NgayBatDau) = MONTH(DATEADD(MONTH,-1,GETDATE()))
          AND YEAR(sk.NgayBatDau)  = YEAR(DATEADD(MONTH,-1,GETDATE())));
    SELECT
        CASE WHEN @nguoiTruoc = 0 THEN 0
             ELSE CAST((@nguoiNay - @nguoiTruoc) * 100.0 / @nguoiTruoc AS INT)
        END AS DeltaNguoiThamGia;
END;
GO

-- ─────────────────────────────────────────────────────────────────────
-- SP 2: usp_Dashboard_GetBarChart
-- 12 tháng gần nhất: số đăng ký + thực dự
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.usp_Dashboard_GetBarChart','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Dashboard_GetBarChart;
GO

CREATE PROCEDURE dbo.usp_Dashboard_GetBarChart
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH months AS (
        SELECT TOP 12
            DATEADD(MONTH, -n,
                DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS FirstDay,
            n
        FROM (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
            FROM sys.objects
        ) x
        ORDER BY n DESC
    )
    SELECT
        FORMAT(m.FirstDay, 'MM/yyyy')                                          AS Thang,
        ISNULL(SUM(CASE WHEN dk.TrangThai = 'approved' THEN 1 ELSE 0 END), 0) AS SoDangKy,
        ISNULL(SUM(CASE WHEN dk.DaDiemDanh = 1         THEN 1 ELSE 0 END), 0) AS SoThamDu
    FROM months m
    LEFT JOIN dbo.SuKien sk
           ON MONTH(sk.NgayBatDau) = MONTH(m.FirstDay)
          AND YEAR(sk.NgayBatDau)  = YEAR(m.FirstDay)
    LEFT JOIN dbo.DangKy dk ON dk.SuKienID = sk.SuKienID
    GROUP BY m.FirstDay, m.n
    ORDER BY m.n DESC;
END;
GO

-- ─────────────────────────────────────────────────────────────────────
-- SP 3: usp_Dashboard_GetDonut
-- Phân bố loại sự kiện
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.usp_Dashboard_GetDonut','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Dashboard_GetDonut;
GO

CREATE PROCEDURE dbo.usp_Dashboard_GetDonut
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        LoaiSuKien,
        COUNT(*) AS SoLuong,
        CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS INT) AS PhanTram
    FROM dbo.SuKien
    GROUP BY LoaiSuKien
    ORDER BY SoLuong DESC;
END;
GO

-- ─────────────────────────────────────────────────────────────────────
-- SP 4: usp_Dashboard_GetRecentEvents
-- 10 sự kiện tạo gần nhất kèm trạng thái UI
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.usp_Dashboard_GetRecentEvents','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Dashboard_GetRecentEvents;
GO

CREATE PROCEDURE dbo.usp_Dashboard_GetRecentEvents
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 10
        sk.SuKienID   AS MaSuKien,
        sk.TenSuKien,
        sk.NgayBatDau AS NgayToChuc,
        sk.LoaiSuKien,
        sk.SucChua,
        ISNULL(d.SoDangKy, 0) AS SoDangKy,
        CASE
            WHEN sk.SucChua = 0 THEN 0
            ELSE CAST(ISNULL(d.SoDangKy, 0) * 100 / sk.SucChua AS INT)
        END AS PhanTram,
        sk.TrangThai,
        CASE sk.TrangThai
            WHEN 'open'     THEN 'open'
            WHEN 'ongoing'  THEN 'open'
            WHEN 'upcoming' THEN 'soon'
            WHEN 'draft'    THEN 'soon'
            WHEN 'closed'   THEN 'closed'
            WHEN 'ended'    THEN 'closed'
            ELSE 'soon'
        END AS TrangThaiClass,
        CASE sk.TrangThai
            WHEN 'open'     THEN N'Mở đăng ký'
            WHEN 'ongoing'  THEN N'Đang diễn ra'
            WHEN 'upcoming' THEN N'Sắp diễn ra'
            WHEN 'draft'    THEN N'Nháp'
            WHEN 'closed'   THEN N'Đã đóng'
            WHEN 'ended'    THEN N'Đã kết thúc'
            ELSE sk.TrangThai
        END AS TrangThaiText
    FROM dbo.SuKien sk
    LEFT JOIN (
        SELECT SuKienID, COUNT(*) AS SoDangKy
        FROM dbo.DangKy
        WHERE TrangThai = 'approved'
        GROUP BY SuKienID
    ) d ON sk.SuKienID = d.SuKienID
    ORDER BY sk.NgayTao DESC;
END;
GO

PRINT 'AdminDashboard SPs created successfully.';
GO
-- ════════════════════════════════════════════════════════════════════
-- AdminDashboard Stored Procedures  –  EventHub
-- Thêm vào database EventHub
-- ════════════════════════════════════════════════════════════════════

USE EventHub;
GO

-- ─────────────────────────────────────────────────────────────────────
-- SP 1: usp_Dashboard_GetStats
-- Trả 6 resultset cho 4 stat card + 2 delta
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.usp_Dashboard_GetStats','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Dashboard_GetStats;
GO

CREATE PROCEDURE dbo.usp_Dashboard_GetStats
AS
BEGIN
    SET NOCOUNT ON;

    -- [1] Tổng sự kiện
    SELECT COUNT(*) AS TongSuKien FROM dbo.SuKien;

    -- [2] Tổng người đã được duyệt (approved)
    SELECT COUNT(*) AS TongNguoiThamGia
    FROM dbo.DangKy WHERE TrangThai = 'approved';

    -- [3] Tỉ lệ điểm danh (%)
    SELECT
        CASE WHEN COUNT(*) = 0 THEN 0
             ELSE CAST(
                 SUM(CASE WHEN DaDiemDanh = 1 THEN 1 ELSE 0 END) * 100.0
                 / COUNT(*) AS INT)
        END AS TyLeThamDu
    FROM dbo.DangKy WHERE TrangThai = 'approved';

    -- [4] Sự kiện tháng này
    SELECT COUNT(*) AS SuKienThangNay
    FROM dbo.SuKien
    WHERE MONTH(NgayBatDau) = MONTH(GETDATE())
      AND YEAR(NgayBatDau)  = YEAR(GETDATE());

    -- [5] Delta sự kiện (tháng này - tháng trước)
    DECLARE @skNay    INT = (SELECT COUNT(*) FROM dbo.SuKien
        WHERE MONTH(NgayBatDau)=MONTH(GETDATE()) AND YEAR(NgayBatDau)=YEAR(GETDATE()));
    DECLARE @skTruoc  INT = (SELECT COUNT(*) FROM dbo.SuKien
        WHERE MONTH(NgayBatDau)=MONTH(DATEADD(MONTH,-1,GETDATE()))
          AND YEAR(NgayBatDau) =YEAR(DATEADD(MONTH,-1,GETDATE())));
    SELECT @skNay - @skTruoc AS DeltaSuKien;

    -- [6] % delta người tham gia (approved theo tháng)
    DECLARE @nguoiNay   INT = (
        SELECT COUNT(*) FROM dbo.DangKy dk
        INNER JOIN dbo.SuKien sk ON dk.SuKienID = sk.SuKienID
        WHERE dk.TrangThai = 'approved'
          AND MONTH(sk.NgayBatDau) = MONTH(GETDATE())
          AND YEAR(sk.NgayBatDau)  = YEAR(GETDATE()));
    DECLARE @nguoiTruoc INT = (
        SELECT COUNT(*) FROM dbo.DangKy dk
        INNER JOIN dbo.SuKien sk ON dk.SuKienID = sk.SuKienID
        WHERE dk.TrangThai = 'approved'
          AND MONTH(sk.NgayBatDau) = MONTH(DATEADD(MONTH,-1,GETDATE()))
          AND YEAR(sk.NgayBatDau)  = YEAR(DATEADD(MONTH,-1,GETDATE())));
    SELECT
        CASE WHEN @nguoiTruoc = 0 THEN 0
             ELSE CAST((@nguoiNay - @nguoiTruoc) * 100.0 / @nguoiTruoc AS INT)
        END AS DeltaNguoiThamGia;
END;
GO

-- ─────────────────────────────────────────────────────────────────────
-- SP 2: usp_Dashboard_GetBarChart
-- 12 tháng gần nhất: số đăng ký + thực dự
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.usp_Dashboard_GetBarChart','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Dashboard_GetBarChart;
GO

CREATE PROCEDURE dbo.usp_Dashboard_GetBarChart
AS
BEGIN
    SET NOCOUNT ON;

    -- Đủ 12 tháng T1→T12 của năm hiện tại, kể cả tháng chưa có dữ liệu (= 0)
    ;WITH months(SoThang) AS (
        SELECT 1  UNION ALL SELECT 2  UNION ALL SELECT 3
        UNION ALL SELECT 4  UNION ALL SELECT 5  UNION ALL SELECT 6
        UNION ALL SELECT 7  UNION ALL SELECT 8  UNION ALL SELECT 9
        UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    )
    SELECT
        m.SoThang,
        'T' + CAST(m.SoThang AS NVARCHAR) AS NhanThang,
        ISNULL(SUM(CASE WHEN dk.TrangThai = 'approved' THEN 1 ELSE 0 END), 0) AS SoDangKy,
        ISNULL(SUM(CASE WHEN dk.DaDiemDanh = 1         THEN 1 ELSE 0 END), 0) AS SoThamDu
    FROM months m
    LEFT JOIN dbo.SuKien sk
           ON MONTH(sk.NgayBatDau) = m.SoThang
          AND YEAR(sk.NgayBatDau)  = YEAR(GETDATE())
    LEFT JOIN dbo.DangKy dk ON dk.SuKienID = sk.SuKienID
    GROUP BY m.SoThang
    ORDER BY m.SoThang;
END;
GO

-- ─────────────────────────────────────────────────────────────────────
-- SP 3: usp_Dashboard_GetDonut
-- Phân bố loại sự kiện
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.usp_Dashboard_GetDonut','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Dashboard_GetDonut;
GO

CREATE PROCEDURE dbo.usp_Dashboard_GetDonut
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        LoaiSuKien,
        COUNT(*) AS SoLuong,
        CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS INT) AS PhanTram
    FROM dbo.SuKien
    GROUP BY LoaiSuKien
    ORDER BY SoLuong DESC;
END;
GO

-- ─────────────────────────────────────────────────────────────────────
-- SP 4: usp_Dashboard_GetRecentEvents
-- 10 sự kiện tạo gần nhất kèm trạng thái UI
-- ─────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.usp_Dashboard_GetRecentEvents','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_Dashboard_GetRecentEvents;
GO

CREATE PROCEDURE dbo.usp_Dashboard_GetRecentEvents
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 10
        sk.SuKienID   AS MaSuKien,
        sk.TenSuKien,
        sk.NgayBatDau AS NgayToChuc,
        sk.LoaiSuKien,
        sk.SucChua,
        ISNULL(d.SoDangKy, 0) AS SoDangKy,
        CASE
            WHEN sk.SucChua = 0 THEN 0
            ELSE CAST(ISNULL(d.SoDangKy, 0) * 100 / sk.SucChua AS INT)
        END AS PhanTram,
        sk.TrangThai,
        CASE sk.TrangThai
            WHEN 'open'     THEN 'open'
            WHEN 'ongoing'  THEN 'open'
            WHEN 'upcoming' THEN 'soon'
            WHEN 'draft'    THEN 'soon'
            WHEN 'closed'   THEN 'closed'
            WHEN 'ended'    THEN 'closed'
            ELSE 'soon'
        END AS TrangThaiClass,
        CASE sk.TrangThai
            WHEN 'open'     THEN N'Mở đăng ký'
            WHEN 'ongoing'  THEN N'Đang diễn ra'
            WHEN 'upcoming' THEN N'Sắp diễn ra'
            WHEN 'draft'    THEN N'Nháp'
            WHEN 'closed'   THEN N'Đã đóng'
            WHEN 'ended'    THEN N'Đã kết thúc'
            ELSE sk.TrangThai
        END AS TrangThaiText
    FROM dbo.SuKien sk
    LEFT JOIN (
        SELECT SuKienID, COUNT(*) AS SoDangKy
        FROM dbo.DangKy
        WHERE TrangThai = 'approved'
        GROUP BY SuKienID
    ) d ON sk.SuKienID = d.SuKienID
    ORDER BY sk.NgayTao DESC;
END;
GO

PRINT 'AdminDashboard SPs created successfully.';
GO
select * from dbo.Users
-- ════════════════════════════════════════════════════════════════════
-- BANG LUU LICH SU NHAP MA XAC NHAN (CAPTCHA)
-- ════════════════════════════════════════════════════════════════════
USE EventHub;
GO

IF OBJECT_ID('dbo.CaptchaLog', 'U') IS NOT NULL
    DROP TABLE dbo.CaptchaLog;
GO

CREATE TABLE dbo.CaptchaLog
(
    CaptchaLogID  INT IDENTITY(1,1) PRIMARY KEY,
    UserID        INT NULL,                       -- NULL neu chua login (truy theo SessionID)
    SessionID     NVARCHAR(100) NULL,             -- Phong khi user chua co UserID
    MaCaptcha     NVARCHAR(10) NOT NULL,          -- Ma user da nhap (VD: AB3C5@)
    KetQua        NVARCHAR(20) NOT NULL,          -- 'success' | 'failed'
    NgayNhap      DATETIME NOT NULL DEFAULT GETDATE(),
    Hidden        BIT NOT NULL DEFAULT 0          -- 1 = an khoi danh sach
);
GO

-- Index de query nhanh
CREATE INDEX IX_CaptchaLog_Session ON dbo.CaptchaLog(SessionID, Hidden, NgayNhap DESC);
CREATE INDEX IX_CaptchaLog_User    ON dbo.CaptchaLog(UserID,    Hidden, NgayNhap DESC);
GO

PRINT 'Da tao bang CaptchaLog!';

-- ════════════════════════════════════════════════════════════════════
-- TEST
-- ════════════════════════════════════════════════════════════════════
-- SELECT * FROM dbo.CaptchaLog ORDER BY NgayNhap DESC;
select* from dbo.CaptchaLog
UPDATE dbo.CaptchaLog
SET Hidden = 0
WHERE CaptchaLogID = 5;