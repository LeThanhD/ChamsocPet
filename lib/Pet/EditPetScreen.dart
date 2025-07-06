import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditPetScreen extends StatefulWidget {
  final Map<String, dynamic> pet;

  const EditPetScreen({Key? key, required this.pet}) : super(key: key);

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController healthController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController furTypeController = TextEditingController();
  final TextEditingController originController = TextEditingController();
  final TextEditingController lastVaccineController = TextEditingController();
  final TextEditingController breedController = TextEditingController();

  String? selectedGender;
  String? selectedSpecies;

  bool vaccinated = false;
  bool trained = false;

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;

    nameController.text = pet['Name'] ?? '';
    colorController.text = pet['FurColor'] ?? '';
    weightController.text = pet['Weight']?.toString() ?? '';
    healthController.text = (pet['latestNote'] ?? pet['latest_note'])?['Content'] ?? '';
    dobController.text = pet['BirthDate'] ?? '';
    furTypeController.text = pet['fur_type'] ?? '';
    originController.text = pet['origin'] ?? '';
    lastVaccineController.text = pet['last_vaccine_date'] ?? '';
    breedController.text = pet['Breed'] ?? '';

    selectedGender = pet['Gender'];
    selectedSpecies = pet['Species'];
    vaccinated = pet['vaccinated'] == 1 || pet['vaccinated'] == true;
    trained = pet['trained'] == 1 || pet['trained'] == true;
  }

  Future<void> _updatePet() async {
    final petId = widget.pet['PetID'];
    final url = Uri.parse('http://192.168.0.108:8000/api/pets/$petId');

    final Map<String, dynamic> data = {
      'Name': nameController.text,
      'Gender': selectedGender,
      'FurColor': colorController.text,
      'Species': selectedSpecies,
      'Breed': breedController.text,
      'BirthDate': dobController.text,
      'Weight': double.tryParse(weightController.text) ?? 0.0,
      'fur_type': furTypeController.text,
      'origin': originController.text,
      'vaccinated': vaccinated ? 1 : 0,
      'last_vaccine_date': lastVaccineController.text,
      'trained': trained ? 1 : 0,
      'HealthStatus': healthController.text,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // ⚠ Không cần Authorization nếu bỏ auth middleware
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật thành công')),
        );
        Navigator.pop(context, 'updated');
      } else {
        final body = jsonDecode(response.body);
        final error = body['message'] ?? body['error'] ?? 'Lỗi không xác định';
        _showErrorDialog(error);
      }
    } catch (e) {
      _showErrorDialog('Lỗi kết nối tới máy chủ: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Chỉnh sửa thú cưng'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTextField('Tên thú cưng', nameController),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField('Giới tính', ['Đực', 'Cái'], selectedGender, (val) {
                            setState(() => selectedGender = val);
                          }),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Màu lông', colorController)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField('Loài', ['Chó', 'Mèo'], selectedSpecies, (val) {
                      setState(() => selectedSpecies = val);
                    }),
                    const SizedBox(height: 12),
                    _buildTextField('Giống', breedController),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Ngày sinh', dobController)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField('Cân nặng (kg)', weightController)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField('Tình trạng sức khỏe', healthController, maxLines: 2),
                    const SizedBox(height: 12),
                    _buildTextField('Loại lông', furTypeController),
                    const SizedBox(height: 12),
                    _buildTextField('Nguồn gốc', originController),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text("Đã tiêm ngừa"),
                            Switch(
                              value: vaccinated,
                              onChanged: (val) => setState(() => vaccinated = val),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("Đã huấn luyện"),
                            Switch(
                              value: trained,
                              onChanged: (val) => setState(() => trained = val),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildTextField('Ngày tiêm gần nhất', lastVaccineController),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD0BCFF),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu', style: TextStyle(fontSize: 16)),
                        onPressed: _updatePet,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(selectedValue) ? selectedValue : null,
          hint: Text(label),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: onChanged,
          items: items.map((val) {
            return DropdownMenuItem(value: val, child: Text(val));
          }).toList(),
        ),
      ),
    );
  }
}
