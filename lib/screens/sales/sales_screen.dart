import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/chicken_batch.dart';
import '../../models/sales.dart';
class RecordSaleScreen extends StatefulWidget {
  final ChickenBatch? batch;

  const RecordSaleScreen({super.key, this.batch});

  @override
  State<RecordSaleScreen> createState() => _RecordSaleScreenState();
}

class _RecordSaleScreenState extends State<RecordSaleScreen> {
  final _formKey = GlobalKey<FormState>();

  List<ChickenBatch> _batches = [];
  ChickenBatch? _selectedBatch;

  int _currentBirds = 0;
  int _totalMortality = 0;
  int _totalSold = 0;

  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _customerController = TextEditingController();

  double _calculatedTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    final batches = await DatabaseHelper.instance.getAllChickenBatches();

    setState(() {
      _batches = batches;
      if (widget.batch != null) {
        _selectedBatch = batches.firstWhere(
          (b) => b.id == widget.batch!.id,
          orElse: () => widget.batch!,
        );
      }
    });

    if (_selectedBatch != null) {
      await _loadBatchStatistics();
    }
  }

  Future<void> _loadBatchStatistics() async {
    if (_selectedBatch == null || _selectedBatch!.id == null) return;

    final mortalities = await DatabaseHelper.instance.getMortalityByBatch(_selectedBatch!.id!);
    int mortality = 0;
    for (final record in mortalities) {
      mortality += record.quantity;
    }

    int sold = await DatabaseHelper.instance.getTotalSoldByBatch(_selectedBatch!.id!);

    setState(() {
      _totalMortality = mortality;
      _totalSold = sold;
      _currentBirds = _selectedBatch!.quantity - mortality - sold;
    });
  }

  void _updateCalculatedTotal() {
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    setState(() {
      _calculatedTotal = qty * price;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _customerController.dispose();
    super.dispose();
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBatch == null || _selectedBatch!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a batch first")),
      );
      return;
    }

    final qty = int.parse(_quantityController.text.trim());
    final price = double.parse(_priceController.text.trim());

    Sale sale = Sale(
      batchId: _selectedBatch!.id!,
      quantity: qty,
      pricePerBird: price,
      totalAmount: qty * price,
      customerName: _customerController.text.trim(),
      date: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.insertSale(sale);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sale recorded successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Sale"),
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
                  labelText: "Select Chicken Batch",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.egg),
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
                validator: (value) => value == null ? "Select a batch" : null,
              ),
              if (_selectedBatch != null) ...[
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat("Original", "${_selectedBatch!.quantity}"),
                        _buildStat("Mortality", "$_totalMortality", color: Colors.red),
                        _buildStat("Sold", "$_totalSold", color: Colors.orange),
                        _buildStat("Available", "$_currentBirds", color: Colors.green, isBold: true),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 15),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity Sold",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                onChanged: (_) => _updateCalculatedTotal(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Enter quantity";
                  final qty = int.tryParse(value.trim());
                  if (qty == null || qty <= 0) return "Enter a valid positive number";
                  if (_selectedBatch == null) return "Select a batch first";
                  if (qty > _currentBirds) return "Only $_currentBirds birds available in stock";
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Price Per Bird (\$)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                onChanged: (_) => _updateCalculatedTotal(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Enter price per bird";
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) return "Enter a valid price";
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _customerController,
                decoration: const InputDecoration(
                  labelText: "Customer Name (Optional)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Revenue:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\$${_calculatedTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _saveSale,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    "Record Sale",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color, bool isBold = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}