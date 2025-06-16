import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán", style: TextStyle(color: Colors.black)),
        elevation: 0,
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
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPaymentOption(
              label: "Thanh toán qua MoMo",
              icon: Icons.qr_code,
              onTap: () {
                // Xử lý chuyển sang thanh toán MoMo
              },
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              label: "Thanh toán qua ATM",
              icon: Icons.credit_card,
              onTap: () {
                // Xử lý chuyển sang thanh toán ATM
              },
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              label: "Thanh toán bằng tiền mặt",
              icon: Icons.attach_money,
              onTap: () {
                // Xử lý chọn thanh toán tiền mặt
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            Icon(icon, size: 24, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
