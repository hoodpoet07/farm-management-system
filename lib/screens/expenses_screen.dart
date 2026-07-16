import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  
  final List<Expense> _expenses = [];
  final TextEditingController _titleController=TextEditingController();
  final TextEditingController _categoryController=TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController =TextEditingController();

  void _addExpense(){
    if (_titleController.text.isEmpty||
        _categoryController.text.isEmpty||
        _amountController.text.isEmpty){
          return;
        }
    Expense expense = Expense(
      title: _titleController.text,
      category: _categoryController.text,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      date: DateTime.now().toString(),
    );

    setState((){
      _expenses.add(expense);
    });

    _titleController.clear();
    _categoryController.clear();
    _amountController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Expense Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _addExpense,
              child: const Text("Add Expense"),
            ),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Expenses",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (context, index){
                  Expense expense = _expenses[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.money_off),
                      title: Text(expense.title),
                      subtitle: Text(expense.category),
                      trailing: Text(
                        "\$${expense.amount}"
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}