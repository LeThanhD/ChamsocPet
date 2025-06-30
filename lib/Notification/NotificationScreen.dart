import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chamsocpet/Page/PageScreen.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'],
      message: json['message'],
      createdAt: json['created_at'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';

      if (userId.isEmpty) {
        print("❌ Thiếu UserID trong local storage");
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.0.108:8000/api/notifications?UserID=$userId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded['data'] ?? [];

        setState(() {
          notifications = data.map((item) => NotificationModel.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        print("❌ Lỗi API: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.0.108:8000/api/notifications/$id/read'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        await fetchNotifications();
      } else {
        print("❌ Lỗi đánh dấu đã đọc: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception khi đánh dấu đã đọc: $e");
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.0.108:8000/api/notifications/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications.removeWhere((noti) => noti.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã xóa thông báo')),
        );
      } else {
        print("❌ Lỗi xóa thông báo: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception khi xóa thông báo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông báo", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PageScreen()),
            );
          },
        ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text("Không có thông báo"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final noti = notifications[index];
          return InkWell(
            onTap: () => markAsRead(noti.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: noti.isRead ? Colors.grey[300] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notifications, color: Colors.teal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noti.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(noti.message),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              noti.createdAt.substring(0, 10),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: const Text('Bạn muốn xóa thông báo này?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        deleteNotification(noti.id);
                      }
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
