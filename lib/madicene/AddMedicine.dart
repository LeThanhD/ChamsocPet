import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddMedicineScreen extends StatefulWidget {
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController();
  final instructionsController = TextEditingController();
  final imageUrlController = TextEditingController();

  bool isLoading = false;

  Future<void> _submitMedicine() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        quantityController.text.isEmpty ||
        unitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('http://10.24.67.249:8000/api/medications'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'Name': nameController.text,
        'Price': int.tryParse(priceController.text.replaceAll('.', '')) ?? 0,
        'Quantity': int.tryParse(quantityController.text) ?? 0,
        'Unit': unitController.text,
        'UsageInstructions': instructionsController.text,
        'ImageURL': imageUrlController.text,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      Navigator.pop(context, 'refresh');
    } else {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Không xác định';
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Lỗi'),
          content: Text('Thêm thuốc thất bại: $message'),
        ),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      onChanged: (_) {
        if (controller == imageUrlController) setState(() {});
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDEFF9), Color(0xFFD1F4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      '🩺 Thêm thuốc',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'Tên thuốc',
                  icon: Icons.medication_outlined,
                  controller: nameController,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Giá thuốc (VND)',
                  icon: Icons.price_change_outlined,
                  controller: priceController,
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Số lượng',
                  icon: Icons.confirmation_number_outlined,
                  controller: quantityController,
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Đơn vị (ví dụ: viên, lọ)',
                  icon: Icons.balance_outlined,
                  controller: unitController,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Hướng dẫn sử dụng',
                  icon: Icons.description_outlined,
                  controller: instructionsController,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Link ảnh (tuỳ chọn)',
                  icon: Icons.image_outlined,
                  controller: imageUrlController,
                ),
                const SizedBox(height: 8),
                if (imageUrlController.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrlController.text,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text('Ảnh không hợp lệ'),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                    onPressed: _submitMedicine,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Xác nhận'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
