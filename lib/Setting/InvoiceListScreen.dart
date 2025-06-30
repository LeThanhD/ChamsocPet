import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  List<dynamic> invoices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvoices();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchInvoices() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/invoices'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      // Nếu response là {"data": [...]} thì bóc jsonBody['data']
      setState(() {
        invoices = jsonBody is Map ? jsonBody['data'] ?? [] : jsonBody;
        isLoading = false;
      });
    } else {
      print('Lỗi lấy hóa đơn: ${response.statusCode}');
      setState(() => isLoading = false);
    }
  }

  Widget buildInvoiceItem(Map<String, dynamic> invoice) {
    final createdAt = invoice['CreatedAt'] ?? invoice['created_at'] ?? '';
    final formattedDate = createdAt.toString().split('T').first;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('🐾 PetID: ${invoice['PetID']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🧾 Appointment: ${invoice['AppointmentID']}'),
            Text('💸 Dịch vụ: ${invoice['ServicePrice']} đ'),
            Text('💊 Thuốc: ${invoice['MedicineTotal']} đ'),
            Text('💰 Tổng cộng: ${invoice['TotalAmount']} đ'),
            Text('🗓 Ngày tạo: $formattedDate'),
          ],
        ),
        trailing: const Icon(Icons.receipt_long),
        onTap: () {
          // Có thể mở chi tiết hóa đơn ở đây nếu muốn
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📄 Danh sách hóa đơn'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : invoices.isEmpty
          ? const Center(child: Text('Không có hóa đơn nào'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: invoices.length,
        itemBuilder: (context, index) =>
            buildInvoiceItem(invoices[index]),
      ),
    );
  }
}
