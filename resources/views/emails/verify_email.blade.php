<h2>🎉 Chào bạn!</h2>

<p>Vui lòng nhấn vào nút bên dưới để xác nhận đăng ký tài khoản:</p>

<p>
    <a href="{{ url('/api/verify-email?token=' . $token) }}"
       style="display: inline-block; padding: 10px 20px; background-color: #28a745; color: white; text-decoration: none; border-radius: 5px;">
       ✅ Xác nhận tài khoản
    </a>
</p>

<p>Nếu bạn không yêu cầu đăng ký, vui lòng bỏ qua email này.</p>

<p>Trân trọng,<br>Hệ thống chăm sóc thú cưng</p>
