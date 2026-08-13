import 'package:flutter/material.dart';
import 'package:my_finance/data/expense_data.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/utils/date_formatters.dart';
import 'package:my_finance/utils/exceptions/exceptions.dart';
import 'package:my_finance/widgets/common/confirm_dialog.dart';
import 'package:my_finance/widgets/common/empty_state.dart';
import 'package:my_finance/widgets/compras/purchase_form_dialog.dart';
import 'package:my_finance/widgets/compras/purchase_month_selector.dart';
import 'package:my_finance/widgets/compras/purchase_list_tile.dart';
import 'package:my_finance/widgets/responsive_sidebar_scaffold.dart';
import 'package:my_finance/widgets/sidebar.dart';

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  bool _isLoading = true;
  String? _initError;
  ExpenseData? _expenseData;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _expenseData = ExpenseData();
      await _expenseData!.init();
    } catch (e) {
      final error = AppException.from(e, origin: 'ComprasPage');
      _initError = 'Erro ao carregar compras: ${error.message}';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return now.month == _selectedMonth.month && now.year == _selectedMonth.year;
  }

  void _changeMonth(int delta) {
    final now = DateTime.now();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    if (next.year > now.year ||
        (next.year == now.year && next.month > now.month)) {
      return;
    }
    setState(() {
      _selectedMonth = next;
    });
  }

  List<ExpenseItem> _getPurchasesOfMonth() {
    if (_expenseData == null) return [];
    return _expenseData!.getExpensesByMonth(
      _selectedMonth.month,
      _selectedMonth.year,
    );
  }

  double _totalOfMonth() {
    final purchases = _getPurchasesOfMonth();
    return purchases.fold<double>(0, (total, p) => total + p.amount);
  }

  Future<void> _deletePurchase(ExpenseItem purchase) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Confirmar exclusão',
      message: 'Tem certeza que deseja excluir a compra "${purchase.name}"?',
    );

    if (confirm) {
      await _expenseData!.deleteExpense(purchase);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F4F8),
        appBar: AppBar(
          title: const Text('Minhas Compras'),
          backgroundColor: const Color.fromARGB(255, 47, 9, 54),
          foregroundColor: Colors.white,
        ),
        drawer: const Drawer(child: Sidebar()),
        body: Center(child: Text(_initError!)),
      );
    }

    if (_isLoading || _expenseData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F4F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ResponsiveSidebarScaffold(
      title: 'Minhas Compras',
      destination: SidebarDestination.compras,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPurchaseFormDialog(context, _expenseData!),
        backgroundColor: const Color.fromARGB(255, 47, 9, 54),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova compra'),
      ),
      body: ListenableBuilder(
        listenable: _expenseData!,
        builder: (context, _) {
          final purchases = _getPurchasesOfMonth();
          final total = _totalOfMonth();
          return RefreshIndicator(
            onRefresh: () async {
              if (mounted) {
                setState(() {});
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2F0936), Color(0xFF5A2E6F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bem Vindo, Usuário',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const SizedBox(height: 12),
                          Text(
                            'Total gasto no mês: R\$ ${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    PurchaseMonthSelector(
                      selectedMonth: _selectedMonth,
                      isCurrentMonth: _isCurrentMonth,
                      onPrevious: () => _changeMonth(-1),
                      onNext: () => _changeMonth(1),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Compras de ${fullMonthName(_selectedMonth.month)} '
                            '${_selectedMonth.year}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${purchases.length} ${purchases.length == 1 ? 'item' : 'itens'}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (purchases.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: EmptyState(
                          icon: Icons.shopping_cart_outlined,
                          message: 'Nenhuma compra neste mês.',
                        ),
                      )
                    else
                      ...purchases.map(
                        (purchase) => PurchaseListTile(
                          purchase: purchase,
                          showActions: _isCurrentMonth,
                          onEdit: () => showPurchaseFormDialog(
                            context,
                            _expenseData!,
                            existing: purchase,
                          ),
                          onDelete: () => _deletePurchase(purchase),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
