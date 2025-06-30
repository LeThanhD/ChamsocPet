import 'package:flutter/material.dart';
import '../DangKy/Dangky.dart';
import '../QuenMk/quenMatKhau.dart';
import 'DangNhap.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7BEEA), Color(0xFF99D8F4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Nút hỗ trợ (góc trái trên)
              Positioned(
                top: 10,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Hỗ trợ"),
                        content: const Text(
                          "Liên hệ email hoặc hotline để được hỗ trợ.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Đóng"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.help_outline, color: Colors.black54),
                      SizedBox(width: 6),
                      Text('Hỗ trợ', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),

              // Nội dung chính
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/anhAvatar.png',
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text('Không thể tải ảnh'),
                      ),
                      const SizedBox(height: 36),

                      _buildFrostedButton(context, 'Đăng nhập'),
                      const SizedBox(height: 16),
                      _buildFrostedButton(context, 'Đăng ký'),
                      const SizedBox(height: 28),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Quên mật khẩu? ',
                            style: const TextStyle(color: Colors.black87),
                            children: [
                              TextSpan(
                                text: 'Lấy lại tại đây.',
                                style: TextStyle(
                                  color: Colors.deepPurpleAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrostedButton(BuildContext context, String label) {
    return Container(
      width: double.infinity,
      height: 56, // tăng chiều cao nút
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          if (label == 'Đăng nhập') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
          } else if (label == 'Đăng ký') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterFullScreen()));
          }
        },
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18, // tăng kích thước chữ
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
