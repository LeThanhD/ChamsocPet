import 'package:chamsocpet/Profile/UserInformationScreen.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String gender = "Nam";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Chỉnh sửa",
          style: TextStyle(color: Colors.black),
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image button
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  minimumSize: Size.fromRadius(40), // làm vừa vòng tròn
                  shape: const CircleBorder(),
                ),
                child: const Text("Chọn ảnh", textAlign: TextAlign.center),
              ),
            ),


            _buildTextField("Tên", ""),
            _buildTextField("Ngày sinh", ""),
            _buildTextField("Email", ""),
            _buildTextField("Địa chỉ", ""),
            _buildTextField("Số điện thoại", ""),

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text("Giới tính", style: TextStyle(fontSize: 16)),
            ),
            Row(
              children: [
                Radio<String>(
                  value: "Nam",
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value!;
                    });
                  },
                ),
                const Text("Nam"),
                Radio<String>(
                  value: "Nữ",
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value!;
                    });
                  },
                ),
                const Text("Nữ"),
              ],
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(120, 50),
                  ),
                  onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserInformationScreen()), // Thay thế bằng màn hình bạn muốn chuyển tới
                  );},
                  child: const Text("Lưu"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: const Size(120, 50),
                  ),
                  onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserInformationScreen()), // Thay thế bằng màn hình bạn muốn chuyển tới
                  );},
                  child: const Text("Huỷ"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          controller: TextEditingController(text: value),
          enabled: enabled,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.only(bottom: 5),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
