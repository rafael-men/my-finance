import 'package:flutter/material.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/models/trip_item.dart';
import 'package:my_finance/pages/add_travel_expense_page.dart';
import 'package:my_finance/widgets/common/empty_state.dart';
import 'package:my_finance/widgets/trips/travel_expense_card.dart';
import 'package:my_finance/widgets/trips/trip_total_card.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.destination),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpense(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListenableBuilder(
              listenable: travelData,
              builder: (context, _) {
                final total = travelData.getTotalExpensesForTrip(widget.tripId);
                return TripTotalCard(
                  currency: widget.trip.currency,
                  total: total,
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Gastos da viagem:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListenableBuilder(
                listenable: travelData,
                builder: (context, _) {
                  final expenses =
                      travelData.getExpensesForTrip(widget.tripId);

                  if (expenses.isEmpty) {
                    return const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: 'Nenhum gasto registrado ainda',
                    );
                  }

                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      return TravelExpenseCard(
                        expense: expenses[index],
                        currency: widget.trip.currency,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddExpense(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTravelExpensePage(tripId: widget.tripId),
      ),
    );
    setState(() {});
  }
}
