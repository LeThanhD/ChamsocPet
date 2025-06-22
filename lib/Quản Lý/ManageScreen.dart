// phần đầu giữ nguyên như cũ
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'AddPetScreen.dart';
import '../Appointment/AppointmentPage.dart';
import '../Page/PageScreen.dart';
import '../Profile/ProfilePage.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreen();
}

class _ManageScreen extends State<ManageScreen> {
  int currentIndex = 2;
  List<dynamic> pets = [];
  final String userId = 'OWNER0001';

  @override
  void initState() {
    super.initState();
    fetchPets();
  }

  Future<void> fetchPets() async {
    final uri = Uri.parse('http://192.168.0.108:8000/api/pets?UserID=$userId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      setState(() {
        pets = jsonDecode(response.body);
      });
    } else {
      print('Lỗi khi lấy danh sách thú cưng: ${response.body}');
    }
  }

  Future<void> deletePet(String petId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xoá thú cưng này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xoá')),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await http.delete(
      Uri.parse('http://192.168.0.108:8000/api/pets/$petId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // rất quan trọng
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xoá thú cưng")),
      );
      fetchPets();
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Lỗi"),
          content: Text("Xoá thất bại: ${response.body}"),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() => currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PageScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppointmentPage()));
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilePage()));
        break;
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
      body: pets.isEmpty
          ? const Center(child: Text("Chưa có thú cưng nào"))
          : ListView.builder(
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(pet['Name'] ?? ''),
              subtitle: Text('${pet['Species'] ?? ''} - ${pet['Breed'] ?? ''}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deletePet(pet['PetID']),
              ),
            ),
          );
        },
      ),
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
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch hẹn'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Quản lý'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
