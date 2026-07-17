import 'package:flutter/material.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}


class _ExpensesScreenState extends State<ExpensesScreen> {
 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
      ),
      body: const Center(
        child: Text(
          "No Expenses Yet",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context)=>const AddExpenseScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      )
    );  
  }
}