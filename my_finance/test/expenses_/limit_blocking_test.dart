import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_finance/data/expense_data.dart';
import 'package:my_finance/data/expense_repository.dart';
import 'package:my_finance/data/settings_data.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/models/purchase_category.dart';
import 'package:my_finance/widgets/compras/purchase_form_dialog.dart';
import 'package:my_finance/widgets/home/spending_limit_section.dart';

class _FakeExpenseRepository implements ExpenseRepository {
  List<ExpenseItem> expenses;

  _FakeExpenseRepository(this.expenses);

  @override
  Future<void> add(ExpenseItem expense) async {
    expenses.add(expense);
  }

  @override
  Future<void> delete(ExpenseItem expense) async {
    expenses.remove(expense);
  }

  @override
  Future<List<ExpenseItem>> fetchAll() async => List.from(expenses);

  @override
  Future<void> update(
    ExpenseItem oldExpense,
    ExpenseItem updatedExpense,
  ) async {
    final index = expenses.indexOf(oldExpense);
    if (index != -1) expenses[index] = updatedExpense;
  }

  @override
  Stream<List<ExpenseItem>> watchAll() async* {
    yield List.from(expenses);
  }
}

class _FakeSpendingLimitStore implements SpendingLimitStore {
  double limit;

  _FakeSpendingLimitStore(this.limit);

  @override
  Future<double> getSpendingLimit() async => limit;

  @override
  Future<void> saveSpendingLimit(double limit) async {
    this.limit = limit;
  }
}

ExpenseItem _expense({
  String name = 'Feira',
  double amount = 10.0,
  PurchaseCategory category = PurchaseCategory.alimentacao,
  DateTime? date,
}) {
  return ExpenseItem(
    name: name,
    amount: amount,
    date: date ?? DateTime.now(),
    category: category,
  );
}

void main() {
  group('Bloqueio por limite mensal', () {
    Future<void> openForm(
      WidgetTester tester, {
      required ExpenseData expenseData,
      required SettingsData settingsData,
      ExpenseItem? existing,
    }) async {
      await expenseData.init();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showPurchaseFormDialog(
                    context,
                    expenseData,
                    settingsData: settingsData,
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

    testWidgets('bloqueia quando a nova compra excede o limite do mês',
        (tester) async {
      final repository = _FakeExpenseRepository([
        _expense(name: 'Gasto existente', amount: 80.0),
      ]);
      final expenseData = ExpenseData.withRepository(repository);
      final settingsData = SettingsData(
        store: _FakeSpendingLimitStore(100.0),
      );

      await openForm(
        tester,
        expenseData: expenseData,
        settingsData: settingsData,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome da compra'),
        'Nova compra',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Valor'),
        '30,00',
      );

      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.text('Compras Bloqueadas'), findsOneWidget);
      expect(find.text('Limite de gastos atingido!'), findsOneWidget);
      expect(repository.expenses.length, 1,
          reason: 'A compra não deve ser salva quando bloqueada');
    });

    testWidgets(
        'alerta e bloqueia ao salvar compra muito acima do limite (2000 / limite 300)',
        (tester) async {
      final repository = _FakeExpenseRepository([]);
      final expenseData = ExpenseData.withRepository(repository);
      final settingsData = SettingsData(
        store: _FakeSpendingLimitStore(300.0),
      );

      await openForm(
        tester,
        expenseData: expenseData,
        settingsData: settingsData,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome da compra'),
        'Compra cara',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Valor'),
        '2000,00',
      );

      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.text('Compras Bloqueadas'), findsOneWidget);
      expect(find.text('Limite de gastos atingido!'), findsOneWidget);
      expect(find.textContaining('Limite definido: R\$ 300,00'), findsOneWidget);
      expect(repository.expenses.length, 0,
          reason: 'A compra de 2000 não deve ser salva com limite de 300');
    });

    testWidgets('permite quando o total fica exatamente no limite',
        (tester) async {
      final repository = _FakeExpenseRepository([
        _expense(name: 'Gasto existente', amount: 70.0),
      ]);
      final expenseData = ExpenseData.withRepository(repository);
      final settingsData = SettingsData(
        store: _FakeSpendingLimitStore(100.0),
      );

      await openForm(
        tester,
        expenseData: expenseData,
        settingsData: settingsData,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome da compra'),
        'Nova compra',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Valor'),
        '30,00',
      );

      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.text('Compras Bloqueadas'), findsNothing);
      expect(repository.expenses.length, 2,
          reason: 'A compra deve ser salva quando dentro do limite');
    });

    testWidgets(
        'bloqueia toda nova compra quando o total do mês já ultrapassa o limite',
        (tester) async {
      final repository = _FakeExpenseRepository([
        _expense(name: 'Gasto alto', amount: 120.0),
      ]);
      final expenseData = ExpenseData.withRepository(repository);
      final settingsData = SettingsData(
        store: _FakeSpendingLimitStore(100.0),
      );

      await openForm(
        tester,
        expenseData: expenseData,
        settingsData: settingsData,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome da compra'),
        'Qualquer compra',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Valor'),
        '1,00',
      );

      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.text('Compras Bloqueadas'), findsOneWidget);
      expect(find.text('Limite de gastos atingido!'), findsOneWidget);
      expect(find.textContaining('Gasto atual'), findsOneWidget);
      expect(repository.expenses.length, 1,
          reason: 'Nenhuma compra adicional deve ser salva quando já está no limite');
    });

    testWidgets('permite quando não há limite definido', (tester) async {
      final repository = _FakeExpenseRepository([]);
      final expenseData = ExpenseData.withRepository(repository);
      final settingsData = SettingsData(
        store: _FakeSpendingLimitStore(0.0),
      );

      await openForm(
        tester,
        expenseData: expenseData,
        settingsData: settingsData,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome da compra'),
        'Compra livre',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Valor'),
        '500,00',
      );

      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      expect(find.text('Compras Bloqueadas'), findsNothing);
      expect(repository.expenses.length, 1);
    });

    testWidgets(
        'já bloqueado: excede o limite apenas ao somar a edição de valor',
        (tester) async {
      final original = _expense(
        name: 'Compra original',
        amount: 40.0,
      );
      final repository = _FakeExpenseRepository([original]);
      final expenseData = ExpenseData.withRepository(repository);
      final settingsData = SettingsData(
        store: _FakeSpendingLimitStore(50.0),
      );

      await openForm(
        tester,
        expenseData: expenseData,
        settingsData: settingsData,
        existing: original,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Valor'),
        '20,00',
      );

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Compras Bloqueadas'), findsNothing);
      expect(repository.expenses.single.amount, 20.0,
          reason: 'Edição para dentro do limite deve salvar');
    });

    testWidgets(
        'bloqueia quando a edição de valor excederia o limite do mês',
        (tester) async {
      final original = _expense(
        name: 'Compra original',
        amount: 40.0,
      );
      final repository = _FakeExpenseRepository([original]);
      final expenseData = ExpenseData.withRepository(repository);
      final settingsData = SettingsData(
        store: _FakeSpendingLimitStore(50.0),
      );

      await openForm(
        tester,
        expenseData: expenseData,
        settingsData: settingsData,
        existing: original,
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Valor'),
        '60,00',
      );

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Compras Bloqueadas'), findsOneWidget);
      expect(repository.expenses.single.amount, 40.0,
          reason: 'A edição não deve salvar quando bloqueada');
    });
  });

  group('Exibição do aviso de limite ultrapassado', () {
    testWidgets('mostra aviso quando as compras do mês ultrapassam o limite',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingLimitSection(
              spendingLimit: 100.0,
              totalSpent: 150.0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Limite ultrapassado!'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('mostra progresso normal quando não ultrapassa o limite',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingLimitSection(
              spendingLimit: 100.0,
              totalSpent: 60.0,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.textContaining('Limite ultrapassado!'), findsNothing);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });
}