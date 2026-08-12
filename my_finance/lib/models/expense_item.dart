import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_finance/models/purchase_category.dart';

class ExpenseItem {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final PurchaseCategory category;

  ExpenseItem({
    this.id = '',
    required this.name,
    required this.amount,
    required this.date,
    this.category = PurchaseCategory.outros,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category.name,
    };
  }

  factory ExpenseItem.fromMap(Map<String, dynamic> map, [String id = '']) {
    final dateValue = map['date'];
    return ExpenseItem(
      id: id,
      name: map['name'] as String? ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '') ?? 0.0,
      category: PurchaseCategory.fromValue(map['category'] as String?),
      date: dateValue is Timestamp
          ? dateValue.toDate()
          : (map['date'] as DateTime?) ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'ExpenseItem(id: $id, name: $name, amount: $amount, date: $date, category: ${category.name})';
  }
}
