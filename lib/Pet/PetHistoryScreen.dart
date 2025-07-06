import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PetHistoryScreen extends StatefulWidget {
  final String petId;
  const PetHistoryScreen({Key? key, required this.petId}) : super(key: key);

  @override
  State<PetHistoryScreen> createState() => _PetHistoryScreenState();
}

class _PetHistoryScreenState extends State<PetHistoryScreen> {
  bool isLoading = true;
  List<dynamic> medications = [];
  List<dynamic> services = [];
  String? error;
  String? message;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final url = Uri.parse('http://192.168.0.108:8000/api/pets/${widget.petId}/used-services-medications');
    try {
      final res = await http.get(url, headers: {'Accept': 'application/json'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          message = data['message'] ?? '';
          medications = data['medications'] ?? [];
          services = data['services'] ?? [];
          isLoading = false;
          error = null;
        });
      } else {
        setState(() {
          error = 'Lỗi tải dữ liệu lịch sử (code ${res.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  Widget buildListSection(String title, List<dynamic> items, String emptyMessage) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 12),
        ...items.map((item) {
          final name = item['Name'] ?? item['ServiceName'] ?? 'Không rõ tên';
          final date = item['Date'] ?? item['UsedAt'] ?? '';
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: title.contains('thuốc') ? Colors.deepPurple.shade100 : Colors.blue.shade100,
                child: Icon(
                  title.contains('thuốc') ? Icons.medical_services : Icons.medical_services,
                  color: title.contains('thuốc') ? Colors.deepPurple : Colors.blue,
                  size: 28,
                ),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: date.isNotEmpty ? Text(date, style: const TextStyle(color: Colors.black54)) : null,
              // Bỏ trailing icon mũi tên
              onTap: () {
                // Optional: xử lý khi bấm vào item
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Lịch sử thuốc & dịch vụ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : error != null
          ? Center(child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 18)))
          : RefreshIndicator(
        onRefresh: fetchHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message != null && message!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(message!, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                ),
              buildListSection('Thuốc đã sử dụng', medications, 'Chưa có lịch sử thuốc'),
              const SizedBox(height: 28),
              buildListSection('Dịch vụ đã sử dụng', services, 'Chưa có lịch sử dịch vụ'),
            ],
          ),
        ),
      ),
    );
  }
}
