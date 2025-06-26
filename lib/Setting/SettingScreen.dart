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
      appBar: AppBar(
        title: const Text("Cài đặt", style: TextStyle(color: Colors.black)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Không gọi lại ProfilePage
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                buildSwitchTile("Màn hình sáng tối", darkMode, (val) {
                  setState(() => darkMode = val);
                }),
                buildNavTile("Đổi mật khẩu", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  );
                }),
                buildSwitchTile("Thông báo", notifications, (val) {
                  setState(() => notifications = val);
                }),
                buildNavTile("Lịch sử thú cưng đã điều trị", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MedicalHistoryScreen()),
                  );
                }),
                buildNavTile("Thay đổi tài khoản", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SwitchAccountScreen()),
                  );
                }),
                buildSwitchTile("Trạng thái hoạt động", activeStatus, (val) {
                  setState(() => activeStatus = val);
                }),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE36C1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // TODO: xử lý đăng xuất tại đây
                },
                child: const Text(
                  'ĐĂNG XUẤT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        activeColor: Colors.blue,
        onChanged: onChanged,
      ),
    );
  }

  Widget buildNavTile(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
