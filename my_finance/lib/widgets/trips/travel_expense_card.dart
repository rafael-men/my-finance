import 'package:flutter/material.dart';
import 'package:my_finance/models/travel_expense.dart';
import 'package:my_finance/utils/currencies.dart';
import 'package:my_finance/utils/date_formatters.dart';

class TravelExpenseCard extends StatelessWidget {
  final TravelExpense expense;
  final String currency;

  const TravelExpenseCard({
    super.key,
    required this.expense,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          expense.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(formatDate(expense.date)),
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${currencyCode(currency)} ${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
