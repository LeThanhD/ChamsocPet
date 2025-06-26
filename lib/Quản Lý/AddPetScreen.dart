import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddPetScreen extends StatefulWidget {
  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final nameController = TextEditingController();
  final colorController = TextEditingController();
  final weightController = TextEditingController();
  final healthController = TextEditingController();
  final dobController = TextEditingController();
  final originController = TextEditingController();
  final lastVaccineDateController = TextEditingController();

  String? selectedGender;
  String? selectedSpecies;
  String? selectedBreed;
  String? selectedFurType;
  bool vaccinated = false;
  bool trained = false;
  String? userId;
  bool isLoading = false;

  final Map<String, List<String>> breedOptions = {
    'Chó': ['Poodle', 'Phốc sóc (Pom)', 'Chihuahua', 'Shih Tzu', 'Pug', 'Corgi', 'Golden Retriever', 'Labrador Retriever', 'Chó ta'],
    'Mèo': ['Mèo ta', 'Mèo Anh lông ngắn', 'Mèo Ba Tư', 'Mèo Xiêm', 'Mèo Scottish', 'Mèo Maine Coon'],
  };

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
  }

  Future<void> _submitPet() async {
    if (userId == null ||
        nameController.text.isEmpty ||
        selectedGender == null ||
        colorController.text.isEmpty ||
        selectedSpecies == null ||
        selectedBreed == null ||
        dobController.text.isEmpty ||
        weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    setState(() => isLoading = true);

    final uri = Uri.parse('http://192.168.0.108:8000/api/pets');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
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
        'origin': originController.text,
        'fur_type': selectedFurType,
        'vaccinated': vaccinated ? 1 : 0,
        'trained': trained ? 1 : 0,
        'last_vaccine_date': lastVaccineDateController.text.isNotEmpty
            ? lastVaccineDateController.text
            : null,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      Navigator.pop(context, 'added');
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Lỗi"),
          content: Text("Thêm thú cưng thất bại: ${response.body}"),
        ),
      );
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2020),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                        child: Text('Thêm thú cưng',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                _buildDropdownField(
                  label: 'Loài',
                  items: breedOptions.keys.toList(),
                  selectedValue: selectedSpecies,
                  onChanged: (value) => setState(() {
                    selectedSpecies = value;
                    selectedBreed = null;
                  }),
                ),
                _buildDropdownField(
                  label: 'Giống',
                  items: selectedSpecies != null ? breedOptions[selectedSpecies]! : [],
                  selectedValue: selectedBreed,
                  onChanged: (value) => setState(() => selectedBreed = value),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(dobController),
                        child: AbsorbPointer(
                          child: _buildTextField('Ngày sinh', dobController),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField('Cân nặng (kg)', weightController)),
                  ],
                ),
                _buildTextField('Tình trạng sức khỏe', healthController),
                _buildDropdownField(
                  label: 'Loại lông',
                  items: ['Ngắn', 'Dài', 'Xoăn'],
                  selectedValue: selectedFurType,
                  onChanged: (value) => setState(() => selectedFurType = value),
                ),
                _buildTextField('Nguồn gốc', originController),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const Text("Đã tiêm ngừa"),
                        value: vaccinated,
                        onChanged: (value) => setState(() => vaccinated = value),
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text("Đã huấn luyện"),
                        value: trained,
                        onChanged: (value) => setState(() => trained = value),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _pickDate(lastVaccineDateController),
                  child: AbsorbPointer(
                    child: _buildTextField('Ngày tiêm gần nhất', lastVaccineDateController),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _submitPet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                  ),
                ),
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
          border: const OutlineInputBorder(),
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
