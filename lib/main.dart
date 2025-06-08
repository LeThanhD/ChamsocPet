import 'package:flutter/material.dart';
import 'DangKy/Dangky.dart';
import 'QuenMk/quenMatKhau.dart';
import 'login/DangNhap.dart';
import 'login/TrangChinh.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

