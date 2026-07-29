import 'package:flutter/material.dart';

class ChickenStockScreen extends StatelessWidget{
  const ChickenStockScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Screen"),
      ),
      body: const Center(
        child: Text(
          "Stocks Page",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}