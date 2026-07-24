import 'package:flutter/material.dart';

class SmartFarmer extends StatefulWidget{
  const SmartFarmer ({super.key});

  @override
  State<SmartFarmer> createState() => _smartFarmer();

}
class _smartFarmer extends State<SmartFarmer>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Artificial Intelligence"),
      ),
      body: const Center(
        child: Text(
          "AI is not yet Available",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )
        ),
      )
    );
  }
}