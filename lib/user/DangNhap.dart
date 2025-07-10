import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Page/PageScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('http://192.168.0.108:8000/api/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      setState(() => isLoading = false);

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Máy chủ trả về định dạng không hợp lệ')),
        );
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data.containsKey('token') && data.containsKey('user')) {
        final prefs = await SharedPreferences.getInstance();
        final user = data['user'];

        await prefs.setString('token', data['token']);
        await prefs.setString('username', user['Username'] ?? '');
        await prefs.setString('role', user['Role'] ?? '');

        // ✅ Gửi FCM token về server
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null && user['UserID'] != null) {
          final updateTokenRes = await http.post(
            Uri.parse('http://192.168.0.108:8000/api/users/update-token'),
            headers: {'Accept': 'application/json'},
            body: {
              'UserID': user['UserID'].toString(),
              'fcm_token': fcmToken,
            },
          );

          if (updateTokenRes.statusCode == 200) {
            print('✅ Cập nhật FCM token thành công');
          } else {
            print('⚠️ Cập nhật FCM token thất bại: ${updateTokenRes.body}');
          }
        }


        if (user['UserID'] != null) {
          if (user['UserID'] is int) {
            await prefs.setInt('user_id', user['UserID']);
          } else if (user['UserID'] is String) {
            await prefs.setString('user_id', user['UserID']);
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PageScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Sai tài khoản hoặc mật khẩu!')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể kết nối máy chủ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7BEEA), Color(0xFF99D8F4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    "Đăng Nhập",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Image.asset(
                              'assets/anhAvatar.png',
                              height: 200,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                              const Text('Không thể tải ảnh'),
                            ),
                            const SizedBox(height: 32),
                            _buildInputField(
                              controller: _usernameController,
                              hintText: 'Tài khoản (username)',
                              validatorText: 'Nhập tài khoản',
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              controller: _passwordController,
                              hintText: 'Mật khẩu',
                              validatorText: 'Nhập mật khẩu',
                              isPassword: true,
                            ),
                            const SizedBox(height: 28),
                            _buildFrostedLoginButton(),
                            const Spacer(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String validatorText,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      validator: (value) =>
      value == null || value.trim().isEmpty ? validatorText : null,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        )
            : null,
      ),
    );
  }

  Widget _buildFrostedLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
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
        onPressed: isLoading ? null : loginUser,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.blueAccent)
            : const Text(
          'Đăng nhập',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}