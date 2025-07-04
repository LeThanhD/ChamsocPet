import 'package:flutter/material.dart';

import '../pay/PaymentScreen.dart';

void main() {
  runApp(MaterialApp(home: ConfirmPaymentScreen()));
}

class ConfirmPaymentScreen extends StatelessWidget {
  const ConfirmPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Xác nhận thanh toán",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.black),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFD4F5), Color(0xFF83F1F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              icon: Icons.person,
              title: "Thông tin người dùng",
              content: "Tên khách hàng: Mai",
            ),
            _buildSection(
              icon: Icons.location_on,
              title: "Địa chỉ của bạn",
              content: "Huỳnh Thúc Kháng, Quận 1, TpHCM",
            ),
            _buildSection(
              icon: Icons.phone,
              title: "Số điện thoại",
              content: "012345678",
            ),
            _buildSection(
              icon: Icons.access_time,
              title: "Thời gian hẹn",
              content: "1/2/2025 - 9:00AM",
            ),

            const SizedBox(height: 10),
            _buildServiceDetail(),

            const SizedBox(height: 20),
            _buildNoteField(),

            const SizedBox(height: 16),
            _buildPaymentMethod(context),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {},
                child: const Text("Xác nhận"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.orange),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(content),
        ),
      ],
    );
  }

  Widget _buildServiceDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.layers, color: Colors.deepOrange),
          title: const Text(
            "Chi tiết dịch vụ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade300,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Combo cắt tỉa, tắm, khám sức khỏe"),
                    const Text("x1", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    const Text("Tổng phí dịch vụ: 250.000đ"),
                    const SizedBox(height: 4),
                    Text(
                      "Phí thanh toán: 250.000đ",
                      style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Padding(
          padding: EdgeInsets.only(left: 16, bottom: 4),
          child: Text("Lưu ý cho shop:"),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Nhập tin nhắn...",
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.all(10),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 4),
          child: Text("Phương thức thanh toán"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const PaymentScreen(),
              //   ),
              // );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Thanh toán bằng tiền mặt",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
