class Feed {
  final int? id;
  final String feedName;
  final String category;
  final double quantityKg;
  final double costPerKg;
  final String dateAdded;

  Feed({
    this.id,
    required this.feedName,
    required this.category,
    required this.quantityKg,
    required this.costPerKg,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'feedName': feedName,
      'category': category,
      'quantityKg': quantityKg,
      'costPerKg': costPerKg,
      'dateAdded': dateAdded,
    };
  }

  factory Feed.fromMap(Map<String, dynamic> map) {
    return Feed(
      id: map['id'],
      feedName: map['feedName'],
      category: map['category'],
      quantityKg: (map['quantityKg'] as num).toDouble(),
      costPerKg: (map['costPerKg'] as num).toDouble(),
      dateAdded: map['dateAdded'],
    );
  }
}