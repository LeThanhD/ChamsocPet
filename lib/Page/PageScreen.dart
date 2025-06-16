import 'package:chamsocpet/Profile/ProfilePage.dart';
import 'package:chamsocpet/Qu%E1%BA%A3n%20L%C3%BD/ManageScreen.dart';
import 'package:flutter/material.dart';

import '../Appointment/AppointmentPage.dart';
import '../Appointment/AppointmentScreen.dart';
import '../Notification/NotificationScreen.dart';
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

  void _onItemTapped(int index) {
    setState(() => currentIndex = index);

    switch (index) {
      case 0:
      // Trang chủ - ở lại
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PetScreen()),
                        );
                      },
                      child: _iconButton(Icons.catching_pokemon, 'Thú cưng', Color(0xFFB3E7F9)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ServicePackageScreen()),
                        );
                      },
                      child: _iconButton(Icons.pets, 'Gói dịch vụ', Color(0xFFF9AFC3)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ContactScreen()),
                        );
                      },
                      child: _iconButton(Icons.call, 'Liên hệ', Color(0xFFF9ED6E)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AppointmentScreen()),
                        );
                      },
                      child: _iconButton(Icons.update, 'Lịch hẹn', Color(0xFFFBB17C)),
                    ),
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

  Widget _iconButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
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
