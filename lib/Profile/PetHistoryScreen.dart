import 'package:chamsocpet/Profile/ProfilePage.dart';
import 'package:flutter/material.dart';

class PetHistoryScreen extends StatelessWidget {
  const PetHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header có nút quay lại + tiêu đề + tìm kiếm
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCCBFFF), Color(0xFF47D7E9)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()), // Thay thế bằng màn hình bạn muốn chuyển tới
                    );
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Lịch sử quản lý",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Icon(Icons.search),
              ],
            ),
          ),

          // Danh sách lịch sử thú cưng
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildPetHistoryCard(
                  name: "Dog",
                  species: "Chó cỏ",
                  birth: "03/07/1999",
                  service: "Tắm Sấy, Spa và Cắt Tỉa",
                  note: "sốt nặng",
                  status: "đã khỏe và trả về nhà",
                ),
                const SizedBox(height: 12),
                _buildPetHistoryCard(
                  name: "Cat",
                  species: "Mèo anh chân ngắn",
                  birth: "07/07/1999",
                  service: "Tắm Sấy, Spa và Cắt Tỉa",
                  note: "cần chải lông",
                  status: "đang theo dõi",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetHistoryCard({
    required String name,
    required String species,
    required String birth,
    required String service,
    required String note,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tên thú cưng : $name", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Giống loài: $species"),
          Text("Ngày sinh: $birth"),
          Text("Dịch vụ yêu cầu: $service"),
          Text("Ghi chú: $note"),
          const SizedBox(height: 4),
          Text(
            "Trạng thái: $status",
            style: const TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
