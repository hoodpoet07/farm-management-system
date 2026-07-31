import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import '../../database/database_helper.dart';
import '../../models/expense.dart';
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}


class _ExpensesScreenState extends State<ExpensesScreen> {

 List<Expense> _expenses = [];
 Future<void> _loadExpenses() async{
  final expenses = await DatabaseHelper.instance.getAllExpenses();

  setState((){
    _expenses =expenses;
  });
 }

 @override
 void initState(){
  super.initState();
  _loadExpenses();
 }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
      ),
      body: _expenses.isEmpty
          ? const Center(
            child: Text(
              "no expenses yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
          :ListView.builder(
            itemCount: _expenses.length,
            itemBuilder: (context,index){
              final expense = _expenses[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.money_off),
                  title: Text(expense.title),
                  subtitle: Text(expense.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Text(
                        "\$${expense.amount.toStringAsFixed(2)}",
                          ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editExpense(expense);
                        },
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: (){
                          _confirmDelete(expense.id!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add expense"),
        onPressed: () async {
          final Expense? expense = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
             ),
        );

        if (expense != null) {
          await DatabaseHelper.instance.insertExpense(expense);
          _loadExpenses();
        }
      },
       
      )
    );  
  }

  Future<void> _confirmDelete(int id) async {
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text("Delete Expense"),
          content: const Text(
            "Are you sure you want to delete this expense ?"
          ),
          actions: [

            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.instance.deleteExpense(id);
                Navigator.pop(context);
                

                _loadExpenses();
              },
              child: const Text("Delete"),
            ),
          ]
        );
      }
    );
  }

  Future<void> _editExpense(Expense expense) async{
    final Expense? updatedExpense = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_)=>AddExpenseScreen(
          expense: expense,
        ),
      ),
    );
    if (updatedExpense != null){
      await DatabaseHelper.instance.updateExpense(updatedExpense);
      _loadExpenses();
    }
  }
}