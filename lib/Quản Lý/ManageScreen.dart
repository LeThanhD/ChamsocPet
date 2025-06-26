import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AddPetScreen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreen();
}

class _ManageScreen extends State<ManageScreen> {
  List<dynamic> pets = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserAndFetchPets();
  }

  // Tải user_id từ SharedPreferences và gọi API để lấy danh sách pet
  Future<void> loadUserAndFetchPets() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');

    if (userId != null && userId!.isNotEmpty) {
      fetchPets();
    } else {
      debugPrint('Không tìm thấy user_id trong SharedPreferences');
      setState(() {
        pets = [];
      });
    }
  }

  // API để lấy danh sách pet của user hiện tại
  Future<void> fetchPets() async {
    final token = await _getToken();
    final uri = Uri.parse('http://192.168.0.108:8000/api/pets/user/$userId');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() {
        pets = decoded is List ? decoded : decoded['data'] ?? [];
      });
    } else {
      debugPrint('❌ Lỗi khi lấy danh sách thú cưng: ${response.body}');
      setState(() {
        pets = [];
      });
    }
  }

  // Lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Xóa pet
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

    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('http://192.168.0.108:8000/api/pets/$petId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xoá thú cưng")),
      );
      fetchPets(); // reload sau xoá
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPetScreen()),
          );
          if (result == 'added') {
            fetchPets(); // Reload danh sách thú cưng sau khi thêm
          }
        },
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }
}
