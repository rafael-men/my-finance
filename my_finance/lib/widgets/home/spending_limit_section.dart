import 'package:flutter/material.dart';

class SpendingLimitSection extends StatelessWidget {
  final TextEditingController controller;
  final double spendingLimit;
  final double totalSpent;
  final ValueChanged<double> onChanged;

  const SpendingLimitSection({
    super.key,
    required this.controller,
    required this.spendingLimit,
    required this.totalSpent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Defina o limite de gastos',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                onChanged: (value) {
                  onChanged(double.tryParse(value) ?? 0.0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Limite: R\$ ${spendingLimit.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
        if (spendingLimit > 0 && totalSpent > spendingLimit) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: const Text(
              'Você ultrapassou o limite de gastos!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}
