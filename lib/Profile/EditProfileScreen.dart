import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final birthController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final citizenIdController = TextEditingController();

  String gender = "Nam";
  String userId = '';
  File? _selectedImage;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '';
    if (userId.isEmpty) return;

    final response = await http.get(Uri.parse('http://10.24.67.249:8000/api/users/detail/$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        nameController.text = data['name'] ?? '';
        birthController.text = data['birth_date'] ?? '';
        emailController.text = data['email'] ?? '';
        addressController.text = data['address'] ?? '';
        phoneController.text = data['phone'] ?? '';
        citizenIdController.text = data['citizen_id'] ?? '';
        gender = (data['gender'] == 1 || data['gender'] == 'Nam') ? 'Nam' : 'Nữ';

        final rawImage = data['image'] ?? '';
        imageUrl = rawImage.startsWith('http')
            ? rawImage
            : 'http://10.24.67.249:8000/storage/' + rawImage;
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> updateUser() async {
    final uri = Uri.parse('http://10.24.67.249:8000/api/users/$userId');
    final request = http.MultipartRequest('POST', uri)
      ..fields['full_name'] = nameController.text
      ..fields['birth_date'] = birthController.text
      ..fields['email'] = emailController.text
      ..fields['address'] = addressController.text
      ..fields['phone'] = phoneController.text
      ..fields['national_id'] = citizenIdController.text
      ..fields['gender'] = gender == 'Nam' ? '1' : '0'
      ..fields['_method'] = 'PUT';

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        _selectedImage!.path,
      ));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thất bại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF9FB),
      appBar: AppBar(
        title: const Text("Chỉnh sửa thông tin", style: TextStyle(color: Colors.black)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null) as ImageProvider?,
                    child: _selectedImage == null && imageUrl.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.camera_alt, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField("Họ tên", nameController, Icons.person),
                    _buildTextField("Ngày sinh", birthController, Icons.cake),
                    _buildTextField("Email", emailController, Icons.email),
                    _buildTextField("Địa chỉ", addressController, Icons.home),
                    _buildTextField("Số điện thoại", phoneController, Icons.phone),
                    _buildTextField("CCCD", citizenIdController, Icons.credit_card),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text("Giới tính", style: TextStyle(fontSize: 16)),
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: "Nam",
                          groupValue: gender,
                          onChanged: (value) => setState(() => gender = value!),
                        ),
                        const Text("Nam"),
                        Radio<String>(
                          value: "Nữ",
                          groupValue: gender,
                          onChanged: (value) => setState(() => gender = value!),
                        ),
                        const Text("Nữ"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Lưu"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    minimumSize: const Size(140, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: updateUser,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text("Huỷ"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: const Size(140, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
