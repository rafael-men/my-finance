import 'package:flutter/material.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/widgets/common/empty_state.dart';
import 'package:my_finance/widgets/compras/purchase_list_tile.dart';

class HomeExpensesList extends StatelessWidget {
  final List<ExpenseItem> expenses;

  const HomeExpensesList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: expenses.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              message: 'Nenhuma compra encontrada neste mês.',
            )
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final item = expenses[index];
                return PurchaseListTile(purchase: item);
              },
            ),
    );
  }
}
