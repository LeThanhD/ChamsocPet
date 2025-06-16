import 'package:chamsocpet/Setting/SettingScreen.dart';
import 'package:flutter/material.dart';

class SwitchAccountScreen extends StatelessWidget {
  const SwitchAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Thay đổi tài khoản",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );},
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tài khoản chính
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text("Peter", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.sync, color: Colors.black),
                  onPressed: () {
                    // Xử lý cập nhật tài khoản nếu cần
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Thêm tài khoản
            TextButton(
              onPressed: () {},
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.add, color: Colors.black),
                  ),
                  SizedBox(width: 12),
                  Text("Thêm tài khoản", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const Spacer(),
            // Nút chuyển đổi
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                ),
                onPressed: () {
                  // Xử lý chuyển tài khoản
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã chuyển tài khoản")),
                  );
                },
                child: const Text(
                  "Chuyển đổi",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
