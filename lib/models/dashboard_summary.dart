class DashboardSummary {
  final double totalExpenses;
  final double totalSales;
  final double totalPurchases;
  final int totalChickens;
  final double feedRemaining;

  DashboardSummary({
    required this.totalExpenses,
    required this.totalSales,
    required this.totalPurchases,
    required this.totalChickens,
    required this.feedRemaining,
  });

  factory DashboardSummary.fromJson(Map<String,dynamic> json){
    return DashboardSummary(
      totalExpenses: (json['total_expenses'] ?? json['totalExpenses'] ?? 0).toDouble(), 
      totalSales: (json['total_sales'] ?? json['totalSales'] ?? 0).toDouble(), 
      totalPurchases: (json['total_purchases'] ?? json['totalPurchases'] ?? 0).toDouble(), 
      totalChickens: (json['total_chickens'] ?? json['totalChickens'] ?? 0) as int, 
      feedRemaining: (json['feed_remaining'] ?? json['feedRemaining'] ?? 0).toDouble(),
      );
  }

  factory DashboardSummary.empty(){
    return DashboardSummary(totalExpenses: 0.0, totalSales: 0.0, totalPurchases: 0.0, totalChickens: 0, feedRemaining: 0.0,);
  }
}