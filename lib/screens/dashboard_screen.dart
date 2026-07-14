import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget{
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Management System'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Welcome to the Farm Management System!',
         style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,),
       
        )
      ),
    );
  }

}
