import 'package:flutter/material.dart';
import 'package:chamsocpet/Profile/ProfilePage.dart';
import 'package:chamsocpet/Quản Lý/ManageScreen.dart';
import '../Appointment/AppointmentPage.dart';
import '../Notification/NotificationScreen.dart';
import '../Appointment/AppointmentScreen.dart';
import '../Page/ServicePackageScreen.dart';
import '../Quản Lý/PetScreen.dart';
import 'ContactScreen.dart';

class PageScreen extends StatefulWidget {
  const PageScreen({super.key});

  @override
  State<PageScreen> createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomeContent(),      // Trang chủ
    AppointmentPage(),        // Lịch hẹn
    ManageScreen(),           // Quản lý
    ProfilePage(),            // Cá nhân
  ];

  void _onItemTapped(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
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
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              color: const Color(0xFF9DDCF6),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm dịch vụ...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationScreen()),
                      );
                    },
                  )
                ],
              ),
            ),

            // Banner
            Container(
              margin: const EdgeInsets.all(12),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Icon Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _iconShortcut(context, Icons.catching_pokemon, 'Thú cưng', Color(0xFFB3E7F9), const PetScreen()),
                  _iconShortcut(context, Icons.pets, 'Gói dịch vụ', Color(0xFFF9AFC3), const ServicePackageScreen()),
                  _iconShortcut(context, Icons.call, 'Liên hệ', Color(0xFFF9ED6E), const ContactScreen()),
                  _iconShortcut(context, Icons.update, 'Lịch hẹn', Color(0xFFFBB17C), AppointmentScreen()),
                ],
              ),
            ),

            const Divider(height: 20),

            _sectionTitle('Dịch vụ gần bạn'),
            _horizontalServiceList(),

            _sectionTitle('Dịch vụ bạn đã sử dụng'),
            _horizontalServiceList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _iconShortcut(BuildContext context, IconData icon, String label, Color color, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.arrow_forward, size: 18, color: Colors.orange),
        ],
      ),
    );
  }

  Widget _horizontalServiceList() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Text(
                    'Dịch vụ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
