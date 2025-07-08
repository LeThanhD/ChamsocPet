import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class DeleteAppointmentPage extends StatefulWidget {
  final String appointmentId;
  final String appointmentStatus;
  final String userRole; // 👈 phân quyền theo vai trò: staff, admin, owner

  const DeleteAppointmentPage({
    Key? key,
    required this.appointmentId,
    required this.appointmentStatus,
    required this.userRole,
  }) : super(key: key);

  @override
  _DeleteAppointmentPageState createState() => _DeleteAppointmentPageState();
}

class _DeleteAppointmentPageState extends State<DeleteAppointmentPage> {
  String reason = '';
  TextEditingController _otherReasonController = TextEditingController();
  String? fcmToken;
  String? role;

  bool get canDelete {
    final blockedStatuses = [
      'Chờ khám',
      'Đang khám',
      'Hoàn tất dịch vụ',
      'Chờ thêm thuốc',
      'Kết thúc',
    ];
    return !blockedStatuses.contains(widget.appointmentStatus);
  }

  List<String> get userReasons => [
    'Không cần hẹn nữa',
    'Đổi dịch vụ',
    'Không đáp ứng yêu cầu của tôi',
    'Khác',
  ];

  List<String> get staffReasons => [
    'Khách không đến',
    'Nhân viên bạn hẹn có việc đột xuất',
    'Hệ thống lỗi',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        fcmToken = token;
      });
      print("FCM Token: $fcmToken");
    });
  }

  Future<void> sendNotification(String reason) async {
    if (fcmToken == null) return;

    final response = await http.post(
      Uri.parse('http://192.168.0.108:8000/notifications/send/${widget.appointmentId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fcm_token': fcmToken,
        'title': 'Lịch hẹn đã bị xóa',
        'message': 'Lý do: $reason',
      }),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  Future<void> deleteAppointment(String reason) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.0.108:8000/api/appointments/${widget.appointmentId}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lịch hẹn đã bị xóa thành công')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Xóa lịch hẹn thất bại');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👇 Chỉ staff và admin được xem lý do nhân viên
    final isStaff = widget.userRole == 'staff';
    final reasons = isStaff ? staffReasons : userReasons;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lý do xóa lịch hẹn'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isStaff
                    ? 'Chọn lý do từ phía nhân viên:'
                    : 'Chọn lý do từ phía khách hàng:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 10),
              ...reasons.map(
                    (option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: reason,
                  onChanged: (value) {
                    setState(() {
                      reason = value!;
                      if (reason != 'Khác') {
                        _otherReasonController.clear();
                      }
                    });
                  },
                ),
              ),
              if (reason == 'Khác')
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextField(
                    controller: _otherReasonController,
                    decoration: const InputDecoration(
                      labelText: 'Nhập lý do cụ thể',
                      labelStyle: TextStyle(color: Colors.pink),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink, width: 2),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if (canDelete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Quay lại',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (reason.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng chọn lý do')),
                          );
                          return;
                        }

                        if (reason == 'Khác' && _otherReasonController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng nhập lý do cụ thể')),
                          );
                          return;
                        }

                        String finalReason = reason == 'Khác'
                            ? _otherReasonController.text.trim()
                            : reason;

                        await deleteAppointment(finalReason);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Xóa lịch hẹn',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
