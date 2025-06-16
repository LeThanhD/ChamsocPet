import 'package:chamsocpet/Qu%E1%BA%A3n%20L%C3%BD/AddPetScreen.dart';
import 'package:flutter/material.dart';

import '../Appointment/AppointmentPage.dart';
import '../Page/PageScreen.dart';
import '../Profile/ProfilePage.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});
  @override
  State<ManageScreen> createState() => _ManageScreen();
}
class _ManageScreen extends State<ManageScreen> {
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
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => ManageScreen()),
        // );
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Quản lý', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          actions: [

          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEBDDF8), Color(0xFF9FF3F9)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Container(), // Nội dung chính trống như ảnh
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade300,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddPetScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black, size: 30),
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
