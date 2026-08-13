import 'package:flutter/material.dart';
import 'package:my_finance/models/expense_item.dart';

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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Color.fromRGBO(
              (category.color.r * 255).round(),
              (category.color.g * 255).round(),
              (category.color.b * 255).round(),
              0.14,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(category.icon, color: category.color),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                purchase.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Text(
              'R\$ ${purchase.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Color.fromARGB(255, 47, 9, 54),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            category.label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: showActions
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.edit_outlined),
                    color: Colors.blueGrey,
                    tooltip: 'Editar compra',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.redAccent,
                    tooltip: 'Excluir compra',
                    onPressed: onDelete,
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
