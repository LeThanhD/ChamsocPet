import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  Map<String, dynamic>? user;
  List<dynamic> pets = [];
  List<dynamic> services = [];
  List<dynamic> medicines = [];
  bool isLoading = true;

  final Color backgroundColor = const Color(0xFFFDF6FB);
  final Color gradientStart = const Color(0xFFEFD4F5);
  final Color gradientEnd = const Color(0xFF83F1F5);
  final Color textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> fetchUserDetails() async {
    final url = Uri.parse('http://192.168.0.108:8000/api/users/full/${widget.userId}/detail');

    try {
      final response = await http.get(url, headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response Data: $data');  // Log dữ liệu trả về để kiểm tra
        setState(() {
          user = data['user'];
          pets = data['pets'] ?? [];
          services = data['services'] ?? [];
          medicines = data['medicines'] ?? [];
          isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  AppBar _buildGradientAppBar(String title) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user!['FullName'] ?? '',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 10),
            _infoRow(Icons.email, 'Email', user!['Email']),
            _infoRow(Icons.cake, 'Ngày sinh', formatDate(user!['BirthDate'])),
            _infoRow(Icons.phone, 'SĐT', user!['Phone']),
            _infoRow(Icons.person, 'Giới tính', user!['Gender'] == "1" ? "Nam" : "Nữ"),
            _infoRow(Icons.location_on, 'Địa chỉ', user!['Address']),
            _infoRow(Icons.assignment_ind, 'CCCD', user!['NationalID']),
            _infoRow(Icons.verified_user, 'Trạng thái', user!['Status']),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: ${value ?? 'Chưa có'}',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(List items, String Function(dynamic) builder) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Không có dữ liệu.', style: TextStyle(color: Colors.grey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: items.map((item) {
          return Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.black),
              title: Text(builder(item), style: const TextStyle(color: Colors.black)),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildGradientAppBar("Chi tiết người dùng"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text('Không tìm thấy người dùng.'))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Thông tin người dùng"),
            _buildUserInfoCard(),
            const Divider(thickness: 1),
            _buildSectionTitle("Danh sách thú cưng"),
            _buildItemCard(pets, (pet) =>
            '${pet['PetName']} - ${pet['Species']} - ${pet['Gender'] == '1' ? 'Đực' : 'Cái'}'),
            const Divider(thickness: 1),
            // _buildSectionTitle("Dịch vụ đã sử dụng"),
            // _buildItemCard(services, (s) =>
            // '${s['ServiceName']} (${formatDate(s['Date'])})'),
            // const Divider(thickness: 1),
            // _buildSectionTitle("Thuốc đã sử dụng"),
            // _buildItemCard(medicines, (m) =>
            // '${m['MedicineName']} (${formatDate(m['Date'])})'),
            // const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
