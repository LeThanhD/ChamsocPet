import 'package:chamsocpet/pay/PaymentSuccessScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'login/DangNhap.dart';       // LoginScreen
import 'login/TrangChinh.dart';    // LoginPage
import 'Profile/ProfilePage.dart'; // Trang cá nhân

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('📩 [Background] Message received: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase initialized!');

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();
      await messaging.setAutoInitEnabled(true);

      final token = await messaging.getToken();
      print('📱 FCM Token: $token');
      setState(() {
        _fcmToken = token;
      });

      // ✅ Nhận thông báo khi app đang mở
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title;
        final body = message.notification?.body;
        final data = message.data;

        print('🔔 [Foreground] $title - $body');

        if (data['action'] == 'payment_approved') {
          final paymentData = {
            'PaymentID': data['payment_id'] ?? '',
            'PaidAmount': data['amount'] ?? 0,
            'Note': data['note'] ?? '',
            'Status': 'Đã xác nhận',
          };

          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(),
            ),
          );
        }
      });
    } catch (e) {
      print('❌ FCM Setup Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => LoginPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
} 