class Sale {
  final int? id;
  final int batchId;
  final int quantity;
  final double pricePerBird;
  final double totalAmount;
  final String customerName;
  final String date;

  Sale({
    this.id,
    required this.batchId,
    required this.quantity,
    required this.pricePerBird,
    required this.totalAmount,
    required this.customerName,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchId': batchId,
      'quantity': quantity,
      'pricePerBird': pricePerBird,
      'totalAmount': totalAmount,
      'customerName': customerName,
      'date': date,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      batchId: map['batchId'],
      quantity: map['quantity'],
      pricePerBird: (map['pricePerBird'] as num).toDouble(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      customerName: map['customerName'] ?? '',
      date: map['date'],
    );
  }
}