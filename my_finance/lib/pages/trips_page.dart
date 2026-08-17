import 'package:flutter/material.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/models/trip_item.dart';
import 'package:my_finance/pages/create_trip_page.dart';
import 'package:my_finance/pages/trip_detail_page.dart';
import 'package:my_finance/utils/exceptions/exceptions.dart';
import 'package:my_finance/widgets/common/confirm_dialog.dart';
import 'package:my_finance/widgets/common/empty_state.dart';
import 'package:my_finance/widgets/responsive_sidebar_scaffold.dart';
import 'package:my_finance/widgets/sidebar.dart';
import 'package:my_finance/widgets/trips/trip_card.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  bool _isLoading = true;
  String? _initError;
  TravelData? _travelData;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _travelData = TravelData();
      await _travelData!.init();
    } catch (e) {
      final error = AppException.from(e, origin: 'TripsPage');
      _initError = 'Erro ao carregar viagens: ${error.message}';
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

  Future<void> _deleteTrip(TripItem trip) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Confirmar exclusão',
      message: 'Tem certeza que deseja excluir a viagem "${trip.destination}" e todos os seus gastos?',
    );

    if (confirm) {
      await _travelData!.deleteTrip(trip.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viagem "${trip.destination}" excluída'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
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
          title: const Text('Minhas Viagens'),
          backgroundColor: const Color.fromARGB(255, 47, 9, 54),
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text(_initError!)),
      );
    }

    if (_isLoading || _travelData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F4F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ResponsiveSidebarScaffold(
      title: 'Minhas Viagens',
      destination: SidebarDestination.trips,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateTrip(context),
        backgroundColor: const Color.fromARGB(255, 47, 9, 54),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova viagem'),
      ),
      body: ListenableBuilder(
        listenable: _travelData!,
        builder: (context, _) {
          final trips = _travelData!.getAllTrips();

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
                            'Suas Viagens',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${trips.length} ${trips.length == 1 ? 'viagem cadastrada' : 'viagens cadastradas'}',
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
                            'Todas as viagens',
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
                          '${trips.length} ${trips.length == 1 ? 'item' : 'itens'}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (trips.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: EmptyState(
                          icon: Icons.airplane_ticket_outlined,
                          message: 'Nenhuma viagem cadastrada ainda.',
                        ),
                      )
                    else
                      ...trips.map(
                        (trip) => TripCard(
                          trip: trip,
                          totalExpenses: _travelData!.getTotalExpensesForTrip(trip.id),
                          onDelete: () => _deleteTrip(trip),
                          onTap: () => _navigateToTripDetail(context, trip),
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
