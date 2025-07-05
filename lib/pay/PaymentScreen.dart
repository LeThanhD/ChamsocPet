import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AdminApprovalScreen.dart';

class MomoPaymentScreen extends StatefulWidget {
  final dynamic amount;
  final String invoiceId;

  const MomoPaymentScreen({
    super.key,
    required this.amount,
    required this.invoiceId,
  });

  @override
  State<MomoPaymentScreen> createState() => _MomoPaymentScreenState();
}

class _MomoPaymentScreenState extends State<MomoPaymentScreen> {
  String? momoNumber, momoName, paymentNote, paymentUrl, paymentId;
  Map<String, dynamic>? createdPayment;
  bool isLoading = true;
  late int parsedAmount;

  @override
  void initState() {
    super.initState();
    parsedAmount = _parseAmount(widget.amount);
    createPayment();
  }

  int _parseAmount(dynamic rawAmount) {
    try {
      if (rawAmount is int) return rawAmount;
      if (rawAmount is double) return rawAmount.round();
      if (rawAmount is String) {
        final parsed = double.tryParse(rawAmount);
        return parsed?.round() ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  Future<void> createPayment() async {
    final uri = Uri.parse("http://10.24.67.249:8000/api/payments");
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      showError("Không tìm thấy user_id. Vui lòng đăng nhập lại.");
      return;
    }

    final body = {
      "amount": parsedAmount,
      "description": "Thanh toán qua MoMo",
      "invoice_id": widget.invoiceId,
      "user_id": userId,
    };

    try {
      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        setState(() {
          momoNumber = data['momo_number'] ?? '';
          momoName = data['momo_name'] ?? '';
          paymentNote = data['payment_note']?.toString() ?? '';
          paymentUrl = data['payment_url'];
          paymentId = data['payment']['PaymentID'].toString();
          createdPayment = data['payment'];
          isLoading = false;
        });
      } else {
        showError("Không thể tạo thanh toán:\n\n${res.body}");
      }
    } catch (e) {
      showError("Lỗi kết nối:\n\n$e");
    }
  }

  void gotoApprovalScreen() {
    if (createdPayment != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminApprovalScreen(paymentData: createdPayment),
        ),
      );
    } else {
      showError("❌ Chưa có dữ liệu thanh toán để duyệt.");
    }
  }

  void showError(String msg) {
    final decodedMsg = Uri.decodeFull(msg);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("❌ Lỗi"),
        content: SingleChildScrollView(child: Text(decodedMsg)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return "${formatter.format(amount)} đ";
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
              title: const Text("Thanh toán MoMo", style: TextStyle(color: Colors.black)),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildRow(Icons.attach_money, "Số tiền", formatCurrency(parsedAmount)),
                      const Divider(),
                      _buildRow(Icons.account_circle, "Tên người nhận", momoName),
                      const Divider(),
                      _buildRow(Icons.phone_android, "Số MoMo", momoNumber),
                      const Divider(),
                      _buildRow(Icons.edit_note, "Nội dung", paymentNote),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Image.asset(
                  'assets/img.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text("❌ Không thể tải ảnh QR"),
                ),
              ),
              const SizedBox(height: 20),
              const Text("📌 Lưu ý khi chuyển khoản:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                "Vui lòng ghi đúng nội dung chuyển khoản để hệ thống xác nhận đơn hàng tự động.",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser),
                label: const Text("Mở ứng dụng MoMo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade200,
                  foregroundColor: Colors.black87,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  if (paymentUrl != null && await canLaunchUrl(Uri.parse(paymentUrl!))) {
                    await launchUrl(Uri.parse(paymentUrl!), mode: LaunchMode.externalApplication);
                  } else {
                    showError("Không thể mở link thanh toán.");
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Tôi đã thanh toán"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: gotoApprovalScreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.teal.shade50,
          child: Icon(icon, color: Colors.teal),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value ?? "-", style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
