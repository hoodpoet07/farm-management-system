import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/chicken_batch.dart';
import '../../models/mortality.dart';

class RecordMortalityScreen extends StatefulWidget {

  final ChickenBatch? batch;

  const RecordMortalityScreen({
    super.key,
    this.batch
  });

  @override
  State<RecordMortalityScreen> createState() =>
      _RecordMortalityScreenState();
}

class _RecordMortalityScreenState
    extends State<RecordMortalityScreen> {

  final _formKey = GlobalKey<FormState>();

  List<ChickenBatch> _batches = [];

  ChickenBatch? _selectedBatch;
  int _currentBirds =0;
  int _totalMortality =0;
  int _totalSold=0;

  Future<void> _loadBatchStatistics() async {
    if (_selectedBatch ==null) return;

    final mortalities = await DatabaseHelper.instance.getMortalityByBatch(_selectedBatch!.id!);
    int mortality = 0;

    for (final record in mortalities){
      mortality += record.quantity;
    }

    int sold = await DatabaseHelper.instance.getTotalSoldByBatch(_selectedBatch!.id!);

    setState(() {
      _totalMortality = mortality;
      _totalSold = sold;
      _currentBirds=_selectedBatch!.quantity-mortality-sold;
    });
  }



  final TextEditingController _quantityController =
      TextEditingController();

  String? _selectedReason;

  final List<String> _reasons = [
    "Disease",
    "Heat Stress",
    "Injury",
    "Predator Attack",
    "Transport Loss",
    "Unknown",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    final batches =
        await DatabaseHelper.instance.getAllChickenBatches();

    setState(() {
      _batches = batches;

      if(widget.batch != null){
        _selectedBatch = batches.firstWhere(
          (b)=>b.id == widget.batch!.id,
        );
      }
    });

    if (_selectedBatch !=null){
      await _loadBatchStatistics();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveMortality() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    Mortality mortality = Mortality(
      batchId: _selectedBatch!.id!,
      quantity: int.parse(_quantityController.text),
      reason: _selectedReason!,
      date: DateTime.now().toString(),
    );

    await DatabaseHelper.instance.insertMortality(
      mortality,
    );

    if (mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Mortality Recorded Successfully",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Record Mortality"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              DropdownButtonFormField<ChickenBatch>(
                initialValue: _selectedBatch,

                decoration: const InputDecoration(
                  labelText: "Chicken Batch",
                  border: OutlineInputBorder(),
                ),

                items: _batches.map((batch) {

                  return DropdownMenuItem(
                    value: batch,
                    child: Text(batch.batchName),
                  );

                }).toList(),

                onChanged: (batch) async {
                  setState(() {
                    _selectedBatch = batch;
                  });
                  
                  await _loadBatchStatistics();
                  _formKey.currentState?.validate();
                },

                validator: (value) {
                  if (value == null) {
                    return "Select a batch";
                  }
                  return null;
                },

              ),
              if (_selectedBatch != null)
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Batch Summary",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Divider(),

                        ListTile(
                          leading: const Icon(Icons.egg),
                          title: const Text("Batch"),
                          trailing: Text(_selectedBatch!.batchName),
                        ),

                        ListTile(
                          leading: const Icon(Icons.pets),
                          title: const Text("Breed"),
                          trailing: Text(_selectedBatch!.breed),
                        ),

                        ListTile(
                          leading: const Icon(Icons.inventory),
                          title: const Text("Original Birds"),
                          trailing: Text("${_selectedBatch!.quantity}"),
                        ),

                        ListTile(
                          leading: const Icon(Icons.warning_amber),
                          title: const Text("Mortality"),
                          trailing: Text("$_totalMortality"),
                        ),

                        ListTile(
                          leading: const Icon(Icons.shopping_cart),
                          title: const Text("Sold"),
                          trailing: Text("$_totalSold"),
                        ),

                        const Divider(),

                        ListTile(
                          leading: const Icon(
                            Icons.calculate,
                            color: Colors.green,
                          ),
                          title: const Text(
                            "Current Birds",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            "$_currentBirds",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 15),

              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: "Number of Birds",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),

                validator: (value) {

                  if (value == null || value.trim().isEmpty) {
                    return "Enter the number of birds";
                  }

                  final quantity = int.tryParse(value);

                  if (quantity == null) {
                    return "Please enter a valid number";
                  }

                  if (quantity <= 0) {
                    return "Quantity must be greater than zero";
                  }

                  if (_selectedBatch == null) {
                    return "Please select a batch first";
                  }

                  if (quantity > _getRemainingBirds()) {
                    return "Only ${_getRemainingBirds()} birds are available in this batch";
                  }

                  return null;
                },

              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: _selectedReason,

                decoration: const InputDecoration(
                  labelText: "Reason",
                  border: OutlineInputBorder(),
                ),

                items: _reasons.map((reason) {

                  return DropdownMenuItem(
                    value: reason,
                    child: Text(reason),
                  );

                }).toList(),

                onChanged: (reason) {

                  setState(() {
                    _selectedReason = reason;
                  });

                },

                validator: (value) {

                  if (value == null) {
                    return "Select reason";
                  }

                  return null;

                },

              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: _saveMortality,

                  icon: const Icon(Icons.save),

                  label: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  int _getRemainingBirds(){
    return _currentBirds;
  }
}