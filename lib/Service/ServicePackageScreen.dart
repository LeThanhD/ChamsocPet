import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AddServiceScreen.dart';
import 'ServiceDetailScreen.dart';

class ServiceItem {
  final String id;
  final String title;
  final int price;
  final String category;
  final String description;

  ServiceItem({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['ServiceID'].toString(),
      title: json['ServiceName'] ?? 'Chưa có tên',
      price: (json['Price'] is int)
          ? json['Price']
          : double.tryParse(json['Price'].toString())?.toInt() ?? 0,
      category: json['CategoryID'] ?? 'Unknown',
      description: json['Description'] ?? '',
    );
  }
}

class ServicePackageScreen extends StatefulWidget {
  const ServicePackageScreen({super.key});

  @override
  State<ServicePackageScreen> createState() => _ServicePackageScreenState();
}

class _ServicePackageScreenState extends State<ServicePackageScreen> {
  late Future<List<ServiceItem>> allServices;
  bool isStaff = false;
  String searchQuery = "";
  bool isSearching = false;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRole();
    allServices = fetchAllServices();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isStaff = prefs.getString('role') == 'staff';
    });
  }

  Future<List<ServiceItem>> fetchAllServices({String query = ""}) async {
    final uri = Uri.parse(
        'http://192.168.0.108:8000/api/services${query.isNotEmpty ? "?search=$query" : ""}');
    final response =
    await http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['data'] is Map && decoded['data']['data'] is List) {
        final List<dynamic> dataList = decoded['data']['data'];
        return dataList.map((e) => ServiceItem.fromJson(e)).toList();
      } else {
        throw Exception("Dữ liệu không hợp lệ");
      }
    } else {
      throw Exception("Lỗi server");
    }
  }

  void _onSearch(String value) {
    setState(() {
      searchQuery = value;
      allServices = fetchAllServices(query: searchQuery);
    });
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchQuery = "";
        searchController.clear();
        allServices = fetchAllServices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: isSearching
            ? TextField(
          controller: searchController,
          autofocus: true,
          onChanged: _onSearch,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm dịch vụ...',
            hintStyle: TextStyle(color: Colors.black45),
            border: InputBorder.none,
          ),
        )
            : const Text("📦 Các gói dịch vụ",
            style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            color: Colors.black,
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFDEFF9), Color(0xFFD1F4FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDEFF9), Color(0xFFD1F4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 16),
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
                  final dogServices = services
                      .where((s) => s.category.toUpperCase() == 'DOG')
                      .toList();
                  final catServices = services
                      .where((s) => s.category.toUpperCase() == 'CAT')
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    children: [
                      if (dogServices.isNotEmpty) ...[
                        _buildCategoryTitle("🐶 Dịch vụ dành cho chó"),
                        ...dogServices.map(_buildServiceCard),
                      ],
                      if (catServices.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildCategoryTitle("🐱 Dịch vụ dành cho mèo"),
                        ...catServices.map(_buildServiceCard),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isStaff
          ? FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddServiceScreen()),
          );
          if (result == 'refresh') {
            setState(() {
              allServices = fetchAllServices();
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildServiceCard(ServiceItem item) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: item)),
        );
        if (result == 'refresh') {
          setState(() {
            allServices = fetchAllServices();
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                "${_formatCurrency(item.price)} đ",
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.description,
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    );
  }
}
