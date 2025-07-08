import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserTotalAmountScreen extends StatefulWidget {
  final String userId;
  final String fullName;

  const UserTotalAmountScreen({
    super.key,
    required this.userId,
    required this.fullName,
  });

  @override
  State<UserTotalAmountScreen> createState() => _UserTotalAmountScreenState();
}

class _UserTotalAmountScreenState extends State<UserTotalAmountScreen> {
  List<dynamic> payments = [];
  bool isLoading = true;
  double totalPaid = 0;

  @override
  void initState() {
    super.initState();
    fetchUserDetail();
  }

  Future<void> fetchUserDetail() async {
    final url = Uri.parse('http://192.168.0.108:8000/api/users/payment/history/total/Amount/${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final List<dynamic> fetchedPayments = jsonBody['payments'] ?? [];

        double sum = 0;
        for (var item in fetchedPayments) {
          sum += double.tryParse(item['paid_amount'].toString()) ?? 0;
        }

        setState(() {
          payments = fetchedPayments;
          totalPaid = sum;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user detail');
      }
    } catch (e) {
      print('❌ Lỗi khi tải chi tiết người dùng: $e');
      setState(() => isLoading = false);
    }
  }

  Widget buildInvoiceCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFE7EAFB), Color(0xFFD4F3F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🧾 Mã hóa đơn: ${item['invoice_id']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('🐾 Pet ID: ${item['pet_id']}'),
            Text('🕒 Ngày thanh toán: ${item['payment_time']}'),
            Text('💰 Số tiền: ${item['paid_amount']} VND'),
            if ((item['services'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('🛠 Dịch vụ đã dùng:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...List<Widget>.from(
                (item['services'] as List).map((s) => Text('- $s')),
              ),
            ],
            if ((item['medicines'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('💊 Thuốc đã sử dụng:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...List<Widget>.from(
                (item['medicines'] as List).map((m) => Text('- $m')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
        backgroundColor: const Color(0xFFB4D2F7),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F5FF), Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('👤 Tên: ${widget.fullName}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('💰 Tổng tiền đã thanh toán: ${totalPaid.toStringAsFixed(0)} VND',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('🧾 Danh sách hóa đơn:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, index) =>
                      buildInvoiceCard(payments[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
