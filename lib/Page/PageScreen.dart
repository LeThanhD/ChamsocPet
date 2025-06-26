import 'package:flutter/material.dart';
import 'package:chamsocpet/Profile/ProfilePage.dart';
import 'package:chamsocpet/Quản Lý/ManageScreen.dart';
import '../Appointment/AppointmentPage.dart';
import '../Hieuung/AnimalEffect.dart';
import '../Notification/NotificationScreen.dart';
import '../Page/ServicePackageScreen.dart';
import '../Profile/PaymentScreen.dart';
import '../madicene/MedicinePage.dart';

class PageScreen extends StatefulWidget {
  const PageScreen({super.key});

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomeContent(),
    AppointmentPage(appointmentData: {}),
    const ManageScreen(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // 👈 Nhận cả vùng trống
      onTapDown: (details) {
        AnimalEffect.show(context, details.globalPosition);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(index: currentIndex, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFFF3E1F9),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black,
          currentIndex: currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch hẹn'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Quản lý'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEBDDF4), Color(0xFF9FEFF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/anhAvatar.png'), // ảnh đại diện
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: [
                    _iconSquare(context, Icons.medication, 'Thuốc', Colors.lightBlue, MedicinePage()),
                    _iconSquare(context, Icons.miscellaneous_services, 'Dịch vụ', Colors.pinkAccent, const ServicePackageScreen()),
                    _iconSquare(context, Icons.notifications, 'Thông báo', Colors.amber, const NotificationScreen()),
                    _iconSquare(context, Icons.payment, 'Thanh toán', Colors.green, const PaymentScreen()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconSquare(BuildContext context, IconData icon, String label, Color color, Widget targetPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage));
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
