import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'EditProfileScreen.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  String fullName = '';
  String gender = '';
  String birthDate = '';
  String address = '';
  String email = '';
  String phone = '';
  String citizenId = '';
  String userId = '';
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  String formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('yyyy-MM-dd').format(date); // hoặc 'dd/MM/yyyy'
    } catch (_) {
      return rawDate;
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '';
    if (userId.isEmpty) return;

    final url = Uri.parse('http://192.168.0.108:8000/api/users/detail/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        fullName = data['name'] ?? '';
        gender = (data['gender'] == 1 || data['gender'] == 'Nam') ? 'Nam' : 'Nữ';
        birthDate = formatDate(data['birth_date'] ?? ''); // ✅ Chỗ này cần gọi hàm format
        address = data['address'] ?? '';
        email = data['email'] ?? '';
        phone = data['phone'] ?? '';
        citizenId = data['citizen_id'] ?? '';
        final rawImage = data['image'] ?? '';
        imageUrl = rawImage.startsWith('http')
            ? rawImage
            : 'http://192.168.0.108:8000/storage/images/$rawImage';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text("Thông tin cá nhân", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.black),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white70)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow(icon: Icons.wc, label: "Giới tính", value: gender),
                    InfoRow(icon: Icons.cake, label: "Ngày sinh", value: birthDate),
                    InfoRow(icon: Icons.home, label: "Địa chỉ", value: address),
                    InfoRow(icon: Icons.email, label: "Email", value: email),
                    InfoRow(icon: Icons.phone, label: "Số điện thoại", value: phone),
                    InfoRow(icon: Icons.badge, label: "CCCD", value: citizenId),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text("Chỉnh sửa", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfileScreen()),
                );
                if (result == true) {
                  loadUserData();
                }
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: ${value.isEmpty ? '(Chưa có)' : value}",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
