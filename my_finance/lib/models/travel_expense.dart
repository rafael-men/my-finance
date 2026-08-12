import 'package:cloud_firestore/cloud_firestore.dart';

class TravelExpense {
  final String id;
  final String tripId;
  final String description;
  final double amount;
  final DateTime date;
  final String category;

  TravelExpense({
    this.id = '',
    required this.tripId,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
    };
  }

  factory TravelExpense.fromMap(Map<String, dynamic> map, [String id = '']) {
    final dateValue = map['date'];
    return TravelExpense(
      id: id,
      tripId: map['tripId'] as String? ?? '',
      description: map['description'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: dateValue is Timestamp
          ? dateValue.toDate()
          : (map['date'] as DateTime?) ?? DateTime.now(),
      category: map['category'] as String? ?? '',
    );
  }
}
