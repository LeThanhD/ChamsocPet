import 'package:chamsocpet/bill/InvoiceListScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chamsocpet/Profile/ProfilePage.dart';
import 'package:chamsocpet/Pet/ManageScreen.dart';
import '../Appointment/AppointmentPage.dart';
import '../Appointment/AppointmentScreen.dart';
import '../Hieuung/AnimalEffect.dart';
import '../Notification/NotificationScreen.dart';
import '../Service/ServicePackageScreen.dart';
import '../pay/PaymentScreen.dart';
import '../madicene/MedicinePage.dart';

class PageScreen extends StatefulWidget {
  const PageScreen({super.key});

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  int currentIndex = 0;

  final GlobalKey<AppointmentPageState> _appointmentKey = GlobalKey();

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomeContent(),
      AppointmentPage(key: _appointmentKey, appointmentData: {}),
      const ManageScreen(),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => currentIndex = index);
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
        body: IndexedStack(index: currentIndex, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFFF3E1F9),
          selectedItemColor: Colors.deepPurple,
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
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))],
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
    );
  }

  Widget _menuCard(BuildContext context, IconData icon, String label, Color color, Widget? page, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {
        if (page != null) Navigator.push(context, MaterialPageRoute(builder: (_) => page));
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
