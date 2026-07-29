import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/chicken_batch.dart';
import 'add_chicken_batch_screen.dart';

class ChickenStockScreen extends StatefulWidget {
  const ChickenStockScreen({super.key});

  @override
  State<ChickenStockScreen> createState() => _ChickenStockScreenState();
}

class _ChickenStockScreenState extends State<ChickenStockScreen> {
  List<ChickenBatch> _batches = [];

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    final batches = await DatabaseHelper.instance.getAllChickenBatches();

    setState(() {
      _batches = batches;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chicken Stock"),
      ),

      body: _batches.isEmpty
          ? const Center(
              child: Text(
                "No Chicken Batches Yet",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _batches.length,
              itemBuilder: (context, index) {
                final batch = _batches[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.egg),
                    ),

                    title: Text(batch.batchName),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Breed: ${batch.breed}"),
                        Text("Quantity: ${batch.quantity} birds"),
                        Text("Cost/Bird: \$${batch.costPerBird}"),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () async {
          final batch = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddChickenBatchScreen(),
            ),
          );

          if (batch != null) {
            await DatabaseHelper.instance.insertChickenBatch(batch);
            _loadBatches();
          }
        },
      ),
    );
  }
}