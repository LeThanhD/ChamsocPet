import 'package:flutter/material.dart';

// Import các màn khác như bạn đang có
import 'Profile/EditProfileScreen.dart';
import 'Profile/UserInformationScreen.dart';
import 'login/DangNhap.dart'; // LoginPage (login screen bạn đang dùng)
import 'login/TrangChinh.dart'; // Trang chính sau khi đăng nhập
import 'Profile/ProfilePage.dart'; // Trang cá nhân

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ Trang khởi động đầu tiên
      home: LoginScreen(),

      // ✅ Định nghĩa các route name
      routes: {
        '/login': (context) => LoginScreen(), // ✅ Route cho đăng nhập
        '/home': (context) => LoginPage(),  // nếu cần
        '/profile': (context) => const ProfilePage(),
        // bạn có thể thêm các route khác ở đây nếu cần
      },
    );
  }
}
