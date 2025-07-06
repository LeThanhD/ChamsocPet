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
      backgroundColor: const Color(0xFFF2F3F5),
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
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Lịch sử hẹn',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
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
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: historyAppointments.length,
        itemBuilder: (context, index) {
          final item = historyAppointments[index];
          final appointment = item['appointment'] ?? {};
          final user = appointment['user'] ?? {};
          final pet = appointment['pet'] ?? {};
          final staff = appointment['staff'] ?? {};
          final services = appointment['services'];

          String serviceNames;
          try {
            if (services is List) {
              serviceNames = services.map((s) => s['ServiceName'] ?? '').join(', ');
            } else if (services is Map) {
              serviceNames = services['ServiceName'] ?? '';
            } else {
              serviceNames = 'Không rõ dịch vụ';
            }
          } catch (e) {
            print('❌ Lỗi parse services: $e');
            serviceNames = 'Không rõ dịch vụ';
          }

          return ListTile(
            tileColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AppointmentDetailPage(appointment: appointment),
                ),
              );
            },
            title: Text(
              '${pet['Name'] ?? 'Không rõ'} - $serviceNames',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('👤 Chủ: ${user['FullName'] ?? 'Không rõ'}'),
                Text('📅 Ngày: ${appointment['AppointmentDate'] ?? ''}'),
                Text('🕒 Giờ: ${appointment['AppointmentTime'] ?? ''}'),
                Text('👨‍🔧 Nhân viên: ${staff['FullName'] ?? staff['name'] ?? 'Không rõ'}'),
                if ((appointment['Reason'] ?? '').toString().isNotEmpty)
                  Text('📝 Ghi chú: ${appointment['Reason']}'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          );
        },
      )
    );
  }
}
