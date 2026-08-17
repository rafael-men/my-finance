import 'package:flutter/material.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/utils/date_formatters.dart';

class PurchaseListTile extends StatelessWidget {
  final ExpenseItem purchase;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PurchaseListTile({
    super.key,
    required this.purchase,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = purchase.category;

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
                  (category.color.r * 255).round(),
                  (category.color.g * 255).round(),
                  (category.color.b * 255).round(),
                  0.14,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category.label,
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
            Text(
              formatCurrency(purchase.amount),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color.fromARGB(255, 47, 9, 54),
              ),
            ),
            if (showActions) ...[
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 22),
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Excluir', style: TextStyle(color: Colors.red.shade600)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
