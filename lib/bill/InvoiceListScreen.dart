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

  String formatCurrency(dynamic amount) {
    final parsed = double.tryParse(amount.toString()) ?? 0.0;
    return parsed.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.',
    );
  }

  String getDisplayStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
      case 'chưa duyệt':
      case 'Chưa thanh toán':
        return 'Chờ duyệt';
      case 'approved':
      case 'đã duyệt':
        return 'Đã duyệt';
      case 'rejected':
      case 'bị từ chối':
        return 'Từ chối';
      case 'paid':
      case 'đã thanh toán':
        return 'Đã thanh toán';
      default:
        return status ?? 'Không rõ';
    }
  }

  Future<void> fetchInvoices() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');
    userId = prefs.getString('user_id');

    if (role == null) {
      print('❌ Role chưa xác định');
      setState(() => isLoading = false);
      return;
    }

    String baseUrl;
    if (role == 'staff') {
      baseUrl = 'http://192.168.0.108:8000/api/invoices?role=staff';
    } else {
      if (userId == null) {
        print('❌ UserID chưa xác định');
        setState(() => isLoading = false);
        return;
      }
      baseUrl = 'http://192.168.0.108:8000/api/invoices?user_id=$userId&role=user';
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      baseUrl += '&search=${Uri.encodeComponent(searchQuery!)}';
    }

    try {
      final uri = Uri.parse(baseUrl);
      final response = await http.get(uri, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final dataList = jsonBody is Map && jsonBody.containsKey('data')
            ? jsonBody['data']
            : jsonBody;

        setState(() {
          invoices = List<dynamic>.from(dataList);
          isLoading = false;
        });
      } else {
        print('❌ Lỗi lấy hóa đơn: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Exception khi lấy hóa đơn: $e');
      setState(() => isLoading = false);
    }
  }

  void onSearchChanged(String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = value.trim();
      });
      fetchInvoices();
    });
  }

  Color _getStatusColor(String? status) {
    final normalized = status?.trim().toLowerCase(); // ✅ Loại bỏ khoảng trắng

    switch (normalized) {
      case 'pending':
      case 'chờ duyệt':
      case 'Chưa thanh toán':
        return Colors.yellow.shade100;
      case 'approved':
      case 'đã duyệt':
        return Colors.green.shade100;
      case 'rejected':
      case 'bị từ chối':
        return Colors.red.shade100;
      default:
        print("⚠️ Không nhận diện được status: $status"); // debug
        return Colors.grey.shade200;
    }
  }

  Widget buildInvoiceItem(Map<String, dynamic> invoice) {
    final createdAt = invoice['CreatedAt'] ?? invoice['created_at'] ?? '';
    final formattedDate = createdAt.toString().split('T').first;
    final status = invoice['Status'] ?? invoice['status'] ?? 'unknown';
    final promotionNote = invoice['Note'] ?? invoice['note'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
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
              Text('🧾 Mã lịch hẹn: ${invoice['AppointmentID'] ?? 'N/A'}'),
              Text('💸 Dịch vụ: ${formatCurrency(invoice['ServicePrice'])} đ'),
              Text('💊 Thuốc: ${formatCurrency(invoice['MedicineTotal'])} đ'),
              if (promotionNote != null && promotionNote.toString().isNotEmpty) ...[
                Text('💰 Tổng cộng (sau giảm): ${formatCurrency(invoice['TotalAmount'])} đ'),
                Text('🎁 Khuyến mãi: $promotionNote', style: const TextStyle(color: Colors.green)),
              ] else ...[
                Text('💰 Tổng cộng: ${formatCurrency(invoice['TotalAmount'])} đ'),
              ],
              Text('🗓 Ngày tạo: $formattedDate'),
              Text('📌 Trạng thái: ${getDisplayStatus(status)}'),
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
