import 'package:flutter/material.dart';
import 'package:my_finance/utils/date_formatters.dart';

class PurchaseMonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final bool isCurrentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PurchaseMonthSelector({
    super.key,
    required this.selectedMonth,
    required this.isCurrentMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Mês anterior',
              onPressed: onPrevious,
            ),
            Text(
              '${fullMonthName(selectedMonth.month)} ${selectedMonth.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Próximo mês',
              onPressed: isCurrentMonth ? null : onNext,
            ),
          ],
        ),
      ),
    );
  }
}
