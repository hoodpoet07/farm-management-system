import 'package:flutter/material.dart';
import '../../widgets/dashboard_card.dart';
import '../expenses/expenses_screen.dart';
import '../purchases/purchases_screen.dart';
import '../sales/sales_screen.dart';
import '../settings/settings_screen.dart';
import '../feed/feed_usage_screen.dart';
import '../reports/reports_screen.dart';
import '../feed/feed_inventory.dart';
class DashboardScreen extends StatelessWidget{
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "Quick Actions",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 20),

      Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [

            DashboardCard(
              icon: Icons.money_off,
              title: "Expenses",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>const ExpensesScreen(),
                  ),
                );
              },
            ),

            DashboardCard(
              icon: Icons.shopping_cart,
              title: "Purchases",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>const PurchasesScreen(),
                  ),
                );
              },
            ),

            DashboardCard(
              icon: Icons.sell,
              title: "Sales",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>const SalesScreen(),  
                  )
                );
              },
            ),

            DashboardCard(
              icon: Icons.grass,
              title: "Feed Usage",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>const FeedUsageScreen(),
                  ),
                );
              },
            ),

            DashboardCard(
              icon: Icons.egg,
              title: "Chickens",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>const FeedInventoryScreen(),
                  )
                );
              },
            ),

            DashboardCard(
              icon: Icons.bar_chart,
              title: "Reports",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>const ReportsScreen(),
                  ),
                );
              },
            ),
            DashboardCard(
              icon: Icons.settings,
              title: "settings",
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context)=>const SettingsScreen(),
                  ),
                );
              },
              ),
            DashboardCard(
              icon: Icons.smart_toy_outlined,
              title: "AI Assistant",
              onTap: (){
                 
              },
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
