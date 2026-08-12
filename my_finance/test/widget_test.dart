
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/models/purchase_category.dart';
import 'package:my_finance/widgets/compras/purchase_list_tile.dart';

void main() {
  testWidgets('Purchase tile shows name, category and amount',
      (WidgetTester tester) async {
    final purchase = ExpenseItem(
      name: 'Arroz',
      amount: 10.0,
      date: DateTime(2026, 8, 12),
      category: PurchaseCategory.alimentacao,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PurchaseListTile(purchase: purchase),
        ),
      ),
    );

    expect(find.text('Arroz'), findsOneWidget);
    expect(find.text('Alimentação'), findsOneWidget);
    expect(find.text('R\$ 10.00'), findsOneWidget);
  });
}
