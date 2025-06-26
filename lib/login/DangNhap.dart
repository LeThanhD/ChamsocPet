import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Page/PageScreen.dart';

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
      final url = Uri.parse('http://192.168.0.108:8000/api/login'); // ⚠️ IP máy bạn, không phải localhost
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // ✅ RẤT QUAN TRỌNG: đảm bảo Laravel trả JSON thay vì HTML
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
        debugPrint("Lỗi không phải JSON: ${response.body}");
        return;
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data.containsKey('token') && data.containsKey('user')) {
          final token = data['token'];
          final user = data['user'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('username', user['Username'] ?? '');
          await prefs.setString('role', user['Role'] ?? '');

          // Lưu user_id đúng kiểu
          if (user['UserID'] != null) {
            if (user['UserID'] is int) {
              await prefs.setInt('user_id', user['UserID']);
            } else if (user['UserID'] is String) {
              await prefs.setString('user_id', user['UserID']);
            }
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PageScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phản hồi không hợp lệ từ máy chủ')),
          );
        }
      } else if (response.statusCode == 422) {
        String message = data['message'] ?? 'Lỗi xác thực';
        if (data['errors'] != null) {
          message += '\n' +
              data['errors'].values.map((e) => (e as List).join(', ')).join('\n');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } else {
        String message = data['message'] ?? 'Sai tài khoản hoặc mật khẩu!';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFD3EC), Color(0xFFB3E5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
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
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Image.asset(
                        'assets/anhAvatar.png',
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Tài khoản (username)',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Nhập tài khoản' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Mật khẩu',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Nhập mật khẩu' : null,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue[200],
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Đăng nhập', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
