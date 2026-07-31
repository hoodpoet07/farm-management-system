import '../database/database_helper.dart';
import '../models/dashboard_summary.dart';

class DashboardService {
  
    Future<DashboardSummary> getSummary() async {
    final totalExpenses = await DatabaseHelper.instance.getTotalExpensesAmount();
    final totalPurchases = await DatabaseHelper.instance.getTotalPurchasesAmount();
    final chickens = await DatabaseHelper.instance.getTotalChickensCount();
    final sales = await DatabaseHelper.instance.getTotalSalesAmount();

    return DashboardSummary(
      totalExpenses: totalExpenses,
      totalSales: sales,
      totalPurchases: totalPurchases,
      totalChickens: chickens,
      feedRemaining: 0,
    );
  }
}