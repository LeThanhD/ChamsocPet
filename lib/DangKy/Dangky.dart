import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../login/TrangChinh.dart';

class RegisterFullScreen extends StatefulWidget {
  const RegisterFullScreen({super.key});

  @override
  State<RegisterFullScreen> createState() => _RegisterFullScreenState();
}

class _RegisterFullScreenState extends State<RegisterFullScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _nationalIDController = TextEditingController();

  bool _obscurePassword = true;
  DateTime? birthDate;

  final RegExp _phoneRegExp = RegExp(r'^\d{9,11}$');
  final RegExp _emailRegExp = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$');
  final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> submitToAPI(Map<String, dynamic> data) async {
    final url = Uri.parse('http://192.168.0.108:8000/api/users');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw FormatException("API không trả về JSON hợp lệ:\n${response.body}");
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Đăng ký thành công!')),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        String message = responseData['message'] ?? 'Lỗi không xác định';
        if (responseData['errors'] != null) {
          message += '\n' + responseData['errors'].values
              .map((e) => (e as List).join(', '))
              .join('\n');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi từ server: $message')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không kết nối được tới API: $e')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userData = {
        "username": _usernameController.text.trim(),
        "password": _passwordController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "full_name": _fullNameController.text.trim(),
        "birth_date": DateFormat('yyyy-MM-dd').format(birthDate!),
        "address": _addressController.text.trim(),
        "national_id": _nationalIDController.text.trim(),
      };
      submitToAPI(userData);
    }
  }

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFBD3E9), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Đăng ký tài khoản",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: _input("Tài khoản"),
                    validator: (v) => v == null || v.isEmpty ? "Nhập tài khoản" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _input("Mật khẩu").copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Nhập mật khẩu';
                      if (!_passwordRegExp.hasMatch(v)) {
                        return 'Ít nhất 8 ký tự, 1 hoa, 1 số, 1 ký tự đặc biệt';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: _input("Email"),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Nhập email";
                      if (!_emailRegExp.hasMatch(v)) return "Email không hợp lệ";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: _input("Số điện thoại"),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Nhập số điện thoại";
                      if (!_phoneRegExp.hasMatch(v)) return "Sai định dạng";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: _input("Họ và tên"),
                    validator: (v) => v == null || v.isEmpty ? "Nhập họ tên" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: _input("Ngày sinh"),
                    validator: (v) => v == null || v.isEmpty ? "Chọn ngày sinh" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: _input("Địa chỉ"),
                    validator: (v) => v == null || v.isEmpty ? "Nhập địa chỉ" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nationalIDController,
                    decoration: _input("Căn cước công dân"),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Nhập số CCCD";
                      if (!RegExp(r'^\d{9,12}$').hasMatch(v)) return "CCCD không hợp lệ";
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
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
                      onPressed: _submitForm,
                      child: const Text(
                        "Đăng ký",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
