import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AppointmentScreen.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key, required this.appointmentData});
  final Map<String, dynamic> appointmentData;

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    if (widget.appointmentData.isNotEmpty &&
        !appointments.any((a) => a['AppointmentID'] == widget.appointmentData['AppointmentID'])) {
      appointments.add(widget.appointmentData);
    }
    await fetchAppointments();
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> fetchAppointments() async {
    final userId = await _getUserId();
    if (userId == null) {
      print('❌ Không có user ID.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.108:8000/api/appointments/all?UserID=$userId'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'] ?? [];

        setState(() {
          for (var item in data) {
            final mapItem = Map<String, dynamic>.from(item);
            if (!appointments.any((a) => a['AppointmentID'] == mapItem['AppointmentID'])) {
              appointments.add(mapItem);
            }
          }
        });
      } else {
        print('❌ Fetch failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hủy lịch')),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await http.delete(
        Uri.parse('http://192.168.0.108:8000/api/appointments/$appointmentId'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          appointments.removeWhere((a) => a['AppointmentID'] == appointmentId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hủy lịch hẹn thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xóa lịch hẹn thất bại: ${response.reasonPhrase}')),
        );
      }
    }
  }

  Future<void> navigateToNewAppointment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        appointments.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEBDDF8), Color(0xFF9FF3F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: const [
                  Spacer(),
                  Text(
                    'Lịch hẹn',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  SizedBox(width: 48),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: appointments.isEmpty
                  ? const Center(
                child: Text(
                  'Chưa có lịch hẹn nào.',
                  style: TextStyle(color: Colors.black87, fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  final status = appointment['Status'] ?? 'Chưa có trạng thái';
                  final userName = appointment['user']?['FullName'] ?? 'Không có tên khách hàng';
                  final petName = appointment['pet']?['Name'] ?? 'Không có tên thú cưng';
                  final serviceName = appointment['service']?['ServiceName'] ?? 'Không có tên dịch vụ';

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Khách hàng: $userName'),
                            Text('Thú cưng: $petName'),
                            Text('Ngày: ${appointment['AppointmentDate'] ?? ''}'),
                            Text('Giờ: ${appointment['AppointmentTime'] ?? ''}'),
                            Text('Dịch vụ: $serviceName'),
                            Text('Ghi chú: ${appointment['Reason'] ?? ''}'),
                            const SizedBox(height: 8),
                            Text(
                              'Trạng thái: $status',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              deleteAppointment(appointment['AppointmentID']);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToNewAppointment,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
