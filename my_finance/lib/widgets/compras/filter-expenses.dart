import 'package:flutter/material.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/models/purchase_category.dart';
import 'package:my_finance/utils/date_formatters.dart';


@immutable
class PurchaseFilter {
  final Set<PurchaseCategory> categories;
  final double? minAmount;
  final double? maxAmount;

  const PurchaseFilter({
    this.categories = const {},
    this.minAmount,
    this.maxAmount,
  });

  bool get isActive =>
      categories.isNotEmpty || minAmount != null || maxAmount != null;

  bool matches(ExpenseItem expense) {
    if (categories.isNotEmpty && !categories.contains(expense.category)) {
      return false;
    }
    if (minAmount != null && expense.amount < minAmount!) return false;
    if (maxAmount != null && expense.amount > maxAmount!) return false;
    return true;
  }

  PurchaseFilter copyWith({
    Set<PurchaseCategory>? categories,
    double? minAmount,
    double? maxAmount,
    bool clearAmounts = false,
  }) {
    return PurchaseFilter(
      categories: categories ?? this.categories,
      minAmount: clearAmounts ? null : minAmount ?? this.minAmount,
      maxAmount: clearAmounts ? null : maxAmount ?? this.maxAmount,
    );
  }
}


Future<PurchaseFilter?> showFilterExpensesDialog(
  BuildContext context, {
  required PurchaseFilter current,
  required List<ExpenseItem> purchases,
}) async {
  var maxValue = 0.0;
  for (final p in purchases) {
    if (p.amount > maxValue) maxValue = p.amount;
  }
  if (purchases.isEmpty) maxValue = 100.0;

  return showDialog<PurchaseFilter>(
    context: context,
    builder: (_) => _FilterExpensesDialog(
      current: current,
      maxValue: maxValue,
    ),
  );
}

class _FilterExpensesDialog extends StatefulWidget {
  final PurchaseFilter current;
  final double maxValue;

  const _FilterExpensesDialog({
    required this.current,
    required this.maxValue,
  });

  @override
  State<_FilterExpensesDialog> createState() => _FilterExpensesDialogState();
}

class _FilterExpensesDialogState extends State<_FilterExpensesDialog> {
  late final Set<PurchaseCategory> _selectedCategories;
  late RangeValues _amountRange;
  late double _sliderMin;
  late double _sliderMax;

  @override
  void initState() {
    super.initState();
    _selectedCategories = Set.of(widget.current.categories);
    _sliderMin = 0;
    _sliderMax = widget.maxValue.ceilToDouble();
    if (_sliderMax <= _sliderMin) {
      _sliderMax = _sliderMin + 100;
    }
    _amountRange = RangeValues(
      (widget.current.minAmount ?? _sliderMin).clamp(_sliderMin, _sliderMax),
      (widget.current.maxAmount ?? _sliderMax).clamp(_sliderMin, _sliderMax),
    );
  }

  void _toggleCategory(PurchaseCategory category, bool selected) {
    setState(() {
      if (selected) {
        _selectedCategories.add(category);
      } else {
        _selectedCategories.remove(category);
      }
    });
  }

  void _apply() {
    final hasAmountFilter =
        _amountRange.start > _sliderMin || _amountRange.end < _sliderMax;
    final applied = PurchaseFilter(
      categories: _selectedCategories.isEmpty
          ? const {}
          : Set.of(_selectedCategories),
      minAmount: hasAmountFilter ? _amountRange.start : null,
      maxAmount: hasAmountFilter ? _amountRange.end : null,
    );
    Navigator.of(context).pop(applied);
  }

  void _clear() {
    Navigator.of(context).pop(const PurchaseFilter());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrar compras'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categoria',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PurchaseCategory.values.map((category) {
                final selected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category.label),
                  avatar: Icon(category.icon, color: category.color, size: 18),
                  selected: selected,
                  onSelected: (value) => _toggleCategory(category, value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Valor',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'De ${formatCurrency(_amountRange.start)} até '
              '${formatCurrency(_amountRange.end)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            RangeSlider(
              values: _amountRange,
              min: _sliderMin,
              max: _sliderMax,
              divisions: 20,
              activeColor: const Color.fromARGB(255, 47, 9, 54),
              onChanged: (values) {
                setState(() {
                  _amountRange = values;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _clear,
          child: const Text('Limpar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _apply,
          icon: const Icon(Icons.filter_alt),
          label: const Text('Aplicar'),
        ),
      ],
    );
  }
}
