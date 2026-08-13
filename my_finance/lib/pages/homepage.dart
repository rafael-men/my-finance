import 'package:flutter/material.dart';
import 'package:my_finance/data/expense_data.dart';
import 'package:my_finance/data/settings_data.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/utils/date_formatters.dart';
import 'package:my_finance/utils/exceptions/exceptions.dart';
import 'package:my_finance/widgets/home/home_expenses_list.dart';
import 'package:my_finance/widgets/home/monthly_expenses_chart.dart';
import 'package:my_finance/widgets/home/spending_limit_section.dart';
import 'package:my_finance/widgets/responsive_sidebar_scaffold.dart';
import 'package:my_finance/widgets/sidebar.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  ExpenseData? expenseData;
  final TextEditingController _limitController = TextEditingController();
  double spendingLimit = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeExpenseData();
  }

  Future<void> _initializeExpenseData() async {
    try {
      expenseData = ExpenseData();
      await expenseData!.init();

      spendingLimit = await SettingsData().getSpendingLimit();
      _limitController.text = spendingLimit > 0 ? spendingLimit.toString() : '';

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      final error = AppException.from(e, origin: 'Homepage');
      debugPrint('Erro ao inicializar ExpenseData: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    if (expenseData == null) return;

    final limit = await SettingsData().getSpendingLimit();
    if (!mounted) return;
    setState(() {
      spendingLimit = limit;
      _limitController.text = limit > 0 ? limit.toString() : '';
    });
  }

  Future<void> _saveSpendingLimit(double limit) async {
    await SettingsData().saveSpendingLimit(limit);
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  List<ExpenseItem> getCurrentMonthExpenses() {
    if (expenseData == null) return [];

    final now = DateTime.now();
    return expenseData!.getExpensesByMonth(now.month, now.year);
  }

  Map<String, double> getMonthlyExpenses() {
    if (expenseData == null) return {};

    final now = DateTime.now();
    final Map<String, double> monthlyTotals = {};

    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthKey =
          '${shortMonthName(monthDate.month)}/${monthDate.year.toString().substring(2)}';
      monthlyTotals[monthKey] = 0.0;
    }

    for (var expense in expenseData!.getAllExpenseList()) {
      final monthKey =
          '${shortMonthName(expense.date.month)}/${expense.date.year.toString().substring(2)}';

      if (monthlyTotals.containsKey(monthKey)) {
        monthlyTotals[monthKey] =
            (monthlyTotals[monthKey] ?? 0) + expense.amount;
      }
    }

    return monthlyTotals;
  }

  double getTotalSpentCurrentMonth() {
    if (expenseData == null) return 0.0;

    final now = DateTime.now();
    final expensesThisMonth = expenseData!.getAllExpenseList().where((expense) {
      return expense.date.month == now.month && expense.date.year == now.year;
    });

    return expensesThisMonth.fold<double>(0, (total, e) => total + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F4F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (expenseData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F4F8),
        body: Center(child: Text('Erro ao carregar dados')),
      );
    }

    final filteredExpenses = getCurrentMonthExpenses();

    final now = DateTime.now();
    final monthName = fullMonthName(now.month);
    final year = now.year;
    final totalSpent = getTotalSpentCurrentMonth();
    final monthlyData = getMonthlyExpenses();

    return ResponsiveSidebarScaffold(
      title: 'Minhas Finanças',
      destination: SidebarDestination.home,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Atualizar dados',
          onPressed: _refreshData,
        ),
      ],
      body: ListenableBuilder(
        listenable: expenseData!,
        builder: (context, _) => RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Olá, seja bem-vindo!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Mês atual: $monthName',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text('Ano: $year', style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 16),
                  Text(
                    'Total gasto no mês: R\$ ${totalSpent.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 53, 41, 72),
                    ),
                  ),

                  const SizedBox(height: 16),
                  SpendingLimitSection(
                    controller: _limitController,
                    spendingLimit: spendingLimit,
                    totalSpent: totalSpent,
                    onChanged: (newLimit) {
                      setState(() {
                        spendingLimit = newLimit;
                      });
                      _saveSpendingLimit(newLimit);
                    },
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Gastos por mês (últimos 6 meses):',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  MonthlyExpensesChart(monthlyData: monthlyData),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Compras deste mês',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${filteredExpenses.length} itens',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  HomeExpensesList(expenses: filteredExpenses),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
