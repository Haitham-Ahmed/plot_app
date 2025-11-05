import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plot_app/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // لو المستخدم مش مسجل دخول، وديه على شاشة الدخول
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // لو مسجل دخول، وديه على الشاشة الرئيسية
        return const HomeScreen();
      },
    );
  }
}