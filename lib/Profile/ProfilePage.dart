import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Appointment/AppointmentHistory.dart';
import '../Setting/InvoiceListScreen.dart';
import 'PaymentScreen.dart';
import 'UserInformationScreen.dart';
import '../Setting/SettingScreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Đang tải...';
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
      final userId = prefs.getString('user_id') ?? '';
      if (userId.isEmpty) {
        setState(() {
          name = 'Chưa đăng nhập';
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse('http://192.168.0.108:8000/api/users/detail/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawImage = data['image'] ?? '';
        setState(() {
          name = data['name'] ?? 'Không rõ';
          imageUrl = rawImage.startsWith('http')
              ? rawImage
              : 'http://192.168.0.108:8000/storage/$rawImage';
          isLoading = false;
        });
      } else {
        setState(() {
          name = 'Lỗi tải dữ liệu';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        name = 'Lỗi kết nối';
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      await http.post(Uri.parse('http://192.168.0.108:8000/api/logout'), headers: {
        'Accept': 'application/json',
      });
    } catch (_) {}

    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 26),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16),
              children: [
                _buildMenuTile(
                  icon: Icons.person_outline,
                  title: 'Chỉnh sửa thông tin',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserInformationScreen()));
                  },
                ),
                _buildMenuTile(
                  icon: Icons.history,
                  title: 'Lịch sử lịch hẹn',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentHistoryPage()));
                  },
                ),
                _buildMenuTile(
                  icon: Icons.receipt_long,
                  title: 'Hóa đơn',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceListScreen()));
                  },
                ),
                _buildMenuTile(
                  icon: Icons.payment,
                  title: 'Thanh toán',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen()));
                  },
                ),
                _buildMenuTile(
                  icon: Icons.privacy_tip,
                  title: 'Điều khoản & Chính sách',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
                _buildMenuTile(
                  icon: Icons.help_outline,
                  title: 'Hỗ trợ',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.black),
                label: const Text('Đăng xuất', style: TextStyle(color: Colors.black, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: logout,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
