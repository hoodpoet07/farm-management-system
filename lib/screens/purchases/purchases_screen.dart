import 'package:flutter/material.dart';
import '../../models/purchase.dart';
import 'add_purchase_screen.dart';
import '../../database/database_helper.dart';

class PurchasesScreen extends StatefulWidget{
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState()=>_PurchasesScreenState();

}

class _PurchasesScreenState extends State<PurchasesScreen> {
  List<Purchase> _purchases = [];

  @override
  void initState(){
    super.initState();
    _loadPurchases();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Purchases"),
      ),

      body: _purchases.isEmpty
        ? const Center(
          child: Text(
            "No purchases Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
        : ListView.builder(
          itemCount: _purchases.length,
          itemBuilder: (context,index){
            final purchase = _purchases[index];

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.shopping_cart),
                ),
                
                title: Text(purchase.itemName),

                subtitle:Text(
                  "\$${purchase.totalPrice.toStringAsFixed(2)}",
                  ),

                trailing: Text(
                  "\$${purchase.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                  isThreeLine: true,
              )
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final Purchase? purchase = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_)=> const AddPurchaseScreen(),
              ),
            );
            
            if (purchase != null){
              await DatabaseHelper.instance.insertPurchase(purchase);
              _loadPurchases();
            }
          },
          child: const Icon(Icons.add),
        ),
    );
  }
  Future<void> _loadPurchases() async {
    final purchases =
      await DatabaseHelper.instance.getAllPurchases();

    setState((){
      _purchases = purchases;
    });
  }
}