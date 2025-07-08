import 'package:chamsocpet/pay/PaymentSuccessScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'user/DangNhap.dart';       // LoginScreen
import 'user/TrangChinh.dart';    // LoginPage
import 'Profile/ProfilePage.dart'; // Trang cá nhân

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background handler cho FCM
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 [Background] Message received: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization (Chỉ gọi một lần duy nhất trong main)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase initialized!');

  // Đăng ký background handler cho FCM
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

      // Request permission to receive notifications
      await messaging.requestPermission();

      // Initialize FCM if not already
      await messaging.setAutoInitEnabled(true);

      // Get the token
      final token = await messaging.getToken();
      if (token != null) {
        print('📱 FCM Token: $token');
        setState(() {
          _fcmToken = token;
        });
      } else {
        print('❌ FCM Token is null!');
      }

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title;
        final body = message.notification?.body;
        final data = message.data;

        print('🔔 [Foreground] $title - $body');

        // Handling custom action from notification data
        if (data['action'] == 'payment_approved') {
          final paymentData = {
            'PaymentID': data['payment_id'] ?? '',
            'PaidAmount': data['amount'] ?? 0,
            'Note': data['note'] ?? '',
            'Status': 'Đã xác nhận',
          };

          // Navigate to PaymentSuccessScreen when action is triggered
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
      home: const LoginScreen(), // Make sure to use const for immutable widgets
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => LoginPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
