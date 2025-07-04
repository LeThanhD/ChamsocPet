import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['created_at'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';

    if (userId.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/notifications?UserID=$userId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];

      setState(() {
        notifications = data.map((e) => NotificationModel.fromJson(e)).toList();
        isLoading = false;
      });
    } else {
      print('❌ Lỗi lấy dữ liệu: ${response.body}');
      setState(() => isLoading = false);
    }
  }

  Future<void> markAsRead(String id) async {
    await http.put(
      Uri.parse('http://192.168.0.108:8000/api/notifications/$id/read'),
      headers: {'Accept': 'application/json'},
    );
    fetchNotifications();
  }

  Future<void> deleteNotification(String id) async {
    final res = await http.delete(
      Uri.parse('http://192.168.0.108:8000/api/notifications/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      setState(() {
        notifications.removeWhere((e) => e.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã xóa thông báo')),
      );
    } else {
      print('❌ Xóa thất bại: ${res.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text('Không có thông báo'))
          : RefreshIndicator(
        onRefresh: fetchNotifications,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: notifications.length,
          itemBuilder: (_, index) {
            final noti = notifications[index];
            return Card(
              color: noti.isRead ? Colors.grey[200] : Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.teal),
                title: Text(noti.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(noti.message),
                    const SizedBox(height: 6),
                    Text(noti.createdAt.substring(0, 16),
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                onTap: () => markAsRead(noti.id),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Xác nhận'),
                        content: const Text('Bạn muốn xóa thông báo này?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
                        ],
                      ),
                    );
                    if (confirm == true) deleteNotification(noti.id);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
