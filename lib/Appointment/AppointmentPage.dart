import 'package:chamsocpet/Appointment/AppointmentScreen.dart';
import 'package:chamsocpet/Page/PageScreen.dart';
import 'package:flutter/material.dart';

import '../Profile/ProfilePage.dart';
import '../Quản Lý/ManageScreen.dart';


class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
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
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => AppointmentPage()),
        // );
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
      appBar: AppBar(
        title: const Text("Lịch hẹn", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow("Người phụ trách:", "Thành"),
                _infoRow("Tên người đặt hẹn:", "Mai"),
                _infoRow("Ngày đặt hẹn:", "03/07/2025"),
                _infoRow("Giờ hẹn:", "14:00 a.m"),
                _infoRow("Dịch vụ yêu cầu:", "Tắm Sấy, Spa và Cắt Tỉa"),
                _infoRow("Ghi chú:", "chăm sóc thú cưng dùm tui"),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Huỷ lịch",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AppointmentScreen()),
          );
        },
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _infoRow(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: '$title ',
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: content,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
