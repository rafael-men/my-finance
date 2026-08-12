import 'package:flutter/material.dart';
import 'package:my_finance/utils/date_formatters.dart';

class WeekdayFilter extends StatelessWidget {
  final int? selectedWeekday;
  final ValueChanged<int?> onChanged;

  const WeekdayFilter({
    super.key,
    required this.selectedWeekday,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtrar por dia da semana:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip(
                label: 'Todos',
                selected: selectedWeekday == null,
                onSelected: (_) => onChanged(null),
              ),
              ...List.generate(7, (index) {
                final weekday = index + 1;
                return _chip(
                  label: kShortWeekdayNames[index],
                  selected: selectedWeekday == weekday,
                  onSelected: (selected) =>
                      onChanged(selected ? weekday : null),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        selectedColor: Colors.deepPurple.shade100,
        checkmarkColor: Colors.deepPurple,
      ),
    );
  }
}
