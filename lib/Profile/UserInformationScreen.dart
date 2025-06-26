import 'package:flutter/material.dart';
import 'EditProfileScreen.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  String selectedGender = "Nam"; // Mặc định là "Nam"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa thông tin", style: TextStyle(color: Colors.black)),
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
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: const Color(0xFFECECEC),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: TextButton(
                    onPressed: () {
                      // TODO: xử lý chọn ảnh
                    },
                    child: const Text("Chọn ảnh"),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Peter",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(label: "Giới tính:", value: selectedGender),
                const InfoRow(label: "Ngày sinh:", value: "03/08/1999"),
                const InfoRow(label: "Địa chỉ:", value: "Quận 7"),
                const InfoRow(label: "Email:", value: "lethanhdanhbtvn@gmail.com"),
                const InfoRow(label: "Số điện thoại:", value: "0356857480"),
                const SizedBox(height: 20),
                const Text("Chọn giới tính:", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Nam',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() => selectedGender = value!);
                      },
                    ),
                    const Text('Nam'),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: 'Nữ',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() => selectedGender = value!);
                      },
                    ),
                    const Text('Nữ'),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) =>EditProfileScreen()),
                        );
                      },
                      child: const Text("Chỉnh sửa", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
