import 'package:flutter/material.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/models/trip_item.dart';
import 'package:my_finance/pages/create_trip_page.dart';
import 'package:my_finance/pages/trip_detail_page.dart';
import 'package:my_finance/widgets/common/confirm_dialog.dart';
import 'package:my_finance/widgets/common/empty_state.dart';
import 'package:my_finance/widgets/sidebar.dart';
import 'package:my_finance/widgets/trips/trip_card.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  final TravelData travelData = TravelData();

  Future<void> _deleteTripWithConfirmation(
      BuildContext context, String tripId, String tripDestination) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Confirmar exclusão',
      message: 'Tem certeza que deseja excluir esta viagem e todos os seus gastos?',
    );

    if (confirm) {
      await travelData.deleteTrip(tripId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Viagem "$tripDestination" excluída')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Viagens'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: const Sidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTrip(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: travelData,
          builder: (context, _) {
            final trips = travelData.getAllTrips();

            if (trips.isEmpty) {
              return const EmptyState(
                icon: Icons.airplane_ticket_outlined,
                message: 'Nenhuma viagem cadastrada ainda',
              );
            }

            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return TripCard(
                  trip: trip,
                  totalExpenses: travelData.getTotalExpensesForTrip(trip.id),
                  onDelete: () => _deleteTripWithConfirmation(
                      context, trip.id, trip.destination),
                  onTap: () => _navigateToTripDetail(context, trip),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _navigateToCreateTrip(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripPage()),
    );
  }

  void _navigateToTripDetail(BuildContext context, TripItem trip) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailPage(trip: trip, tripId: trip.id),
      ),
    );
  }
}
