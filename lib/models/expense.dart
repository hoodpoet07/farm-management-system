class Expense{
  final int? id;
  final String title;
  final String category;
  final double amount;
  final String description;
  final String date;


Expense({
  this.id,
  required this.title,
  required this.category,
  required this.amount,
  required this.description,
  required this.date,
});

}