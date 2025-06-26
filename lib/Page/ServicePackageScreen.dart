import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ================= Model =================
class ServiceItem {
  final String id;
  final String title;
  final int price;
  final String category;

  ServiceItem({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['ServiceID'].toString(),
      title: json['ServiceName'] ?? 'Chưa có tên',
      price: (json['Price'] is int)
          ? json['Price']
          : double.tryParse(json['Price'].toString())?.toInt() ?? 0,
      category: json['CategoryID'] ?? 'Unknown',
    );
  }
}

// ================= UI =================
class ServicePackageScreen extends StatefulWidget {
  const ServicePackageScreen({super.key});

  @override
  State<ServicePackageScreen> createState() => _ServicePackageScreenState();
}

class _ServicePackageScreenState extends State<ServicePackageScreen> {
  late Future<List<ServiceItem>> allServices;

  @override
  void initState() {
    super.initState();
    allServices = fetchAllServices();
  }

  Future<List<ServiceItem>> fetchAllServices() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/services'),
      headers: {
        'Accept': 'application/json',
      },
    );

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // Truy cập đúng vào danh sách dịch vụ nằm ở: decoded['data']['data']
      if (decoded is Map &&
          decoded.containsKey('data') &&
          decoded['data'] is Map &&
          decoded['data'].containsKey('data')) {
        final List<dynamic> dataList = decoded['data']['data'];
        return dataList.map((e) => ServiceItem.fromJson(e)).toList();
      } else {
        throw Exception("Phản hồi API không có key 'data.data'");
      }
    } else {
      throw Exception('Không thể tải dịch vụ từ API');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Các gói dịch vụ", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.black),
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
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ServiceItem>>(
              future: allServices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi tải dịch vụ: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu'));
                }

                final services = snapshot.data!;
                final dogServices = services
                    .where((s) => s.category.toUpperCase() == 'DOG')
                    .toList();
                final catServices = services
                    .where((s) => s.category.toUpperCase() == 'CAT')
                    .toList();

                return ListView(
                  children: [
                    if (dogServices.isNotEmpty) ...[
                      _buildCategoryTitle("🐶 Dịch vụ dành cho chó"),
                      ...dogServices.map(_buildItem),
                    ],
                    if (catServices.isNotEmpty) ...[
                      const Divider(thickness: 8),
                      _buildCategoryTitle("🐱 Dịch vụ dành cho mèo"),
                      ...catServices.map(_buildItem),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildItem(ServiceItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text("${_formatCurrency(item.price)}đ",
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
