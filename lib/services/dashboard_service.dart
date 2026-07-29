import '../database/database_helper.dart';
import '../models/dashboard_summary.dart';

class DashboardService {

  Future<DashboardSummary> getSummary() async {

    final expenses =
        await DatabaseHelper.instance.getAllExpenses();

    final purchases =
        await DatabaseHelper.instance.getAllPurchases();

    double totalExpenses = 0;

    for (final expense in expenses) {
      totalExpenses += expense.amount;
    }

    double totalPurchases = 0;

    for (final purchase in purchases) {
      totalPurchases += purchase.totalPrice;
    }

    return DashboardSummary(
      totalExpenses: totalExpenses,
      totalSales: 0,
      totalPurchases: totalPurchases,
      totalChickens: 0,
      feedRemaining: 0,
    );
  }
}