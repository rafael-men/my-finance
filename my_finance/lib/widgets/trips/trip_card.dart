import 'package:flutter/material.dart';
import 'package:my_finance/models/trip_item.dart';
import 'package:my_finance/utils/currencies.dart';
import 'package:my_finance/utils/date_formatters.dart';

class TripCard extends StatelessWidget {
  final TripItem trip;
  final double totalExpenses;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.trip,
    required this.totalExpenses,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.deepPurple[50],
      child: ListTile(
        title: Text(
          trip.destination,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${formatDate(trip.startDate)} - ${formatDate(trip.endDate)}'),
            Text(
              'Total gasto: ${currencyCode(trip.currency)} ${totalExpenses.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.deepPurple[800],
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
