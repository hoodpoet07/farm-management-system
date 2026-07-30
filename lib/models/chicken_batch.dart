class ChickenBatch{
  final int? id;
  final String batchName;
  final String breed;
  final int quantity;
  final String arrivalDate;
  final double costPerBird;

  ChickenBatch({
    this.id,
    required this.batchName,
    required this.breed,
    required this.quantity,
    required this.arrivalDate,
    required this.costPerBird,
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'batchName': batchName,
      'breed': breed,
      'quantity': quantity,
      'dateReceived': arrivalDate,
      'costPerBird': costPerBird,
    };
  }

  factory ChickenBatch.fromMap(Map<String, dynamic> map){
    return ChickenBatch(
      id: map['id'],
      batchName: map['batchName'],
      breed: map['breed'],
      quantity: map['quantity'],
      arrivalDate: map['dateReceived'],
      costPerBird: map['costPerBird'],
    );
  }
}