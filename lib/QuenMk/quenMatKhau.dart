import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
            child: SizedBox(
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
                          "Quên Mật Khẩu",
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
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Số điện thoại
                  TextField(
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('Số điện thoại'),
                  ),

                  const SizedBox(height: 24),

                  // Mã SMS với nút Gửi mã ở bên phải
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: _inputDecorationWithButton('Mã SMS', onSendCode: () {
                      // TODO: xử lý gửi mã
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Nút xác nhận
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: xử lý xác nhận
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[200],
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration _inputDecorationWithButton(String hint, {required VoidCallback onSendCode}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      suffix: TextButton(
        onPressed: onSendCode,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          backgroundColor: Colors.lightBlue[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Gửi mã',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
