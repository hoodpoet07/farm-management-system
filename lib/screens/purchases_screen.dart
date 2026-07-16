import 'package:flutter/material.dart';

class PurchasesScreen extends StatelessWidget{
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(
        title: const Text("Expenses"),
      ),
      body: const Center(
        child: Text(
          "Purchases Page",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}