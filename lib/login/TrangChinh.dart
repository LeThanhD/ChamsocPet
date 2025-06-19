import 'package:flutter/material.dart';
import '../DangKy/Dangky.dart';
import '../QuenMk/quenMatKhau.dart';
import 'DangNhap.dart';


class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFD3EC), Color(0xFFB3E5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Nút hỗ trợ
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Hỗ trợ"),
                        content: Text(
                          "Vui lòng liên hệ qua email hoặc hotline để được hỗ trợ.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Đóng"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.help_outline, color: Colors.black54),
                      SizedBox(width: 4),
                      Text('Hỗ trợ', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),

              // Nội dung chính
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/anhAvatar.png',
                        height: 250,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'Không thể tải ảnh',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                      const SizedBox(height: 40),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1877F2),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          // TODO: xử lý đăng nhập Facebook
                        },
                        child: Text(
                          'Đăng nhập bằng Facebook',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text("hoặc",
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),

                      _buildFrostedButton(context, 'Đăng nhập'),
                      const SizedBox(height: 10),

                      _buildFrostedButton(context, 'Đăng ký'),
                      const SizedBox(height: 30),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                          );
                          },
                        child: Text.rich(
                          TextSpan(
                            text: 'Quên mật khẩu. ',
                            children: [
                              TextSpan(
                                text: 'Lấy lại tài khoản tại đây.',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
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
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.lightBlue[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          if (label == 'Đăng nhập') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
          } else if (label == 'Đăng ký') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RegisterFullScreen()),
            );
          }
        },
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
