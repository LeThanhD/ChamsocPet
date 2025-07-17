import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddServiceScreen extends StatefulWidget {
  @override
  _AddServiceScreenState createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  String category = 'Chó';

  Future<void> submitService() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('http://192.168.0.108:8000/api/services');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'ServiceName': nameController.text,
        'Price': int.tryParse(priceController.text) ?? 0,
        'CategoryID': category,
        'Description': descriptionController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Tạo dịch vụ thành công!')),
      );
      Navigator.pop(context, 'refresh');
    } else {
      final err = jsonDecode(response.body);
      final msg = err['message'] ?? 'Tạo thất bại';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $msg')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 👉 Nền gradient phủ toàn bộ màn hình
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDEFF9), Color(0xFFD1F4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 👉 Nội dung có AppBar và Form
          SafeArea(
            child: Column(
              children: [
                // AppBar tuỳ chỉnh
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  height: 56,
                  child: Row(
                    children: const [
                      BackButton(color: Colors.black),
                      Expanded(
                        child: Center(
                          child: Text(
                            '➕ Thêm Dịch Vụ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 48), // Duy trì cân bằng với nút back
                    ],
                  ),
                ),

                // Form nhập liệu
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInputField(
                            controller: nameController,
                            label: 'Tên dịch vụ',
                            validatorText: 'Vui lòng nhập tên dịch vụ',
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: priceController,
                            label: 'Giá (VNĐ)',
                            validatorText: 'Vui lòng nhập giá',
                            isNumber: true,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: category,
                            decoration: InputDecoration(
                              labelText: 'Loại dịch vụ',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: ['Chó', 'Mèo']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) => setState(() => category = val!),
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: descriptionController,
                            label: 'Mô tả',
                            validatorText: 'Vui lòng nhập mô tả',
                            maxLines: 4,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: submitService,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.check),
                            label: const Text(
                              'Xác nhận',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String validatorText,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: (value) =>
      value == null || value.trim().isEmpty ? validatorText : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
