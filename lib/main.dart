import 'package:flutter/material.dart';
import 'screens/login/login.dart';
void main() {
  runApp(const FarmManagementApp());
}

class FarmManagementApp extends StatelessWidget {
  const FarmManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farm Management System',
      home: const LoginScreen(),
    );
  }
}