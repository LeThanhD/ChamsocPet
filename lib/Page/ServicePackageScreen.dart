import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ServiceItem {
  final String title;
  final int price;
  final String category;

  ServiceItem({
    required this.title,
    required this.price,
    required this.category,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      title: json['ServiceName'],
      price: (json['Price'] is int)
          ? json['Price']
          : double.parse(json['Price'].toString()).toInt(),
      category: json['CategoryID'],
    );
  }
}

class ServicePackageScreen extends StatefulWidget {
  const ServicePackageScreen({super.key});

  @override
  State<ServicePackageScreen> createState() => _ServicePackageScreenState();
}

class _ServicePackageScreenState extends State<ServicePackageScreen> {
  int totalPrice = 0;
  late Future<List<ServiceItem>> allServices;

  @override
  void initState() {
    super.initState();
    allServices = fetchAllServices();
  }

  Future<List<ServiceItem>> fetchAllServices() async {
    final response = await http.get(Uri.parse('http://192.168.0.108:8000/api/services'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // Nếu Laravel trả về kiểu { "data": [...] }
      final List<dynamic> data = decoded is List ? decoded : decoded['data'];

      return data.map((e) => ServiceItem.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải dịch vụ từ API');
    }
  }


  void addToCart(int price) {
    setState(() {
      totalPrice += price;
    });
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
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu'));
                }

                final services = snapshot.data!;
                final dogServices = services.where((s) => s.category == 'DOG').toList();
                final catServices = services.where((s) => s.category == 'CAT').toList();

                return ListView(
                  children: [
                    _buildCategoryTitle("🐶 Dịch vụ dành cho chó"),
                    ...dogServices.map(_buildItem),

                    const Divider(thickness: 8),
                    _buildCategoryTitle("🐱 Dịch vụ dành cho mèo"),
                    ...catServices.map(_buildItem),
                  ],
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey)),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Tổng thanh toán\n${_formatCurrency(totalPrice)} VND",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: () {
                    // Chuyển sang giỏ hàng
                  },
                  child: const Text("Xem giỏ hàng"),
                ),
              ],
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
          // Container(width: 60, height: 60, color: Colors.grey[300]),
          // const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text("${_formatCurrency(item.price)}đ",
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => addToCart(item.price),
            icon: const Icon(Icons.add_circle_outline, color: Colors.deepOrange),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
