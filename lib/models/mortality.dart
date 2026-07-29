class Mortality {
  final int? id;
  final int batchId;
  final int quantity;
  final String reason;
  final String date;

  Mortality({
    this.id,
    required this.batchId,
    required this.quantity,
    required this.reason,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchId': batchId,
      'quantity': quantity,
      'reason': reason,
      'date': date,
    };
  }

  factory Mortality.fromMap(Map<String, dynamic> map) {
    return Mortality(
      id: map['id'],
      batchId: map['batchId'],
      quantity: map['quantity'],
      reason: map['reason'],
      date: map['date'],
    );
  }
}