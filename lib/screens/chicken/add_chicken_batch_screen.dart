import 'package:flutter/material.dart';
import '../../models/chicken_batch.dart';
import '../../database/database_helper.dart';

class AddChickenBatchScreen extends StatefulWidget {
  const AddChickenBatchScreen({super.key});

  @override
  State<AddChickenBatchScreen> createState() =>_AddChickenBatchScreenState();
}

class _AddChickenBatchScreenState extends State<AddChickenBatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final _batchController = TextEditingController();
  final _breedController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();

  @override
  void dispose() {
    _batchController.dispose();
    _breedController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _saveBatch() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    ChickenBatch batch = ChickenBatch(
      batchName: _batchController.text.trim(),
      breed: _breedController.text.trim(),
      quantity: int.parse(_quantityController.text),
      costPerBird: double.parse(_costController.text),
      arrivalDate: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.insertChickenBatch(batch);

    if (mounted){
    Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Chicken Batch"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(
                  labelText: "Batch Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter batch name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: "Breed",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.egg),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter breed";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter quantity";
                  }
                  if (int.tryParse(value.trim())==null){
                    return "Enter a valid integer";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Cost Per Bird",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter cost per bird";
                  }
                  if (double.tryParse(value.trim())==null){
                    return "Enter a valid cost amount";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _saveBatch,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Save Batch",
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