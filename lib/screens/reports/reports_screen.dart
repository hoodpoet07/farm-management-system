import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double _totalSales = 0.0;
  double _totalExpenses = 0.0;
  double _totalPurchases = 0.0;
  double _totalFeedCost = 0.0;
  int _activeBirds = 0;
  int _totalMortality = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);

    final sales = await DatabaseHelper.instance.getTotalSalesAmount();
    final expenses = await DatabaseHelper.instance.getTotalExpensesAmount();
    final purchases = await DatabaseHelper.instance.getTotalPurchasesAmount();
    final feed = await DatabaseHelper.instance.getTotalFeedCost();
    final birds = await DatabaseHelper.instance.getTotalChickensCount();
    final mortality = await DatabaseHelper.instance.getTotalMortalityCount();

    setState(() {
      _totalSales = sales;
      _totalExpenses = expenses;
      _totalPurchases = purchases;
      _totalFeedCost = feed;
      _activeBirds = birds;
      _totalMortality = mortality;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double totalOutgoings = _totalExpenses + _totalPurchases + _totalFeedCost;
    final double netProfit = _totalSales - totalOutgoings;

    return Scaffold(
      appBar: AppBar(title: const Text('Farm Summary & Reports')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReportData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Overview Profit/Loss Card
                  Card(
                    color: netProfit >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Net Profit / Loss',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${netProfit.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Financial Breakdown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  _buildReportTile('Total Revenue (Sales)', _totalSales, Colors.green, Icons.monetization_on),
                  _buildReportTile('Feed Inventory Cost', _totalFeedCost, Colors.orange, Icons.grass),
                  _buildReportTile('General Expenses', _totalExpenses, Colors.deepOrange, Icons.money_off),
                  _buildReportTile('Purchases Cost', _totalPurchases, Colors.blue, Icons.shopping_bag),

                  const SizedBox(height: 20),
                  const Text(
                    'Flock Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.pets, color: Colors.white),
                    ),
                    title: const Text('Active Birds On Farm'),
                    trailing: Text(
                      '$_activeBirds',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.warning, color: Colors.white),
                    ),
                    title: const Text('Total Mortality Recorded'),
                    trailing: Text(
                      '$_totalMortality',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildReportTile(String title, double amount, Color color, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        trailing: Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}