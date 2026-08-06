import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/feed.dart';

class FeedInventoryScreen extends StatefulWidget {
  const FeedInventoryScreen({super.key});

  @override
  State<FeedInventoryScreen> createState() => _FeedInventoryScreenState();
}

class _FeedInventoryScreenState extends State<FeedInventoryScreen> {
  List<Feed> _feeds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    setState(() => _isLoading = true);
    final feeds = await DatabaseHelper.instance.getAllFeeds();
    setState(() {
      _feeds = feeds;
      _isLoading = false;
    });
  }

  void _showAddFeedDialog() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final costController = TextEditingController();
    String category = 'Starter Mash';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Feed Stock'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Feed Name/Brand'),
              ),
              DropdownButtonFormField<String>(
                initialValue: category,
                items: ['Starter Mash', 'Grower Mash', 'Finisher Pellets', 'Layer Feed']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => category = val!,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity (Kg)'),
              ),
              TextField(
                controller: costController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Cost Per Kg (\$)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  qtyController.text.isEmpty ||
                  costController.text.isEmpty) {
                return;
              }

              await DatabaseHelper.instance.insertFeed(
                Feed(
                  feedName: nameController.text.trim(),
                  category: category,
                  quantityKg: double.parse(qtyController.text),
                  costPerKg: double.parse(costController.text),
                  dateAdded: DateTime.now().toIso8601String().substring(0, 10),
                ),
              );

              if (mounted) {
                Navigator.pop(context);
                _loadFeeds();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed Inventory')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feeds.isEmpty
              ? const Center(child: Text('No feed items in stock'))
              : ListView.builder(
                  itemCount: _feeds.length,
                  itemBuilder: (context, index) {
                    final item = _feeds[index];
                    final totalCost = item.quantityKg * item.costPerKg;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 3,
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.grass),
                        ),
                        title: Text(item.feedName),
                        subtitle: Text(
                          "Category: ${item.category}\nQty: ${item.quantityKg} kg @ \$${item.costPerKg.toStringAsFixed(2)}/kg",
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${totalCost.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () async {
                                await DatabaseHelper.instance.deleteFeed(item.id!);
                                _loadFeeds();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFeedDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Feed'),
      ),
    );
  }
}