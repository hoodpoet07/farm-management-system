import 'package:farm_management_system/screens/sales/sales_screen.dart';
import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/chicken_batch.dart';
import 'add_chicken_batch_screen.dart';
import 'record_mortality_screen.dart';

class ChickenStockScreen extends StatefulWidget {
  const ChickenStockScreen({super.key});

  @override
  State<ChickenStockScreen> createState() => _ChickenStockScreenState();
}

class _ChickenStockScreenState extends State<ChickenStockScreen> {
  List<ChickenBatch> _batches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() {
      _isLoading=true;
    });

    final batches = await DatabaseHelper.instance.getAllChickenBatches();

    setState(() {
      _batches=batches;
      _isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chicken Stock"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          :_batches.isEmpty
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
                  elevation: 4,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.egg),
                        ),
                        title: Text(batch.batchName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Breed: ${batch.breed}"),
                            Text("Quantity: ${batch.quantity} birds"),
                            Text("Cost/Bird: \$${batch.costPerBird.toStringAsFixed(2)}"),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                //batch edit
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text("Edit"),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>  RecordMortalityScreen(
                                      batch: batch,
                                    ),
                                  ),
                                );
                                _loadBatches();
                              },
                              icon: const Icon(
                                Icons.warning,
                                color: Colors.red,
                              ),
                              label: const Text("Mortality",style: TextStyle(color: Colors.red),),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecordSaleScreen(batch: batch),
                                    ),
                                );
                                _loadBatches();
                              },
                              icon: const Icon(
                                Icons.sell,
                                color: Colors.green,
                              ),
                              label: const Text("Sell", style: TextStyle(color: Colors.green)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add batch"),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddChickenBatchScreen(),
            ),
          );
        if (result==true){
          await _loadBatches();
        }
        },
      ),
    );
  }
}