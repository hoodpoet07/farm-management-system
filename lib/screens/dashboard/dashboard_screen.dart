import 'package:farm_management_system/screens/ai/smart_farmer.dart';
import 'package:farm_management_system/screens/chicken/chicken_stock_screen.dart';
import 'package:farm_management_system/screens/expenses/expenses_screen.dart';
import 'package:farm_management_system/screens/feed/feed_inventory.dart';
import 'package:farm_management_system/screens/purchases/purchases_screen.dart';
import 'package:farm_management_system/screens/reports/reports_screen.dart';
import 'package:farm_management_system/screens/sales/sales_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/dashboard_card.dart';


class DashboardScreen extends StatelessWidget{
  const DashboardScreen({super.key});
  

  String _getGreeting(){
    final hour=DateTime.now().hour;

    if (hour<12){
      return "Good Morning";
    }else if(hour<17){
      return "Good Afternoon";
    }else{
      return "Good Evening";
    }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 3, 53, 5),
            width: 1.0,
          )
        ),
        title: const Text("PFUYAI",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 3, 53, 5),
          )),
        
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Farm Manager"), 
              accountEmail: Text("Welcome Back"),
              currentAccountPicture: CircleAvatar(
                child: Icon(
                  Icons.agriculture,
                  size: 40,
                  color: const Color.fromARGB(255, 3, 53, 5),
                ),
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 3, 53, 5),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Purchases"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>PurchasesScreen()
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text("Sales"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>SalesScreen()
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text("Expenses"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>ExpensesScreen()
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.egg),
              title: const Text("Chicken Batches"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>ChickenStockScreen()
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.grass),
              title: const Text("Feed Inventory"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>FeedInventoryScreen()
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Reports"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>ReportsScreen())
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text("AI"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>VirtualScreen() )
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        _getGreeting(),
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 5),

      const Text(
        "Here's today's farm summary",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),

      const SizedBox(height: 25),

      Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: const [

            DashboardCard(
              icon: Icons.egg,
              title: "Chickens",
              value: "0",
              color: Colors.orange,
              
            ),

            DashboardCard(
              icon: Icons.shopping_cart,
              title: "Purchases",
              value: "0",
              color: Colors.blue,
            ),

            DashboardCard(
              icon: Icons.attach_money,
              title: "Sales",
              value: "\$0.00",
              color: Colors.green,
            ),

            DashboardCard(
              icon: Icons.money_off,
              title: "Expenses",
              value: "\$0.00",
              color: Colors.red,
            ),

          ],
        ),
      ),

    ],
  ),
),
    );
          
  }


}
