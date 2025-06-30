import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'AppointmentHistory.dart';
import 'AppointmentScreen.dart';
import 'AppointmentDetailPage.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key, required this.appointmentData});
  final Map<String, dynamic> appointmentData;

  @override
  AppointmentPageState createState() => AppointmentPageState();
}

class AppointmentPageState extends State<AppointmentPage> {
  List<Map<String, dynamic>> appointments = [];
  String? role;
  String? userId;
  bool isLoading = false;
  bool isSearching = false;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserAndFetchAppointments();
  }

  Future<void> loadUserAndFetchAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
    role = prefs.getString('role');

    if (widget.appointmentData.isNotEmpty &&
        !appointments.any((a) => a['AppointmentID'] == widget.appointmentData['AppointmentID'])) {
      appointments.add(widget.appointmentData);
    }

    await fetchAppointments();
  }

  Future<void> fetchAppointments({String query = ''}) async {
    setState(() => isLoading = true);
    String url;

    if (role == 'staff') {
      url = 'http://192.168.0.108:8000/api/appointments/every?role=staff';
      if (query.isNotEmpty) url += '&search=$query';
    } else {
      url = 'http://192.168.0.108:8000/api/appointments/all?UserID=$userId';
      if (query.isNotEmpty) url += '&search=$query';
    }

    try {
      final response = await http.get(Uri.parse(url), headers: {'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'] ?? [];
        setState(() {
          appointments = data
              .cast<Map<String, dynamic>>()
              .where((a) => a['Status'] != 'Kết thúc')
              .toList();
        });
      } else {
        print('❌ Fetch failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveToHistory(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList('history_appointments') ?? [];
    current.add(jsonEncode(item));
    await prefs.setStringList('history_appointments', current);
  }

  Future<void> createNotification(String userId, String title, String message) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('http://192.168.0.108:8000/api/notifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'message': message,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('❌ Gửi thông báo thất bại: ${response.body}');
    }
  }

  Future<void> updateStatus(String appointmentId, String status) async {
    setState(() => isLoading = true);

    try {
      final appointment = appointments.firstWhere(
            (a) => a['AppointmentID'] == appointmentId,
        orElse: () => {},
      );

      final response = await http.put(
        Uri.parse('http://192.168.0.108:8000/api/appointments/update-status/$appointmentId'),
        headers: {'Accept': 'application/json'},
        body: {'Status': status},
      );

      if (response.statusCode == 200) {
        if (status == 'Đã duyệt' && appointment.isNotEmpty) {
          await createNotification(
            appointment['UserID'].toString(),
            'Lịch hẹn đã được duyệt',
            'Cuộc hẹn ngày ${appointment['AppointmentDate']} đã được xác nhận.',
          );
        }

        if (status == 'Kết thúc') {
          try {
            final detailRes = await http.get(
              Uri.parse('http://192.168.0.108:8000/api/appointments/$appointmentId'),
              headers: {'Accept': 'application/json'},
            );

            if (detailRes.statusCode == 200) {
              final fullData = jsonDecode(detailRes.body)['data'];
              await saveToHistory(fullData);
              await createNotification(
                fullData['UserID'].toString(),
                'Lịch hẹn đã hoàn thành',
                'Kính mời quý khách đến nhận thú cưng trong thời gian sớm nhất.',
              );
            } else if (appointment.isNotEmpty) {
              await saveToHistory(appointment);
              await createNotification(
                appointment['UserID'].toString(),
                'Lịch hẹn đã hoàn thành',
                'Kính mời quý khách đến nhận thú cưng trong thời gian sớm nhất.',
              );
            }
          } catch (e) {
            print('❌ Lỗi khi lưu lịch sử: $e');
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AppointmentHistoryPage()),
          );
        }

        await fetchAppointments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cập nhật trạng thái thành công')),
        );
      } else {
        print('❌ Cập nhật trạng thái thất bại: ${response.body}');
      }
    } catch (e) {
      print('❌ Lỗi khi cập nhật trạng thái: $e');
    }

    setState(() => isLoading = false);
  }

  Widget statusActions(String current, String id) {
    final Map<String, List<String>> next = {
      'Chưa duyệt': ['Đã duyệt'],
      'Đã duyệt': ['Kết thúc'],
    };

    return next[current] != null
        ? Row(
      children: next[current]!
          .map(
            (s) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => updateStatus(id, s),
            child: Text(s, style: const TextStyle(color: Colors.white)),
          ),
        ),
      )
          .toList(),
    )
        : const SizedBox();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Kết thúc':
        return Colors.green;
      case 'Đã duyệt':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isSearching) {
          setState(() {
            isSearching = false;
            searchController.clear();
            fetchAppointments();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEBDDF8), Color(0xFF9FF3F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          title: isSearching
              ? TextField(
            controller: searchController,
            autofocus: true,
            onChanged: (value) => fetchAppointments(query: value),
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              hintText: 'Tìm thú cưng hoặc dịch vụ...',
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
            ),
          )
              : const Text(
            'Lịch hẹn',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    searchController.clear();
                    fetchAppointments();
                  }
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (isLoading) const LinearProgressIndicator(),
            Expanded(
              child: appointments.isEmpty
                  ? const Center(child: Text('Chưa có lịch hẹn nào.', style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  final status = appt['Status'] ?? 'Chưa có trạng thái';
                  final userName = appt['user']?['FullName'] ?? 'Không có tên khách hàng';
                  final staffName = appt['staff']?['FullName'] ?? appt['staff']?['name'] ?? 'Không có nhân viên phụ trách';
                  final petName = appt['pet']?['Name'] ?? 'Không có tên thú cưng';
                  final serviceName = appt['service']?['ServiceName'] ?? 'Không có tên dịch vụ';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppointmentDetailPage(appointment: appt),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.pets, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$petName (${appt['AppointmentDate'] ?? ''} - ${appt['AppointmentTime'] ?? ''})',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('👤 Khách hàng: $userName'),
                          Text('👨‍🔧 Nhân viên: $staffName'),
                          Text('🛠️ Dịch vụ: $serviceName'),
                          if (appt['Reason'] != null && appt['Reason'].toString().isNotEmpty)
                            Text('📝 Ghi chú: ${appt['Reason']}'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: getStatusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: getStatusColor(status)),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (role == 'staff') statusActions(status, appt['AppointmentID']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: role == 'staff'
            ? null
            : FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AppointmentScreen()),
            );
            if (result == true) {
              await fetchAppointments();
            }
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
