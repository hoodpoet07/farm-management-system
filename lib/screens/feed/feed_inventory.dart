import 'package:flutter/material.dart';

class FeedInventoryScreen extends StatelessWidget{
  const FeedInventoryScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed Inventory"),
      ),
      body: const Center(
        child: Text(
          "Feed Inventory Page",
          style: TextStyle(
            fontSize: 24,
          ),
        )
      )

    );
  }
}