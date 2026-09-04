import 'package:flutter/material.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/models/travel_expense.dart';
import 'package:my_finance/models/trip_item.dart';
import 'package:my_finance/pages/add_travel_expense_page.dart';
import 'package:my_finance/utils/currencies.dart';
import 'package:my_finance/utils/date_formatters.dart';
import 'package:my_finance/widgets/common/confirm_dialog.dart';
import 'package:my_finance/widgets/common/empty_state.dart';
import 'package:my_finance/widgets/responsive_sidebar_scaffold.dart';
import 'package:my_finance/widgets/sidebar.dart';
import 'package:my_finance/widgets/trips/travel_expense_card.dart';

class TripDetailPage extends StatefulWidget {
  final TripItem trip;
  final String tripId;

  const TripDetailPage({
    super.key,
    required this.trip,
    required this.tripId,
  });

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  late TravelData travelData;

  @override
  void initState() {
    super.initState();
    travelData = TravelData();
    travelData.init();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return ResponsiveSidebarScaffold(
      title: trip.destination,
      destination: SidebarDestination.trips,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddExpense(context),
        backgroundColor: const Color.fromARGB(255, 47, 9, 54),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo gasto'),
      ),
      body: ListenableBuilder(
        listenable: travelData,
        builder: (context, _) {
          final total = travelData.getTotalExpensesForTrip(widget.tripId);
          final expenses = travelData.getExpensesForTrip(widget.tripId);

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
                          Row(
                            children: [
                              const Icon(Icons.flight, color: Colors.white70, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  trip.destination,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${formatDate(trip.startDate)} - ${formatDate(trip.endDate)}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Total gasto: ${currencyCode(trip.currency)} ${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Gastos da viagem',
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
                          '${expenses.length} ${expenses.length == 1 ? 'item' : 'itens'}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (expenses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: EmptyState(
                          icon: Icons.receipt_long_outlined,
                          message: 'Nenhum gasto registrado ainda.',
                        ),
                      )
                    else
                      ...expenses.map(
                        (expense) => TravelExpenseCard(
                          expense: expense,
                          currency: trip.currency,
                          onEdit: () =>
                              _navigateToAddExpense(context, expense: expense),
                          onDelete: () => _deleteExpense(expense),
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

  void _navigateToAddExpense(
    BuildContext context, {
    TravelExpense? expense,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTravelExpensePage(
          tripId: widget.tripId,
          currency: widget.trip.currency,
          expense: expense,
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _deleteExpense(TravelExpense expense) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Confirmar exclusão',
      message: 'Tem certeza que deseja excluir o gasto "${expense.description}"?',
    );

    if (confirm) {
      await travelData.deleteExpense(expense);
    }
  }
}
