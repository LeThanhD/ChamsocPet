import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key, this.paymentData});
  final Map<String, dynamic>? paymentData;

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  List<Map<String, dynamic>> payments = [];
  bool isLoading = true;
  String? role;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    role = prefs.getString('role');

    if (userId == null || role == null) {
      showError("Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.");
      setState(() => isLoading = false);
      return;
    }

    final uri = Uri.parse("http://10.24.67.249:8000/api/payments?user_id=$userId&role=$role");

    try {
      final res = await http.get(uri, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          setState(() {
            payments = List<Map<String, dynamic>>.from(decoded);
          });
        } else {
          showError("Dữ liệu trả về không đúng:\n\n${res.body}");
        }
      } else {
        showError("Lỗi lấy danh sách:\n\n${res.body}");
      }
    } catch (e) {
      showError("Lỗi kết nối:\n\n$e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> approvePayment(String paymentId) async {
    final payment = payments.firstWhere((p) => p['PaymentID'].toString() == paymentId);
    final paidAmount = payment['PaidAmount'] ?? 0;
    final note = payment['Note'] ?? '';

    // Gửi yêu cầu duyệt
    final uri = Uri.parse("http://10.24.67.249:8000/api/payments/approve/$paymentId");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        final paymentUserId = data['payment']?['UserID'] ?? '';
        if (paymentUserId.isNotEmpty) {
          await sendNotificationAfterApproval(paymentId, paymentUserId, paidAmount, note);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "✅ Đã xác nhận thanh toán"),
            backgroundColor: Colors.green,
          ),
        );

        fetchPayments();
      } else {
        final isJson = res.headers['content-type']?.contains("application/json") ?? false;
        final msg = isJson
            ? jsonDecode(res.body)['message'] ?? 'Lỗi không xác định'
            : "Server trả về HTML hoặc định dạng không hợp lệ.";
        showError("❌ Không thể xác nhận (${res.statusCode}):\n\n$msg");
      }
    } catch (e) {
      showError("❌ Lỗi khi xác nhận:\n\n$e");
    }
  }

  Future<void> sendNotificationAfterApproval(String paymentId, String userId, dynamic amount, String note) async {
    final uri = Uri.parse("http://10.24.67.249:8000/api/notifications");

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "user_id": userId,
        "title": "Thanh toán đã được duyệt",
        "message": "Đơn thanh toán #$paymentId đã được xác nhận thành công.",
        "payment_id": paymentId,
        "action": "payment_approved",
        "note": note,
        "amount": amount
      }),
    );

    if (res.statusCode != 200) {
      print("⚠️ Gửi thông báo thất bại: ${res.body}");
    } else {
      print("📢 Gửi thông báo thành công.");
    }
  }




  String formatCurrency(dynamic amount) {
    try {
      if (amount is int || amount is double) {
        return NumberFormat("#,###", "vi_VN").format(amount) + " đ";
      }
      final parsed = double.tryParse(amount.toString()) ?? 0;
      return NumberFormat("#,###", "vi_VN").format(parsed) + " đ";
    } catch (_) {
      return "$amount đ";
    }
  }

  String formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  void showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("❌ Lỗi"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Duyệt thanh toán", style: TextStyle(color: Colors.black)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : payments.isEmpty
            ? const Center(child: Text("Không có thanh toán nào."))
            : RefreshIndicator(
          onRefresh: fetchPayments,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (_, index) {
              final payment = payments[index];
              final status = (payment['status'] ?? '').toString().toLowerCase();
              final isApproved = status == 'đã duyệt';
              final paidAmount = payment['PaidAmount'] ?? 0;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white.withOpacity(0.95),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("💳 Mã: ${payment['PaymentID'] ?? ''}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("💰 Số tiền: ${formatCurrency(paidAmount)}"),
                      Text("📝 Ghi chú: ${payment['Note'] ?? ''}"),
                      Text("📅 Thời gian: ${formatDateTime(payment['PaymentTime'])}"),
                      Text(
                        "📌 Trạng thái: ${isApproved ? 'Đã duyệt' : 'Chờ duyệt'}",
                        style: TextStyle(
                          color: isApproved ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!isApproved && role == 'staff')
                        ElevatedButton.icon(
                          onPressed: () => approvePayment(payment['PaymentID'].toString()),
                          icon: const Icon(Icons.check),
                          label: const Text("Duyệt thanh toán"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      if (isApproved)
                        const Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green),
                            SizedBox(width: 6),
                            Text("Đã duyệt", style: TextStyle(color: Colors.green)),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}