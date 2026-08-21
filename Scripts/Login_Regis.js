// ════════════════════════════════════════════
//  Login_Regis.js
//  Tab UI ban đầu được set từ SERVER (C#) - JS chỉ xử lý khi user CLICK
// ════════════════════════════════════════════

function findById(endsWith) {
    var el = document.getElementById(endsWith);
    if (el) return el;
    var all = document.querySelectorAll('[id$="' + endsWith + '"]');
    return all.length > 0 ? all[0] : null;
}

/**
 * Đổi tab khi user click - chỉ set hidden field rồi chuyển UI
 */
function switchTab(tab, btn) {
    var section = findById('formSection');
    var title = findById('formTitle');
    var subtitle = findById('formSubtitle');
    var footer = findById('formFooter');
    var submitBtn = findById('btnSubmit');
    var hf = findById('hfAuthMode');
    var msgBox = findById('lblMsg');

    if (!section) return false;

    document.querySelectorAll('.tab-btn').forEach(function (b) {
        b.classList.remove('active');
    });
    if (btn) {
        btn.classList.add('active');
    } else {
        var tabs = document.querySelectorAll('.tab-btn');
        if (tabs.length >= 2)
            tabs[tab === 'register' ? 1 : 0].classList.add('active');
    }

    if (tab === 'register') {
        section.classList.add('register-active');
        if (title) title.textContent = 'Tạo tài khoản';
        if (subtitle) subtitle.textContent = 'Điền thông tin để bắt đầu';
        if (submitBtn) submitBtn.value = 'Tạo tài khoản';
        if (hf) hf.value = 'register';
        if (footer) footer.innerHTML =
            'Đã có tài khoản? <a href="#" onclick="switchTab(\'login\',null);return false;">Đăng nhập</a>';
    } else {
        section.classList.remove('register-active');
        if (title) title.textContent = 'Chào mừng trở lại';
        if (subtitle) subtitle.textContent = 'Đăng nhập để tiếp tục sử dụng EventHub';
        if (submitBtn) submitBtn.value = 'Đăng nhập';
        if (hf) hf.value = 'login';
        if (footer) footer.innerHTML =
            'Chưa có tài khoản? <a href="#" onclick="switchTab(\'register\',null);return false;">Đăng ký ngay</a>';
    }

    // ❗ Khi user CHỦ ĐỘNG đổi tab thì ẩn thông báo lỗi cũ
    if (msgBox) msgBox.style.display = 'none';

    return false;
}

function showToast(msg) {
    var toast = document.getElementById('toast');
    var span = document.getElementById('toastMsg');
    if (!toast || !span) return;
    span.textContent = msg;
    toast.classList.add('show');
    setTimeout(function () { toast.classList.remove('show'); }, 4000);
}

// ════════════════════════════════════════════
//  Tuyết rơi
// ════════════════════════════════════════════
document.addEventListener('DOMContentLoaded', function () {
    var canvas = document.getElementById('snowCanvas');
    if (!canvas) return;
    var ctx = canvas.getContext('2d');
    var hero = canvas.parentElement;
    var flakes = [], wind = 0;

    function resize() {
        canvas.width = hero.clientWidth;
        canvas.height = hero.clientHeight;
    }
    resize();
    window.addEventListener('resize', resize);

    for (var i = 0; i < 100; i++) {
        flakes.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            r: Math.random() * 3 + 1,
            vy: Math.random() * 1.2 + 0.3,
            vx: Math.random() * 0.4 - 0.2,
            op: Math.random() * 0.6 + 0.2,
            t: Math.random() * Math.PI,
            ts: Math.random() * 0.03 + 0.005
        });
    }

    function loop() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        wind += 0.001;
        flakes.forEach(function (f) {
            ctx.beginPath();
            ctx.arc(f.x, f.y, f.r, 0, Math.PI * 2);
            ctx.fillStyle = 'rgba(255,255,255,' + f.op + ')';
            ctx.fill();
            f.y += f.vy;
            f.x += f.vx + Math.sin(wind + f.t) * 0.2;
            f.t += f.ts;
            if (f.y > canvas.height) { f.y = -5; f.x = Math.random() * canvas.width; }
            if (f.x > canvas.width) f.x = 0;
            if (f.x < 0) f.x = canvas.width;
        });
        requestAnimationFrame(loop);
    }
    loop();
});