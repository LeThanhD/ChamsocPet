import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: ShoppingCartScreen()));
}

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreen();
}

class _ShoppingCartScreen extends State<ShoppingCartScreen> {
  int selectedTab = 0;

  final List<String> tabTitles = ["Chờ xác nhận", "Đang diễn ra", "Đã nhận hàng"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giỏ hàng", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
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
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabTitles.length, (index) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedTab == index ? Colors.orange : Colors.white,
                    foregroundColor: selectedTab == index ? Colors.white : Colors.black,
                    side: const BorderSide(color: Colors.black12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedTab = index;
                    });
                  },
                  child: Text(tabTitles[index]),
                );
              }),
            ),
          ),

          // Đơn hàng (mock)
          if (selectedTab == 0) _buildOrderCard(), // Chỉ hiển thị khi đang ở "Chờ xác nhận"
        ],
      ),
    );
  }

  Widget _buildOrderCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên khách + trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Trúc Mai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Chờ xác nhận", style: TextStyle(color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 8),

            // Danh sách sản phẩm
            const Text("x1  Combo cắt tỉa, tắm sấy, khám sức khỏe"),
            const Text("x1  Vitamin tổng hợp cho chó mèo"),

            const SizedBox(height: 12),

            // Tổng tiền
            const Text.rich(
              TextSpan(
                text: "Tổng đơn hàng:  ",
                children: [
                  TextSpan(
                    text: "500.000VND",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () {
                    // Xử lý nhận đơn
                  },
                  child: const Text("Nhận đơn"),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                  onPressed: () {
                    // Xử lý huỷ đơn
                  },
                  child: const Text("Huỷ đơn"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
