import 'package:flutter/material.dart';
import 'ChangePasswordScreen.dart';
import 'SwitchAccountScreen.dart';
import '../Setting/MedicalHistoryScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = true;
  bool notifications = true;
  bool activeStatus = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("⚙️ Cài đặt", style: TextStyle(color: Colors.black)),
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
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDEFF9), Color(0xFFD1F4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildSectionTitle("Giao diện & Hệ thống"),
                      _buildSwitchTile("🌙 Chế độ tối", darkMode, (val) {
                        setState(() => darkMode = val);
                      }),
                      _buildSwitchTile("🔔 Thông báo", notifications, (val) {
                        setState(() => notifications = val);
                      }),
                      _buildSwitchTile("🟢 Trạng thái hoạt động", activeStatus, (val) {
                        setState(() => activeStatus = val);
                      }),
                      const SizedBox(height: 12),
                      _buildSectionTitle("Tài khoản & Dữ liệu"),
                      _buildNavTile("🔐 Đổi mật khẩu", onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                        );
                      }),
                      _buildNavTile("📋 Lịch sử thú cưng điều trị", onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MedicalHistoryScreen()),
                        );
                      }),
                      _buildNavTile("👥 Chuyển tài khoản", onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SwitchAccountScreen()),
                        );
                      }),
                    ],
                  ),
                ),

                // Logout button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'ĐĂNG XUẤT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE36C1A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // TODO: xử lý đăng xuất
                      },
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

  // ===== Custom Widgets =====

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title),
        trailing: Switch(
          value: value,
          activeColor: Colors.deepPurpleAccent,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNavTile(String title, {VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
