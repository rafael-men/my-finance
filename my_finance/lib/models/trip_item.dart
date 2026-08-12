import 'package:cloud_firestore/cloud_firestore.dart';

class TripItem {
  final String id;
  final String destination;
  final String currency;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;

  TripItem({
    this.id = '',
    required this.destination,
    required this.currency,
    required this.startDate,
    required this.endDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'destination': destination,
      'currency': currency,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'notes': notes,
    };
  }

  factory TripItem.fromMap(Map<String, dynamic> map, [String id = '']) {
    return TripItem(
      id: id,
      destination: map['destination'] as String? ?? '',
      currency: map['currency'] as String? ?? '',
      startDate: _parseDate(map['startDate']),
      endDate: _parseDate(map['endDate']),
      notes: map['notes'] as String?,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
