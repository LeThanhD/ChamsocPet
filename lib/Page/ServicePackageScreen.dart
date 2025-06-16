import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: ServicePackageScreen()));
}

class ServicePackageScreen extends StatefulWidget {
  const ServicePackageScreen({super.key});

  @override
  State<ServicePackageScreen> createState() => _ServicePackageScreenState();
}

class _ServicePackageScreenState extends State<ServicePackageScreen> {
  int totalPrice = 0;

  final List<Map<String, dynamic>> dogServices = [
    {"title": "Gói cắt tỉa lông, móng, tắm sấy", "price": 150000},
    {"title": "Combo cắt tỉa, tắm, khám sức khỏe", "price": 200000},
    {"title": "Tạo kiểu lông, spa, tiêm vaccine", "price": 250000},
  ];

  final List<Map<String, dynamic>> catServices = [
    {"title": "Cắt tỉa lông, nhuộm lông thời trang", "price": 200000},
    {"title": "Combo cắt tỉa, spa, tiêm vaccine", "price": 250000},
  ];

  final List<Map<String, dynamic>> supplements = [
    {"title": "Vitamin tổng hợp cho chó mèo", "price": 300000},
    {"title": "Thuốc tẩy giun dạng nước, xổ giun cho chó mèo", "price": 200000},
    {"title": "Thuốc tiêu hóa tiêu chảy dành cho chó mèo", "price": 150000},
  ];

  final List<Map<String, dynamic>> tools = [
    {"title": "Spa, Tắm Sấy, Triệt sản", "price": 100000},
    {"title": "Tẩy giun dạng viên, xổ giun cho chó mèo", "price": 20000},
    {"title": "Sữa tắm trị ve, rận cho chó mèo", "price": 350000},
    {"title": "Tuýp kem bôi viêm da, nấm da", "price": 40000},
    {"title": "Men tiêu hóa", "price": 10000},
    {"title": "Chai xịt diệt bọ chét 300ml", "price": 50000},
  ];

  void addToCart(int price) {
    setState(() {
      totalPrice += price;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Các gói dịch vụ & đơn thuốc", style: TextStyle(color: Colors.black)),
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildCategoryTitle("🐶 Dịch vụ dành cho chó:"),
                ...dogServices.map(_buildServiceItem).toList(),

                const Divider(thickness: 8, color: Colors.grey),
                _buildCategoryTitle("🐱 Dịch vụ dành cho mèo:"),
                ...catServices.map(_buildServiceItem).toList(),

                const Divider(thickness: 8, color: Colors.grey),
                _buildCategoryTitle("💊 Thuốc & thực phẩm bổ sung:"),
                ...supplements.map(_buildServiceItem).toList(),

                const Divider(thickness: 8, color: Colors.grey),
                _buildCategoryTitle("🧴 Thuốc và dụng cụ chăm sóc chó mèo:"),
                ...tools.map(_buildServiceItem).toList(),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey)),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Tổng thanh toán\n${_formatCurrency(totalPrice)} VND",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: () {
                    // Chuyển sang màn hình giỏ hàng
                  },
                  child: const Text("Xem giỏ hàng"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            color: Colors.grey[300], // Placeholder image
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["title"], style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  "${_formatCurrency(item["price"])}đ",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                const Text("Xem chi tiết", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              addToCart(item["price"]);
            },
            icon: const Icon(Icons.add_circle_outline, color: Colors.deepOrange),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
