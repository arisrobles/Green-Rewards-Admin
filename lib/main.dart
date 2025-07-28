import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screen/admin_credentials_login_screen.dart';
import 'screen/admin_home_screen.dart';
import 'screen/admin_give_points_screen.dart';
import 'screen/admin_edit_rewards_screen.dart';
import 'screen/admin_transactions_screen.dart';
import 'screen/report_forum_screen.dart';
import 'screen/admin_profile_screen.dart';
import 'screen/splash_screen.dart';
import 'screen/admin_signup_screen.dart';
import 'screen/admin_forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDslKcef5sJQk2LuGegJTVy6nAfM-jxcug",
      appId: "1:1024622849606:android:e34a223f86345420d12447",
      messagingSenderId: "1024622849606",
      projectId: "green-rewards-ae329",
      storageBucket: "green-rewards-ae329.firebasestorage.app",
    ),
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trash Rewards Admin App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
      routes: {
        '/admin-login': (context) => const AdminCredentialsLoginScreen(),
        '/admin-signup': (context) => const AdminSignUpScreen(),
        '/admin-forgot': (context) => const AdminForgotPasswordScreen(),
        '/admin-home': (context) => const AdminHomeScreen(),
        '/admin-give-points': (context) => const AdminGivePointsScreen(),
        '/admin-edit-rewards': (context) => const AdminEditRewardsScreen(),
        '/admin-transactions': (context) => const AdminTransactionsScreen(),
        '/report-forum': (context) => const ReportForumScreen(),
        '/admin-profile': (context) => const AdminProfileScreen(),
      },
    );
  }
}