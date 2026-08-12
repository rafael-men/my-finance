import 'package:flutter/material.dart';

class TripTotalCard extends StatelessWidget {
  final String currency;
  final double total;

  const TripTotalCard({
    super.key,
    required this.currency,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total gasto na viagem:',
              style: TextStyle(color: Colors.deepPurple[800], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '$currency ${total.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.deepPurple[900],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
