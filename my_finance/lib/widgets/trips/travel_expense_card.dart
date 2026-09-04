import 'package:flutter/material.dart';
import 'package:my_finance/models/travel_expense.dart';
import 'package:my_finance/utils/currencies.dart';
import 'package:my_finance/utils/date_formatters.dart';

class TravelExpenseCard extends StatelessWidget {
  final TravelExpense expense;
  final String currency;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TravelExpenseCard({
    super.key,
    required this.expense,
    required this.currency,
    this.onEdit,
    this.onDelete,
  });

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'alimentacao':
      case 'alimentação':
        return Icons.restaurant_outlined;
      case 'transporte':
        return Icons.directions_bus_outlined;
      case 'hospedagem':
        return Icons.hotel_outlined;
      case 'lazer':
        return Icons.sports_esports_outlined;
      case 'compras':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'alimentacao':
      case 'alimentação':
        return const Color(0xFF2E7D32);
      case 'transporte':
        return const Color(0xFF1565C0);
      case 'hospedagem':
        return const Color(0xFF6A1B9A);
      case 'lazer':
        return const Color(0xFFEF6C00);
      case 'compras':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF546E7A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(expense.category);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  (color.r * 255).round(),
                  (color.g * 255).round(),
                  (color.b * 255).round(),
                  0.14,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(_categoryIcon(expense.category), color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${expense.category} - ${formatDate(expense.date)}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currencyCode(currency)} ${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color.fromARGB(255, 47, 9, 54),
                  ),
                ),
                if (onEdit != null || onDelete != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 18,
                          color: Colors.grey.shade600,
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: onEdit,
                        ),
                      if (onDelete != null)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 18,
                          color: Colors.red.shade400,
                          tooltip: 'Excluir',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
