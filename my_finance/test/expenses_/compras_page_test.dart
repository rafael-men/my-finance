import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_finance/data/expense_data.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/models/purchase_category.dart';
import 'package:my_finance/widgets/compras/purchase_form_dialog.dart';
import 'package:my_finance/widgets/compras/purchase_list_tile.dart';
import 'package:my_finance/widgets/compras/purchase_month_selector.dart';

ExpenseItem _purchase({
  String name = 'Feira do mês',
  double amount = 34.99,
  PurchaseCategory category = PurchaseCategory.alimentacao,
}) {
  return ExpenseItem(
    name: name,
    amount: amount,
    date: DateTime(2026, 8, 10),
    category: category,
  );
}

void main() {
  group('PurchaseMonthSelector', () {
    testWidgets('exibe o mês e ano selecionados', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseMonthSelector(
              selectedMonth: DateTime(2026, 8, 1),
              isCurrentMonth: false,
              onPrevious: () {},
              onNext: () {},
            ),
          ),
        ),
      );

      expect(find.text('Agosto 2026'), findsOneWidget);
    });

    testWidgets('dispara onPrevious ao tocar no mês anterior', (tester) async {
      var previousCalls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseMonthSelector(
              selectedMonth: DateTime(2026, 8, 1),
              isCurrentMonth: false,
              onPrevious: () => previousCalls++,
              onNext: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Mês anterior'));
      expect(previousCalls, 1);
    });

    testWidgets('dispara onNext quando não é o mês atual', (tester) async {
      var nextCalls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseMonthSelector(
              selectedMonth: DateTime(2026, 7, 1),
              isCurrentMonth: false,
              onPrevious: () {},
              onNext: () => nextCalls++,
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Próximo mês'));
      expect(nextCalls, 1);
    });

    testWidgets('desabilita o próximo mês quando é o mês atual',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseMonthSelector(
              selectedMonth: DateTime(2026, 8, 1),
              isCurrentMonth: true,
              onPrevious: () {},
              onNext: () {},
            ),
          ),
        ),
      );

      final nextButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(nextButton.onPressed, isNull);
    });
  });

  group('PurchaseListTile', () {
    testWidgets('exibe nome, categoria e valor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseListTile(purchase: _purchase()),
          ),
        ),
      );

      expect(find.text('Feira do mês'), findsOneWidget);
      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('R\$ 34.99'), findsOneWidget);
    });

    testWidgets('não exibe ações por padrão', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseListTile(purchase: _purchase()),
          ),
        ),
      );

      expect(find.byTooltip('Editar compra'), findsNothing);
      expect(find.byTooltip('Excluir compra'), findsNothing);
    });

    testWidgets('exibe ações de editar e excluir com showActions',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseListTile(
              purchase: _purchase(),
              showActions: true,
            ),
          ),
        ),
      );

      expect(find.byTooltip('Editar compra'), findsOneWidget);
      expect(find.byTooltip('Excluir compra'), findsOneWidget);
    });

    testWidgets('dispara onEdit e onDelete', (tester) async {
      var editCalls = 0;
      var deleteCalls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseListTile(
              purchase: _purchase(),
              showActions: true,
              onEdit: () => editCalls++,
              onDelete: () => deleteCalls++,
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('Editar compra'));
      expect(editCalls, 1);
      expect(deleteCalls, 0);

      await tester.tap(find.byTooltip('Excluir compra'));
      expect(editCalls, 1);
      expect(deleteCalls, 1);
    });
  });

  group('showPurchaseFormDialog', () {
    Future<void> openForm(WidgetTester tester, {ExpenseItem? existing}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showPurchaseFormDialog(
                    context,
                    ExpenseData(),
                    existing: existing,
                  ),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    final nameField = find.byType(TextFormField).at(0);
    final amountField = find.byType(TextFormField).at(1);

    String fieldText(WidgetTester tester, Finder field) {
      return tester.widget<TextFormField>(field).controller!.text;
    }

    testWidgets('abre em modo de nova compra', (tester) async {
      await openForm(tester);

      expect(find.text('Nova compra'), findsOneWidget);
      expect(fieldText(tester, nameField), isEmpty);
      expect(fieldText(tester, amountField), isEmpty);
    });

    testWidgets('abre em modo de edição com valor formatado com vírgula',
        (tester) async {
      await openForm(tester, existing: _purchase());

      expect(find.text('Editar compra'), findsOneWidget);
      expect(fieldText(tester, nameField), 'Feira do mês');
      expect(fieldText(tester, amountField), '34,99');
    });

    testWidgets('nome aceita apenas letras', (tester) async {
      await openForm(tester);

      await tester.enterText(nameField, 'Feira123#');
      await tester.pump();

      expect(fieldText(tester, nameField), 'Feira');
    });

    testWidgets('valor aceita vírgula como separador decimal', (tester) async {
      await openForm(tester);

      await tester.enterText(amountField, '34,99');
      await tester.pump();

      expect(fieldText(tester, amountField), '34,99');
    });

    testWidgets('valor converte ponto em vírgula', (tester) async {
      await openForm(tester);

      await tester.enterText(amountField, '34.99');
      await tester.pump();

      expect(fieldText(tester, amountField), '34,99');
    });

    testWidgets('valor limita a duas casas decimais', (tester) async {
      await openForm(tester);

      await tester.enterText(amountField, '12,345');
      await tester.pump();

      expect(fieldText(tester, amountField), '12,34');
    });

    testWidgets('valor permite apenas uma vírgula', (tester) async {
      await openForm(tester);

      await tester.enterText(amountField, '1,2,3');
      await tester.pump();

      expect(fieldText(tester, amountField), '1,23');
    });

    testWidgets('valor remove caracteres inválidos', (tester) async {
      await openForm(tester);

      await tester.enterText(amountField, 'abc!?');
      await tester.pump();

      expect(fieldText(tester, amountField), isEmpty);
    });

    testWidgets('valida campos obrigatórios', (tester) async {
      await openForm(tester);

      await tester.tap(find.text('Adicionar'));
      await tester.pump();

      expect(find.text('Informe o nome da compra'), findsOneWidget);
      expect(find.text('Informe o valor'), findsOneWidget);
    });

    testWidgets('valida valor maior que zero', (tester) async {
      await openForm(tester);

      await tester.enterText(nameField, 'Feira');
      await tester.enterText(amountField, '0');
      await tester.pump();

      await tester.tap(find.text('Adicionar'));
      await tester.pump();

      expect(find.text('Valor deve ser maior que zero'), findsOneWidget);
    });
  });
}
