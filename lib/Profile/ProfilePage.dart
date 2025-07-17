import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Appointment/AppointmentHistory.dart';
import '../QuenMk/quenMatKhau.dart';
import '../Statistics/StatisticsScreen.dart';
import '../bill/InvoiceListScreen.dart';
import '../pay/AdminApprovalScreen.dart';
import '../user/ManagementUserTotalAmount.dart';
import '../user/UserManagementScreen.dart';
import 'UserInformationScreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Đang tải...';
  String imageUrl = '';
  String userRole = '';
  bool isLoading = true;
  Map<String, dynamic>? statistics;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();

    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (!mounted) return;
      print('🔁 Auto-refresh ProfilePage...');
      await fetchUserInfo(); // Gọi lại cả user info và statistics nếu là staff
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // <-- huỷ timer
    super.dispose();
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
        final roleFromAPI = data['role']?.toString().toLowerCase() ?? '';

        setState(() {
          name = data['name'] ?? 'Không rõ';
          userRole = roleFromAPI;
          imageUrl = rawImage.startsWith('http')
              ? rawImage
              : 'http://192.168.0.108:8000/storage/$rawImage';
          isLoading = false;
        });

        if (roleFromAPI == 'staff') {
          fetchStatistics();
        }
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

  Future<void> fetchStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.108:8000/api/users/statistics/TotalAmount/human'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          statistics = data;
        });
      }
    } catch (e) {
      print('❌ Lỗi thống kê: $e');
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
                if (userRole == 'staff' && statistics != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManagementUserTotalAmount()),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('📊 Thống kê tháng này',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Text('💰 Tổng thu: ${statistics!['total_income']} VND',
                                style: const TextStyle(fontSize: 16)),
                            Text('👤 Người dùng hoàn tất: ${statistics!['completed_users']} người',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                _buildMenuTile(
                  icon: Icons.person_outline,
                  title: 'Chỉnh sửa thông tin',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UserInformationScreen()));
                  },
                ),
                _buildMenuTile(
                  icon: Icons.lock_outline,
                  title: 'Đổi mật khẩu',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                  },
                ),
                if (userRole != 'doctor')
                _buildMenuTile(
                  icon: Icons.history,
                  title: 'Lịch sử lịch hẹn',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentHistoryPage()));
                  },
                ),
                if (userRole != 'doctor')
                _buildMenuTile(
                  icon: Icons.receipt_long,
                  title: 'Hóa đơn',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceListScreen()));
                  },
                ),
                if (userRole == 'staff')
                  _buildMenuTile(
                    icon: Icons.bar_chart,
                    title: 'Xem thống kê chi tiết',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                      );
                    },
                  ),
                if (userRole == 'staff' && userRole != 'doctor') ...[
                  _buildMenuTile(
                    icon: Icons.admin_panel_settings,
                    title: 'Duyệt thanh toán',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminApprovalScreen()));
                    },
                  ),

                  _buildMenuTile(
                    icon: Icons.group,
                    title: 'Quản lý người dùng',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen()));
                    },
                  ),
                ] else if (userRole == 'owner' && userRole != 'doctor')
                  _buildMenuTile(
                    icon: Icons.payment,
                    title: 'Thanh toán hóa đơn',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminApprovalScreen()));
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
