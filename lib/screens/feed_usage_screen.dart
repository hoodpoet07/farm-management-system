import 'package:flutter/material.dart';

class FeedUsageScreen extends StatelessWidget{
  const FeedUsageScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed Usage"),
      ),
      body:const Center(
        child: Text(
          "Feed Usage Page",
          style: TextStyle(
            fontSize: 24,
          ),  
        ),
      )
    );
  }
}