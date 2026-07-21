import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory;

  final List<String> _categories=[
    'Feed',
    'Transportation',
    'Medication',
    'Equipment',
    'Labour',
    'Utilities',
    'Other',
  ];

  @override
  void dispose(){
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  void _saveExpense(){
    if(!_formKey.currentState!.validate()){
      return;
    }
  
    Expense expense = Expense(
      title: _titleController.text,
      category: _selectedCategory!,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.trim(),
      date: DateTime.now().toString(),
    );

    Navigator.pop(context,expense);
    
  

  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
          children: [
            CustomTextField(
              controller: _titleController,
              label: "Expense Title",
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter an expense title";
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            CustomDropdown(
              label: "category",
              icon: Icons.category,
              value: _selectedCategory,
              items: _categories,
              onChanged: (value){
                setState(() {
                  _selectedCategory=value;
                });
              },
              validator: (value){
                if (value==null){
                  return "Please select a category";
                }
                return null;
              },
            ),


            const SizedBox(height: 10),

            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value){
                if (value==null||value.trim().isEmpty){
                  return "Please enter an amount";
                }
                final amount=double.tryParse(value);

                if (amount==null){
                  return "amount must be a number";
                }

                if (amount<=0){
                  return "amount must be greater than zero";
                }

                return null;
              },
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveExpense,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Expense",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}