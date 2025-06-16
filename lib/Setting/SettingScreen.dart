import 'package:chamsocpet/Profile/ProfilePage.dart';
import 'package:chamsocpet/Setting/MedicalHistoryScreen.dart';
import 'package:flutter/material.dart';

import 'ChangePasswordScreen.dart';
import 'SwitchAccountScreen.dart';


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
      body: Column(
        children: [
          // Gradient Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCCBFFF), Color(0xFF47D7E9)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()), // Thay thế bằng màn hình bạn muốn chuyển tới
                    );
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Cài đặt',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // để cân đối icon back
              ],
            ),

          ),

          // Setting items
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

          // Đăng xuất Button
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
                onPressed: () {},
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
