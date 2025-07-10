import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AddPetScreen.dart';
import 'PetSecondScreen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreen();
}

class _ManageScreen extends State<ManageScreen> {
  List<dynamic> pets = [];
  String? userId;
  String? role;
  String searchText = '';
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserAndFetchPets();
  }

  Future<void> loadUserAndFetchPets() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
    role = prefs.getString('role');

    if (userId != null && userId!.isNotEmpty) {
      await fetchPets();
    } else {
      debugPrint('Không tìm thấy user_id trong SharedPreferences');
      setState(() => pets = []);
    }
  }

  Future<void> fetchPets({String query = ''}) async {
    final token = await _getToken();
    Uri uri;

    if (role == 'staff' || role == 'doctor') {
      uri = Uri.parse(
          'http://192.168.0.108:8000/api/pets/all?role=staff${query.isNotEmpty ? '&search=$query' : ''}');
    } else {
      uri = Uri.parse(
          'http://192.168.0.108:8000/api/pets/user/$userId${query.isNotEmpty ? '?search=$query' : ''}');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() {
        pets = decoded is List ? decoded : decoded['data'] ?? [];
      });
    } else {
      debugPrint('❌ Lỗi khi lấy danh sách thú cưng: ${response.body}');
      setState(() => pets = []);
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> deletePet(String petId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('Xác nhận xoá'),
          ],
        ),
        content: const Text('Bạn có chắc muốn xoá thú cưng này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    final response = await http.delete(
      Uri.parse('http://192.168.0.108:8000/api/pets/$petId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'user_id': userId}),
    );

    final decoded = jsonDecode(response.body);
    final errorMsg = decoded['message'] ?? 'Xảy ra lỗi không xác định';

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Đã xoá thú cưng thành công")),
      );
      await fetchPets();
    } else {
      if (errorMsg.toLowerCase().contains('đã bị xoá') ||
          errorMsg.toLowerCase().contains('không thể xoá')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      } else {
        // Hiển thị dialog nhẹ nhàng
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                const SizedBox(height: 12),
                Text(
                  errorMsg,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.deepPurple, // màu chữ cho nút Hủy
                ),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,    // màu nền nút Xoá
                  foregroundColor: Colors.black,         // màu chữ trắng
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Xoá'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEBDDF8), Color(0xFF9FF3F9)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          title: isSearching
              ? TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Tìm theo tên thú cưng...',
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.black),
            onChanged: (value) => fetchPets(query: value),
          )
              : const Text('Quản lý thú cưng', style: TextStyle(color: Colors.black)),
          actions: [
            IconButton(
              icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    searchController.clear();
                    fetchPets();
                  }
                });
              },
            )
          ],
        ),
      ),
      body: pets.isEmpty
          ? const Center(child: Text("Chưa có thú cưng nào"))
          : ListView.builder(
        itemCount: pets.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemBuilder: (context, index) {
          final pet = pets[index];
          final ownerName = ((role == 'staff' || role == 'doctor') && pet['user'] != null)
              ? pet['user']['FullName'] ?? 'Không rõ'
              : null;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.pets, color: Colors.white),
              ),
              title: Text(
                pet['Name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${pet['Species'] ?? ''} - ${pet['Breed'] ?? ''}'),
                  if (ownerName != null)
                    Text('Chủ: $ownerName',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              trailing: (role != 'staff' && role != 'doctor')
                  ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => deletePet(pet['PetID']),
              )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PetDetailScreen(petId: pet['PetID']),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton:(role == 'staff' || role == 'doctor')
          ? null
          : FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPetScreen()),
          );
          if (result == 'added') {
            final prefs = await SharedPreferences.getInstance();
            role = prefs.getString('role');
            await fetchPets();
          }
        },
        backgroundColor: Colors.deepPurpleAccent,
        icon: const Icon(Icons.add, color: Colors.white, size: 30),
        label: const Text(
          'Thêm thú cưng',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
