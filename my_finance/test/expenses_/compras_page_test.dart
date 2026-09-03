import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_finance/data/expense_data.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/models/purchase_category.dart';
import 'package:my_finance/widgets/compras/filter-expenses.dart';
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
      expect(find.text('R\$ 34,99'), findsOneWidget);
    });

    testWidgets('não exibe ações por padrão', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PurchaseListTile(purchase: _purchase()),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('exibe menu de editar e excluir com showActions',
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

      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Excluir'), findsOneWidget);
    });

    testWidgets('dispara onEdit e onDelete pelo menu', (tester) async {
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

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      expect(editCalls, 1);
      expect(deleteCalls, 0);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
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

  group('PurchaseFilter', () {
    ExpenseItem item({
      double amount = 50.0,
      PurchaseCategory category = PurchaseCategory.alimentacao,
    }) {
      return ExpenseItem(
        name: 'compra',
        amount: amount,
        date: DateTime(2026, 8, 10),
        category: category,
      );
    }

    test('isActive é false sem filtros', () {
      const filter = PurchaseFilter();
      expect(filter.isActive, isFalse);
    });

    test('isActive é true com categoria', () {
      const filter = PurchaseFilter(categories: {PurchaseCategory.outros});
      expect(filter.isActive, isTrue);
    });

    test('filtrar por categoria mantém apenas a categoria selecionada', () {
      const filter = PurchaseFilter(categories: {PurchaseCategory.roupas});

      expect(filter.matches(item(category: PurchaseCategory.roupas)), isTrue);
      expect(
        filter.matches(item(category: PurchaseCategory.alimentacao)),
        isFalse,
      );
    });

    test('filtrar por faixa de valor mantém valores dentro do intervalo', () {
      const filter = PurchaseFilter(minAmount: 30, maxAmount: 80);

      expect(filter.matches(item(amount: 30)), isTrue);
      expect(filter.matches(item(amount: 80)), isTrue);
      expect(filter.matches(item(amount: 50)), isTrue);
      expect(filter.matches(item(amount: 29)), isFalse);
      expect(filter.matches(item(amount: 81)), isFalse);
    });

    test('filtrar por valor mínimo apenas', () {
      const filter = PurchaseFilter(minAmount: 40);

      expect(filter.matches(item(amount: 60)), isTrue);
      expect(filter.matches(item(amount: 39)), isFalse);
    });

    test('filtrar por valor máximo apenas', () {
      const filter = PurchaseFilter(maxAmount: 60);

      expect(filter.matches(item(amount: 30)), isTrue);
      expect(filter.matches(item(amount: 61)), isFalse);
    });

    test('combina categoria e faixa de valor', () {
      const filter = PurchaseFilter(
        categories: {PurchaseCategory.entretenimento},
        minAmount: 20,
        maxAmount: 100,
      );

      final match = item(
        amount: 50,
        category: PurchaseCategory.entretenimento,
      );
      expect(filter.matches(match), isTrue);

      final wrongCategory = item(
        amount: 50,
        category: PurchaseCategory.roupas,
      );
      expect(filter.matches(wrongCategory), isFalse);

      expect(filter.matches(item(amount: 150, category: PurchaseCategory.entretenimento)),
          isFalse);
    });

    test('sem filtros ativos corresponde a qualquer item', () {
      const filter = PurchaseFilter();
      expect(filter.matches(item(amount: 999, category: PurchaseCategory.roupas)), isTrue);
    });
  });

  group('showFilterExpensesDialog', () {
    Future<PurchaseFilter?> openFilter(
      WidgetTester tester, {
      PurchaseFilter current = const PurchaseFilter(),
      List<ExpenseItem> purchases = const [],
    }) async {
      PurchaseFilter? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showFilterExpensesDialog(
                      context,
                      current: current,
                      purchases: purchases,
                    );
                  },
                  child: const Text('abrir-filtro'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir-filtro'));
      await tester.pumpAndSettle();
      return result;
    }

    final fixtures = [
      ExpenseItem(
        name: 'Feira',
        amount: 34.99,
        date: DateTime(2026, 8, 10),
        category: PurchaseCategory.alimentacao,
      ),
      ExpenseItem(
        name: 'Camiseta',
        amount: 45.00,
        date: DateTime(2026, 8, 11),
        category: PurchaseCategory.roupas,
      ),
      ExpenseItem(
        name: 'Cinema',
        amount: 60.00,
        date: DateTime(2026, 8, 12),
        category: PurchaseCategory.entretenimento,
      ),
    ];

    testWidgets('exibe título e opções de categoria', (tester) async {
      await openFilter(tester, purchases: fixtures);

      expect(find.text('Filtrar compras'), findsOneWidget);
      expect(find.text('Alimentação'), findsOneWidget);
      expect(find.text('Roupas'), findsOneWidget);
      expect(find.text('Entretenimento'), findsOneWidget);
      expect(find.byType(RangeSlider), findsOneWidget);
    });

    testWidgets('cancelar retorna null', (tester) async {
      PurchaseFilter? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showFilterExpensesDialog(
                      context,
                      current: const PurchaseFilter(),
                      purchases: fixtures,
                    );
                  },
                  child: const Text('abrir-filtro'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir-filtro'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('aplicar filtro por categoria retorna categoria selecionada',
        (tester) async {
      PurchaseFilter? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showFilterExpensesDialog(
                      context,
                      current: const PurchaseFilter(),
                      purchases: fixtures,
                    );
                  },
                  child: const Text('abrir-filtro'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir-filtro'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Roupas'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.categories, {PurchaseCategory.roupas});
    });

    testWidgets('limpar retorna um filtro vazio', (tester) async {
      PurchaseFilter? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showFilterExpensesDialog(
                      context,
                      current: const PurchaseFilter(),
                      purchases: fixtures,
                    );
                  },
                  child: const Text('abrir-filtro'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir-filtro'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Limpar'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.isActive, isFalse);
    });
  });
}
