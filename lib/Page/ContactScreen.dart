import 'package:flutter/material.dart';


class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("Thông tin liên hệ", style: TextStyle(color: Colors.black)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Liên hệ với chúng tôi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan),
            ),
            const SizedBox(height: 10),
            const Icon(Icons.pets, size: 50, color: Colors.cyan),
            const SizedBox(height: 10),
            const Text(
              "Hãy để lại thông tin bên dưới, chúng tôi sẽ liên hệ ngay lập tức để tư vấn và hỗ trợ vấn đề bạn gặp phải. Xin cảm ơn!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            // Form fields
            Row(
              children: [
                Expanded(child: _buildInputField("Tên")),
                const SizedBox(width: 10),
                Expanded(child: _buildInputField("Email")),
              ],
            ),
            const SizedBox(height: 10),
            _buildInputField("Tiêu đề"),
            const SizedBox(height: 10),
            _buildInputField("Nhập nội dung", maxLines: 5),
            const SizedBox(height: 20),
            // Gửi yêu cầu
            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã gửi yêu cầu")),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.cyan),
                ),
                child: const Text("Gửi yêu cầu", style: TextStyle(color: Colors.cyan)),
              ),
            ),
            const SizedBox(height: 30),
            const Divider(height: 1),
            const SizedBox(height: 20),
            // Contact info
            _buildContactRow(Icons.phone, "SỐ KHẨN CẤP", "0112565989"),
            const SizedBox(height: 10),
            _buildContactRow(Icons.email, "EMAIL", "info@shopthucung.com.vn"),
            const SizedBox(height: 10),
            _buildContactRow(Icons.access_time, "GIỜ LÀM VIỆC",
                "Thứ 2 - Chủ nhật : Sáng 08h00 - 12h00, Chiều 14h00 - 18h00"),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, {int maxLines = 1}) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }


  Widget _buildContactRow(IconData icon, String label, String info) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.cyan),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(info, style: const TextStyle(fontSize: 14)),
            ],
          ),
        )
      ],
    );
  }
}
