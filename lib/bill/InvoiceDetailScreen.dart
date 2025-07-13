import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../pay/PaymentScreen.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  Map<String, dynamic>? invoice;
  bool isLoading = true;
  String? userRole;
  bool isPaid = false;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    fetchInvoiceDetail();
    checkIfPaid(); // gọi API kiểm tra đã thanh toán
  }

  Future<void> fetchUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('role') ?? '';
    });
  }

  Future<void> fetchInvoiceDetail() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.108:8000/api/invoices/${widget.invoiceId}'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        invoice = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> checkIfPaid() async {
    final uri = Uri.parse('http://192.168.0.108:8000/api/payments/check-paid?invoice_id=${widget.invoiceId}');
    final response = await http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List && data.isNotEmpty) {
        setState(() => isPaid = true);
      }
    }
  }

  String getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ duyệt';
      case 'approved':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  Widget buildInfoTile(String title, String value, {IconData? icon}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: icon != null ? Icon(icon, color: Colors.deepPurple) : null,
      title: Text(title),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medicines = (invoice?['medications'] ?? []) as List;
    final status = invoice?['Status']?.toString().toLowerCase() ?? '';

    final isButtonDisabled = isPaid || status == 'chờ duyệt' || status == 'đã duyệt';
    final buttonLabel = isPaid
        ? 'Hóa đơn đã thanh toán'
        : (status == 'chờ duyệt'
        ? 'Hóa đơn đang chờ duyệt'
        : (status == 'đã duyệt' ? 'Hóa đơn đã được duyệt' : 'Tiếp tục thanh toán'));

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0BBF9), Color(0xFFA7F0F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0BBF9), Color(0xFFA7F0F9)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('Chi tiết hóa đơn', style: TextStyle(color: Colors.black)),
              iconTheme: const IconThemeData(color: Colors.black),
              centerTitle: true,
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : invoice == null
            ? const Center(child: Text('Hóa đơn không tồn tại'))
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              color: Colors.white.withOpacity(0.95),
              child: Column(
                children: [
                  buildInfoTile('Mã hóa đơn', invoice!['InvoiceID'], icon: Icons.receipt),
                  buildInfoTile(
                    'Ngày tạo',
                    (invoice!['CreatedAt'] ?? '').toString().split('T').first,
                    icon: Icons.date_range,
                  ),
                  buildInfoTile('Tên thú cưng', invoice!['name'] ?? 'Không rõ', icon: Icons.pets),
                  buildInfoTile('Mã lịch hẹn', invoice!['AppointmentID']),
                  buildInfoTile('Tổng tiền', '${invoice!['TotalAmount']} đ', icon: Icons.payments),
                  buildInfoTile('Trạng thái', getDisplayStatus(status), icon: Icons.info_outline),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              color: Colors.white.withOpacity(0.95),
              child: Column(
                children: [
                  buildInfoTile('Dịch vụ', '${invoice!['ServicePrice']} đ',
                      icon: Icons.medical_services),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.medication, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text('Thuốc sử dụng',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    medicines.isEmpty
                        ? const Text('Không có thuốc nào')
                        : ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: medicines.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final m = medicines[index];
                        final name = m['Name'] ?? m['name'] ?? 'Không rõ';
                        final quantity = m['Quantity'] ?? 0;
                        final price = m['Price'] ?? 0;
                        final total = quantity * price;

                        return ListTile(
                          title: Text(name),
                          subtitle: Text('Số lượng: $quantity x $price đ'),
                          trailing: Text('$total đ',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (userRole != 'staff')
              ElevatedButton.icon(
                onPressed: isButtonDisabled
                    ? null
                    : () {
                  final rawAmount = invoice!['TotalAmount'];
                  final amountParsed =
                      double.tryParse(rawAmount.toString())?.round() ?? 0;
                  final invoiceId = invoice!['InvoiceID'].toString();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MomoPaymentScreen(
                        amount: amountParsed,
                        invoiceId: invoiceId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.payment),
                label: Text(buttonLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent.shade100,
                  foregroundColor: Colors.black87,
                  shadowColor: Colors.deepPurple,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
