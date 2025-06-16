import 'package:chamsocpet/Appointment/AppointmentPage.dart';
import 'package:chamsocpet/Appointment/AppointmentScreen.dart';
import 'package:chamsocpet/Profile/ConfirmPaymentScreen.dart';
import 'package:chamsocpet/Notification/NotificationScreen.dart';
import 'package:chamsocpet/Page/ContactScreen.dart';
import 'package:chamsocpet/Page/ProductDetailScreen.dart';
import 'package:chamsocpet/Page/ServicePackageScreen.dart';
import 'package:chamsocpet/Profile/EditProfileScreen.dart';
import 'package:chamsocpet/Profile/PetHistoryScreen.dart';
import 'package:chamsocpet/Profile/ShoppingCartScreen.dart';
import 'package:chamsocpet/Profile/UserInformationScreen.dart';
import 'package:chamsocpet/Profile/PaymentScreen.dart';
import 'package:chamsocpet/Qu%E1%BA%A3n%20L%C3%BD/PetScreen.dart';
import 'package:chamsocpet/Qu%E1%BA%A3n%20L%C3%BD/PetSecondScreen.dart';
import 'package:chamsocpet/Setting/ChangePasswordScreen.dart';
import 'package:chamsocpet/Setting/MedicalHistoryScreen.dart';
import 'package:chamsocpet/Setting/SettingScreen.dart';
import 'package:chamsocpet/Qu%E1%BA%A3n%20L%C3%BD/AddPetScreen.dart';
import 'package:chamsocpet/Qu%E1%BA%A3n%20L%C3%BD/ManageScreen.dart';
import 'package:chamsocpet/Page/PageScreen.dart';
import 'package:chamsocpet/Profile/ProfilePage.dart';
import 'package:chamsocpet/Setting/SwitchAccountScreen.dart';
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
      home: PageScreen(),
    );
  }
}

