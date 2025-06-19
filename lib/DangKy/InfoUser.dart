import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();

  String fullName = '';
  DateTime? birthDate;
  String address = '';

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
          SnackBar(content: Text(responseData['message'] ?? '🎉 Đăng ký thành công!')),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final base = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      final userData = {
        "username": base['username'],
        "password": base['password'],
        "email": base['email'],
        "phone": base['phone'],
        "full_name": fullName,
        "birth_date": DateFormat('yyyy-MM-dd').format(birthDate!),
        "address": address,
        "country": "Việt Nam"
      };

      await submitToAPI(userData);
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
            child: Column(
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
                        "Nhập thông tin đăng ký",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: _input('Họ và tên'),
                            validator: (v) => v == null || v.isEmpty ? 'Nhập họ tên' : null,
                            onSaved: (v) => fullName = v!,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            decoration: _input('Ngày sinh'),
                            onTap: _selectDate,
                            validator: (v) => v == null || v.isEmpty ? 'Chọn ngày sinh' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: _input('Địa chỉ'),
                            validator: (v) => v == null || v.isEmpty ? 'Nhập địa chỉ' : null,
                            onSaved: (v) => address = v!,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: 'Việt Nam',
                            readOnly: true,
                            decoration: _input('Quốc gia'),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue[200],
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Đăng ký',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
