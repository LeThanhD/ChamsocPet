import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final newPasswordController = TextEditingController();
  final codeInputController = TextEditingController();

  String generatedCode = '';
  bool showCodeInput = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFD3EC), Color(0xFFB3E5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SizedBox(
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Text(
                        "Quên Mật Khẩu",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      'assets/anhAvatar.png',
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('Không thể tải ảnh'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(hintText: 'Tên tài khoản', controller: usernameController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hintText: 'Số điện thoại',
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hintText: 'Mật khẩu mới',
                    controller: newPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 16),

                  if (showCodeInput) ...[
                    const Text("Nhập mã xác nhận hiển thị bên cạnh:",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: codeInputController,
                            decoration: InputDecoration(
                              hintText: 'Nhập mã xác nhận',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            generatedCode,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Nút xác nhận
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.95),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        shadowColor: Colors.black.withOpacity(0.08),
                        elevation: 6,
                      ),
                      onPressed: isLoading ? null : _handleResetPassword,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.black87)
                          : const Text(
                        'Xác nhận',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: hintText.toLowerCase().contains("mật khẩu"),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  String _generateRandomCode({int length = 5}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _handleResetPassword() async {
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();
    final newPass = newPasswordController.text.trim();
    final enteredCode = codeInputController.text.trim();

    if (username.isEmpty || phone.isEmpty || newPass.isEmpty) {
      _showMessage('Vui lòng điền đầy đủ thông tin');
      return;
    }

    if (!showCodeInput) {
      generatedCode = _generateRandomCode();
      setState(() => showCodeInput = true);
      _showMessage('Vui lòng nhập mã xác nhận để tiếp tục');
      return;
    }

    if (enteredCode != generatedCode) {
      _showMessage('Mã xác nhận không đúng');
      return;
    }

    // Gọi API đổi mật khẩu
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://10.24.67.249:8000/api/users/force-reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'phone': phone,
          'password': newPass,
        }),
      );

      if (response.statusCode == 200) {
        _showMessage('Đổi mật khẩu thành công');
        Navigator.pushReplacementNamed(context, '/');
      } else {
        final data = jsonDecode(response.body);
        _showMessage(data['message'] ?? 'Lỗi không xác định');
      }
    } catch (e) {
      _showMessage('Không thể kết nối đến máy chủ');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
