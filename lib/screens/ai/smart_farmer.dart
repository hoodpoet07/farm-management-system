import 'package:flutter/material.dart';

class VirtualScreen extends StatelessWidget{
  const VirtualScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI"),
      ),
      body: const Center(
        child: Text(
          "AI Page",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}