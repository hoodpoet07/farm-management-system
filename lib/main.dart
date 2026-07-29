import 'package:farm_management_system/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
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
      home: const DashboardScreen(),
    );
  }
}