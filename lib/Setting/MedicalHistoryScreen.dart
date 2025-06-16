import 'package:chamsocpet/Setting/SettingScreen.dart';
import 'package:flutter/material.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử bệnh", style: TextStyle(color: Colors.black)),
        // backgroundColor: const LinearGradientAppBar(),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );},
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          HistoryCard(
            id: "1",
            petInfo: "Coby - 6 tháng",
            date: "14-01-2025",
            price: "500.000VND",
          ),
          SizedBox(height: 12),
          HistoryCard(
            id: "2",
            petInfo: "Helen - 2 năm",
            date: "20-01-2025",
            price: "250.000VND",
          ),
        ],
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String id;
  final String petInfo;
  final String date;
  final String price;

  const HistoryCard({
    super.key,
    required this.id,
    required this.petInfo,
    required this.date,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mã đơn + Ngày
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Mã đơn: $id", style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.black),
                  const SizedBox(width: 5),
                  Text(date),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Thông tin thú cưng
          Text(
            petInfo,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          // Giá tiền
          Text(price,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough)),
          const SizedBox(height: 6),
          // Đã thanh toán + xem chi tiết
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("Đã thanh toán",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("Xem chi tiết", style: TextStyle(color: Colors.red)),
              )
            ],
          )
        ],
      ),
    );
  }
}

// Gradient AppBar background
class LinearGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LinearGradientAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purpleAccent, Colors.cyan],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
