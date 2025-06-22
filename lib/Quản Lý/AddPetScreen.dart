import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ManageScreen.dart';

class AddPetScreen extends StatefulWidget {
  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController healthController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? selectedGender;
  String? selectedSpecies;
  String? selectedBreed;

  final Map<String, List<String>> breedOptions = {
    'Chó': [
      'Poodle', 'Phốc sóc (Pom)', 'Chihuahua', 'Shih Tzu', 'Pug',
      'Corgi', 'Golden Retriever', 'Labrador Retriever', 'Chó ta (F1, bản địa)'
    ],
    'Mèo': [
      'Mèo ta (mướp/vằn)', 'Mèo Anh lông ngắn', 'Mèo Ba Tư', 'Mèo Xiêm',
      'Mèo Scottish tai cụp', 'Mèo Maine Coon'
    ],
  };

  // ID người dùng đã đăng nhập (có trong bảng Users)
  String userId = 'OWNER0001'; // Cập nhật đúng UserID

  Future<void> _submitPet() async {
    final uri = Uri.parse('http://192.168.0.108:8000/api/pets');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Name': nameController.text,
        'Gender': selectedGender,
        'FurColor': colorController.text,
        'Species': selectedSpecies,
        'Breed': selectedBreed,
        'BirthDate': dobController.text,
        'Weight': double.tryParse(weightController.text) ?? 0,
        'UserID': userId,
        'HealthStatus': healthController.text,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ManageScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Lỗi"),
          content: Text("Thêm thú cưng thất bại: ${response.body}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Thêm thú cưng',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField('Tên thú cưng', nameController),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Giới tính',
                        items: ['Đực', 'Cái'],
                        selectedValue: selectedGender,
                        onChanged: (value) => setState(() => selectedGender = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Màu sắc', colorController)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Loài',
                  items: breedOptions.keys.toList(),
                  selectedValue: selectedSpecies,
                  onChanged: (value) => setState(() {
                    selectedSpecies = value;
                    selectedBreed = null;
                  }),
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Giống',
                  items: selectedSpecies != null ? breedOptions[selectedSpecies]! : [],
                  selectedValue: selectedBreed,
                  onChanged: (value) => setState(() => selectedBreed = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField('Ngày sinh (YYYY-MM-DD)', dobController)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Cân nặng (kg)', weightController)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField('Tình trạng sức khỏe(nếu bệnh có thế ghi rõ triệu chứng)', healthController),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitPet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(label),
          value: selectedValue,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
