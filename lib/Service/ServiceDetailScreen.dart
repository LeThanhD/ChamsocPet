import 'package:flutter/material.dart';
import 'ServicePackageScreen.dart';
import 'EditServiceScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceItem service;

  const ServiceDetailScreen({Key? key, required this.service}) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool isStaff = false;
  late ServiceItem currentService;

  @override
  void initState() {
    super.initState();
    currentService = widget.service;
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isStaff = prefs.getString('role') == 'staff';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Chi tiết dịch vụ"),
        centerTitle: true,
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE1F5FE), Color(0xFFF3E5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            Icon(Icons.soap, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              currentService.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "${_formatCurrency(currentService.price)} đ",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Mô tả dịch vụ:",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                currentService.description,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            const Spacer(),
            if (isStaff)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditServiceScreen(service: currentService),
                      ),
                    );
                    if (result is ServiceItem) {
                      setState(() {
                        currentService = result;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ Đã cập nhật dịch vụ")),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Chỉnh sửa dịch vụ"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
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
