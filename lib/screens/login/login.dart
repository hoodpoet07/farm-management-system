import 'package:farm_management_system/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("LOGIN SCREEN"),
        backgroundColor: Colors.green[700],
        
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login coming Soon'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>DashboardScreen()
                     ),
                );
              },
              child: const Text('Go to Dashboard Screen')
            ),
          ],
        ),
      ),
      
    );
  }
}