/* ═══════════════════════════════════════════════
   EventHub – Site.js  (shared scripts)
   ═══════════════════════════════════════════════ */

// Notification panel toggle
function toggleNotif() {
    document.getElementById('notifPanel').classList.toggle('open');
}

// Toast notification
function showToast(msg) {
    var t = document.getElementById('toast');
    document.getElementById('toastMsg').textContent = msg;
    t.classList.add('show');
    setTimeout(function () { t.classList.remove('show'); }, 3500);
}

// Close notif panel when clicking outside
document.addEventListener('click', function (e) {
    var panel = document.getElementById('notifPanel');
    var btn = document.querySelector('.notif-btn');
    if (panel && !panel.contains(e.target) && btn && !btn.contains(e.target)) {
        panel.classList.remove('open');
    }
});

// Set greeting based on time
function setGreeting() {
    var h = new Date().getHours();
    var g = h < 12 ? 'Chào buổi sáng' : h < 18 ? 'Chào buổi chiều' : 'Chào buổi tối';
    var el = document.getElementById('timeGreet');
    if (el) {
        var days = ['Chủ nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
        var now = new Date();
        var dayName = days[now.getDay()];
        var dateStr = now.getDate().toString().padStart(2, '0') + '/' + (now.getMonth() + 1).toString().padStart(2, '0') + '/' + now.getFullYear();
        el.textContent = g + ' · ' + dayName + ', ' + dateStr;
    }
}

// Announce band close
function closeAnnounce() {
    var band = document.getElementById('announceBand');
    if (band) band.style.display = 'none';
}

document.addEventListener('DOMContentLoaded', function () {
    setGreeting();
});