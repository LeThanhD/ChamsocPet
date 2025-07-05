import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'InvoiceDetailScreen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  List<dynamic> invoices = [];
  bool isLoading = true;
  String? role;
  String? userId;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  String? searchQuery;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    fetchInvoices();
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');
    userId = prefs.getString('user_id');

    String baseUrl = role == 'staff'
        ? 'http://10.24.67.249:8000/api/invoices?role=staff'
        : 'http://10.24.67.249:8000/api/invoices?user_id=$userId&role=user';

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      baseUrl += '&search=${Uri.encodeComponent(searchQuery!)}';
    }

    final uri = Uri.parse(baseUrl);
    final response = await http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      setState(() {
        invoices = jsonBody is Map ? jsonBody['data'] ?? [] : jsonBody;
        isLoading = false;
      });
    } else {
      print('❌ Lỗi lấy hóa đơn: ${response.statusCode}');
      setState(() => isLoading = false);
    }
  }

  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = value;
        isLoading = true;
      });
      fetchInvoices();
    });
  }

  Widget buildInvoiceItem(Map<String, dynamic> invoice) {
    final createdAt = invoice['CreatedAt'] ?? invoice['created_at'] ?? '';
    final formattedDate = createdAt.toString().split('T').first;
    final status = invoice['status']?.toString().toLowerCase() ?? 'unknown';

    Color backgroundColor;
    switch (status) {
      case 'pending':
        backgroundColor = Colors.yellow.shade100;
        break;
      case 'approved':
        backgroundColor = Colors.green.shade100;
        break;
      case 'rejected':
        backgroundColor = Colors.red.shade100;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          '🐶 Tên thú cưng: ${invoice['name'] ?? 'Không rõ'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🧾 Mã lịch hẹn: ${invoice['AppointmentID']}'),
              Text('💸 Dịch vụ: ${invoice['ServicePrice']} đ'),
              Text('💊 Thuốc: ${invoice['MedicineTotal']} đ'),
              Text('💰 Tổng cộng: ${invoice['TotalAmount']} đ'),
              Text('🗓 Ngày tạo: $formattedDate'),
              Text('📌 Trạng thái: $status'),
            ],
          ),
        ),
        trailing: const Icon(Icons.receipt_long, color: Colors.teal),
        onTap: () {
          final invoiceId = invoice['InvoiceID']?.toString() ?? '';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceDetailScreen(invoiceId: invoiceId),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0BBF9), Color(0xFFA7F0F9)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: isSearching
                      ? TextField(
                    controller: searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Tìm hóa đơn...',
                      hintStyle: TextStyle(color: Colors.black54),
                      border: InputBorder.none,
                    ),
                    onChanged: onSearchChanged,
                  )
                      : const Center(
                    child: Text(
                      "Hóa đơn",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.black87),
                  onPressed: () {
                    setState(() {
                      if (isSearching) {
                        searchController.clear();
                        searchQuery = null;
                        isLoading = true;
                        fetchInvoices();
                      }
                      isSearching = !isSearching;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : invoices.isEmpty
                ? const Center(child: Text('Không có hóa đơn nào'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: invoices.length,
              itemBuilder: (context, index) => buildInvoiceItem(invoices[index]),
            ),
          ),
        ],
      ),
    );
  }
}
