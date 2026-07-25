class Purchase{
  final int? id;
  final String itemName;
  final String supplier;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String date;

  Purchase({
    this.id,
    required this.itemName,
    required this.supplier,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.date,
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'itemName': itemName,
      'supplier': supplier,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'date': date,
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map){
    return Purchase(
      id: map['id'],
      itemName: map['itemName'],
      supplier: map['supplier'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
      totalPrice: map['totalPrice'],
      date: map['date'],
    );
  }
}