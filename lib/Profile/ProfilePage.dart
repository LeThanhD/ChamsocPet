import 'package:chamsocpet/Profile/PaymentScreen.dart';
import 'package:chamsocpet/Profile/PetHistoryScreen.dart';
import 'package:chamsocpet/Profile/ShoppingCartScreen.dart';
import 'package:chamsocpet/Profile/UserInformationScreen.dart';
import 'package:chamsocpet/Setting/SettingScreen.dart';
import 'package:flutter/material.dart';

import '../Appointment/AppointmentPage.dart';
import '../Page/PageScreen.dart';
import '../Quản Lý/ManageScreen.dart';
import 'EditProfileScreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}
class _ProfilePage extends State<ProfilePage> {
  int currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() => currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PageScreen()),
        );
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AppointmentPage()),
        );
      case 2:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ManageScreen()),
      );
      case 3:
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => ProfilePage()),
        // );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            color: Color(0xFF9DDCF6), // màu xanh nhạt
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + Name
                // Avatar + Name
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      child: Text('Chọn ảnh', style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    const Text('Hello', style: TextStyle(fontSize: 50, color: Colors.white)),
                  ],
                ),

                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()), // Thay thế bằng màn hình bạn muốn chuyển tới
                    );
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShoppingCartScreen()), // Thay thế bằng màn hình bạn muốn chuyển tới
                    );
                  },
                ),
              ],
            ),
          ),

          // Overview
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Column(
                  children: [
                    Text('2', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Thú cưng đang khám'),
                  ],
                ),
                Column(
                  children: [
                    Text('15', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Số lần đến khám'),
                  ],
                ),
              ],
            ),
          ),

          // Balanced Buttons
          _buildMenuButton(Icons.edit, 'Chỉnh sửa thông tin người dùng', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UserInformationScreen()));
          }),
          _buildMenuButton(Icons.description, 'Điều khoản & Chính sách', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
          _buildMenuButton(Icons.support_agent, 'Hỗ trợ', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
          _buildMenuButton(Icons.history, 'Lịch sử quản lý thú cưng', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PetHistoryScreen()));
          }),
          _buildMenuButton(Icons.payment, 'Thanh toán', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen()));
          }),

        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF3E1F9),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch hẹn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Quản lý',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String title, {VoidCallback? onTap}) {
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
