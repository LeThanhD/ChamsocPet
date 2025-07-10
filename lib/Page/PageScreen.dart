import 'dart:convert';
import 'package:chamsocpet/bill/InvoiceListScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'package:chamsocpet/Profile/ProfilePage.dart';
import 'package:chamsocpet/Pet/ManageScreen.dart';
import '../Appointment/AppointmentPage.dart';
import '../Hieuung/AnimalEffect.dart';
import '../Notification/NotificationScreen.dart';
import '../Service/ServicePackageScreen.dart';
import '../madicene/MedicinePage.dart';

class PageScreen extends StatefulWidget {
  const PageScreen({super.key});

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  int currentIndex = 0;
  int unseenCount = 0;
  String? staffId;
  String? role;

  final GlobalKey<AppointmentPageState> _appointmentKey = GlobalKey<AppointmentPageState>();
  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    staffId = prefs.getString('user_id');
    role = prefs.getString('role');

    // ✅ Tùy vai trò tạo danh sách trang
    if (role == 'doctor') {
      pages = [
        AppointmentPage(key: _appointmentKey),
        const ProfilePage(), // ✅ Thay vì ManageScreen
      ];
    } else {
      pages = [
        HomeContent(),
        AppointmentPage(key: _appointmentKey),
        const ManageScreen(),
        const ProfilePage(),
      ];
    }

    setState(() {});
    loadUnseenCount();
  }

  Future<void> loadUnseenCount() async {
    if (staffId != null) {
      int count = await fetchUnseenCount(staffId!);
      setState(() => unseenCount = count);
    }
  }

  void _onItemTapped(int index) async {
    setState(() => currentIndex = index);
    if (index == (role == 'doctor' ? 0 : 1)) {
      await loadUnseenCount();
    }
  }

  Future<int> fetchUnseenCount(String staffId) async {
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/appointments/unseen/count?staff_id=$staffId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['unseen_count'] ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        AnimalEffect.show(context, details.globalPosition);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: pages.isNotEmpty
            ? IndexedStack(index: currentIndex, children: pages)
            : const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFFF3E1F9),
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.black,
          currentIndex: currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: role == 'doctor'
              ? [
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.calendar_today),
                  if (unseenCount > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          unseenCount > 9 ? '9+' : unseenCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Lịch hẹn',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          ]
              : [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.calendar_today),
                  if (unseenCount > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          unseenCount > 9 ? '9+' : unseenCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Lịch hẹn',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Quản lý'),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEBDDF4), Color(0xFF9FEFF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/anhAvatar.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    children: [
                      _menuCard(context, Icons.medication, 'Thuốc', Colors.lightBlue, MedicinePage()),
                      _menuCard(context, Icons.soap, 'Dịch vụ', Colors.pinkAccent, const ServicePackageScreen()),
                      _menuCard(context, Icons.notifications, 'Thông báo', Colors.orange, const NotificationScreen()),
                      _menuCard(context, Icons.inventory_outlined, 'Hóa đơn', Colors.green, const InvoiceListScreen()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, IconData icon, String label, Color color, Widget page,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
