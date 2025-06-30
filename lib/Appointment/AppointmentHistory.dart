import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'AppointmentDetailPage.dart';

class AppointmentHistoryPage extends StatefulWidget {
  const AppointmentHistoryPage({super.key});

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage> {
  List<dynamic> historyAppointments = [];
  String? role;
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistoryFromAPI();
  }

  Future<void> fetchHistoryFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');
    userId = prefs.getString('user_id');

    String url = role == 'staff'
        ? 'http://192.168.0.108:8000/api/appointment-history/all'
        : 'http://192.168.0.108:8000/api/appointment-history?UserID=$userId';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          historyAppointments = decoded['data'];
          isLoading = false;
        });
      } else {
        print('❌ Lỗi tải lịch sử: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Exception: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE6DFFF), Color(0xFFB2F6FD)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Lịch sử hẹn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyAppointments.isEmpty
          ? const Center(child: Text('Không có lịch sử hẹn nào.'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: historyAppointments.length,
        itemBuilder: (context, index) {
          final item = historyAppointments[index];
          final appointment = item['appointment'] ?? {};
          final user = appointment['user'] ?? {};
          final pet = appointment['pet'] ?? {};
          final service = appointment['service'] ?? {};
          final staff = appointment['staff'] ?? {};

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AppointmentDetailPage(appointment: appointment),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE1F5FE), Color(0xFFF3E5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👤 Chủ: ${user['FullName'] ?? 'Không rõ'}',
                    style:
                    const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('🐾 Thú cưng: ${pet['Name'] ?? 'Không rõ'}'),
                  const SizedBox(height: 4),
                  Text(
                      '📅 Ngày: ${appointment['AppointmentDate'] ?? ''}'),
                  Text(
                      '🕒 Giờ: ${appointment['AppointmentTime'] ?? ''}'),
                  Text(
                      '🧴 Dịch vụ: ${service['ServiceName'] ?? 'Không có'}'),
                  Text(
                    '👨‍🔧 Nhân viên: ${staff['FullName'] ?? staff['name'] ?? 'Không rõ'}',
                  ),
                  Text(
                    '📝 Ghi chú: ${appointment['Reason'] ?? 'Không có'}',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
