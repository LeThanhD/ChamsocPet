import 'package:chamsocpet/Profile/EditProfileScreen.dart';
import 'package:chamsocpet/Profile/ProfilePage.dart';
import 'package:chamsocpet/Qu%E1%BA%A3n%20L%C3%BD/EditPetScreen.dart';
import 'package:flutter/material.dart';

class UserInformationScreen extends StatefulWidget {
  @override
  State<UserInformationScreen> createState() => _UserInformationScreen();
}

class _UserInformationScreen extends State<UserInformationScreen> {
  String selectedGender = "Nam"; // Mặc định là "Nam"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[300],
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Chọn ảnh"),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Peter",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(label: "Giới tính:", value: selectedGender),
                const InfoRow(label: "Ngày sinh:", value: "03/08/1999"),
                const InfoRow(label: "Địa chỉ:", value: "Quận 7"),
                const InfoRow(label: "Email:", value: "lethanhdanhbtvn@gmail.com"),
                const InfoRow(label: "Số điện thoại:", value: "0356857480"),
                const SizedBox(height: 10),
                const Text("Chọn giới tính:", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Nam',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                    ),
                    const Text('Nam'),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: 'Nữ',
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                    ),
                    const Text('Nữ'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 250,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()), // Thay thế bằng màn hình bạn muốn chuyển tới
                );
              },
              child: const Text("Chỉnh sửa", style: TextStyle(fontSize: 16)),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
