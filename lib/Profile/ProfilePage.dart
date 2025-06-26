import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'PaymentScreen.dart';
import 'UserInformationScreen.dart';
import '../Setting/SettingScreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Loading...';
  String imageUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null || userId.isEmpty) {
        setState(() {
          name = 'Chưa đăng nhập';
          isLoading = false;
        });
        debugPrint('SharedPreferences không có user_id hoặc user_id rỗng');
        return;
      }

      final url = Uri.parse('http://192.168.0.108:8000/api/users/detail/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API response: $data');

        final rawName = data['name'];
        final rawImage = data['image'];

        setState(() {
          name = rawName is String ? rawName : 'Không có tên';
          imageUrl = (rawImage is String && rawImage.isNotEmpty)
              ? (rawImage.startsWith('http')
              ? rawImage
              : 'http://172.20.10.8:8000/storage/$rawImage')
              : '';
          isLoading = false;
        });
      } else {
        debugPrint('Lỗi từ server: ${response.statusCode}');
        setState(() {
          name = 'Lỗi dữ liệu';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Exception: $e');
      setState(() {
        name = 'Lỗi kết nối';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEBDDF4), Color(0xFF9FEFF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? const Text(
                        'Ảnh',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuButton(Icons.edit, 'Chỉnh sửa thông tin người dùng', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserInformationScreen()),
            );
          }),
          _buildMenuButton(Icons.description, 'Điều khoản & Chính sách', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }),
          _buildMenuButton(Icons.support_agent, 'Hỗ trợ', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }),
          _buildMenuButton(Icons.payment, 'Thanh toán', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
