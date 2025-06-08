import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEFD3EC), // Hồng nhạt
              Color(0xFFB3E5FC), // Xanh nhạt
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Stack cho tiêu đề và nút quay lại
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const Center(
                        child: Text(
                          "Đăng Nhập",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Ảnh minh họa
                  Center(
                    child: Image.asset(
                      'assets/anhAvatar.png',
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Trường nhập tài khoản
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tài khoản',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trường nhập mật khẩu
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Mật khẩu',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nút đăng nhập
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Xử lý đăng nhập
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[200],
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
