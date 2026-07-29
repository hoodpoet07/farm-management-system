import 'package:farm_management_system/screens/ai/smart_farmer.dart';
import 'package:farm_management_system/screens/chicken/chicken_stock_screen.dart';
import 'package:farm_management_system/screens/expenses/expenses_screen.dart';
import 'package:farm_management_system/screens/feed/feed_inventory.dart';
import 'package:farm_management_system/screens/login/login.dart';
import 'package:farm_management_system/screens/purchases/purchases_screen.dart';
import 'package:farm_management_system/screens/reports/reports_screen.dart';
import 'package:farm_management_system/screens/sales/sales_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/dashboard_card.dart';
import 'package:url_launcher/url_launcher.dart';


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
        child: Column(
          children: [
            // Your top scrolling items stay inside Expanded to prevent pixel layout crashes
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: const Text("Farm Manager"), 
                    accountEmail: const Text("Welcome Back"),
                    currentAccountPicture: const CircleAvatar(
                      child: Icon(
                        Icons.agriculture,
                        size: 40,
                        color: Color.fromARGB(255, 3, 53, 5),
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
                          builder: (context) => const PurchasesScreen()
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
                          builder: (context) => const SalesScreen()
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
                          builder: (context) => const ExpensesScreen()
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
                          builder: (context) => const ChickenStockScreen()
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
                          builder: (context) => const FeedInventoryScreen()
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
                          builder: (context) => const ReportsScreen()
                        )
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
                          builder: (context) => const VirtualScreen() 
                        )
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("LOGOUT"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen() 
                        )
                      );
                    },
                  ),
                ],
              ),
            ),

            // FIXED AREA
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0, left: 16.0, right: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(color: Color.fromARGB(255, 3, 53, 5), thickness: 0.5),
                      const SizedBox(height: 8),
                      const Text(
                        "FULECH AI",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 3, 53, 5),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chat, color: Colors.green),
                            iconSize: 28,
                            onPressed: () async {
                              final Uri whatsappUrl = Uri.parse("https://wa.me/+263710809945"); 
                              if (await canLaunchUrl(whatsappUrl)) {
                                await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                              }
                            },
                            tooltip: 'WhatsApp Support',
                          ),
                          const SizedBox(width: 30),
                          IconButton(
                            icon: const Icon(Icons.phone, color: Color.fromARGB(255, 3, 53, 5)),
                            iconSize: 28,
                            onPressed: () async {
                              final Uri phoneUrl = Uri.parse("tel:+263710809945"); 
                              if (await canLaunchUrl(phoneUrl)) {
                                await launchUrl(phoneUrl, mode: LaunchMode.externalApplication);
                              }
                            },
                            tooltip: 'Call Support',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
