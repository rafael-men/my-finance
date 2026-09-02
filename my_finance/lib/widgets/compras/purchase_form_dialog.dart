import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_finance/data/expense_data.dart';
import 'package:my_finance/data/settings_data.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/models/purchase_category.dart';
import 'package:my_finance/utils/date_formatters.dart';
import 'package:my_finance/utils/exceptions/exceptions.dart';

Future<void> showPurchaseFormDialog(
  BuildContext context,
  ExpenseData expenseData, {
  ExpenseItem? existing,
  SettingsData? settingsData,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _PurchaseFormDialog(
      expenseData: expenseData,
      existing: existing,
      settingsData: settingsData,
    ),
  );
}

class _PurchaseFormDialog extends StatefulWidget {
  final ExpenseData expenseData;
  final ExpenseItem? existing;
  final SettingsData? settingsData;

  const _PurchaseFormDialog({
    required this.expenseData,
    this.existing,
    this.settingsData,
  });

  @override
  State<_PurchaseFormDialog> createState() => _PurchaseFormDialogState();
}

class _PurchaseFormDialogState extends State<_PurchaseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late DateTime _selectedDate;
  late PurchaseCategory _selectedCategory;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _amountController = TextEditingController(
      text: existing != null
          ? existing.amount.toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );
    _selectedDate = existing?.date ?? DateTime.now();
    _selectedCategory = existing?.category ?? PurchaseCategory.outros;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = now;
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDay,
      lastDate: lastDay,
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _showLimitBlockedPopup(double currentTotal, double limit) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.block,
          color: Colors.red,
          size: 48,
        ),
        title: const Text(
          'Compras Bloqueadas',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Limite de gastos atingido!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Gasto atual: ${formatCurrency(currentTotal)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Limite definido: ${formatCurrency(limit)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Altere seu limite na tela inicial para continuar comprando.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 47, 9, 54),
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final normalizedAmount = _amountController.text.replaceAll(',', '.');
    final parsedAmount = double.tryParse(normalizedAmount);
    if (parsedAmount == null || parsedAmount <= 0) return;

    final settings = widget.settingsData ?? SettingsData();
    final spendingLimit = await settings.getSpendingLimit();
    if (spendingLimit > 0 && mounted) {
      final now = DateTime.now();
      final allExpenses = widget.expenseData.getAllExpenseList();
      final currentMonthTotal = allExpenses
          .where((e) => e.date.month == now.month && e.date.year == now.year)
          .fold<double>(0, (total, e) => total + e.amount);

      double newTotal;
      if (_isEditing) {
        newTotal = currentMonthTotal - widget.existing!.amount + parsedAmount;
      } else {
        newTotal = currentMonthTotal + parsedAmount;
      }

      if (newTotal > spendingLimit) {
        await _showLimitBlockedPopup(currentMonthTotal, spendingLimit);
        return;
      }
    }

    setState(() {
      _saving = true;
    });

    try {
      final expense = ExpenseItem(
        name: _nameController.text.trim(),
        amount: parsedAmount,
        date: _selectedDate,
        category: _selectedCategory,
      );

      if (_isEditing) {
        await widget.expenseData.updateExpense(widget.existing!, expense);
      } else {
        await widget.expenseData.addExpense(expense);
      }

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);

      if (mounted) {
        Navigator.of(context).pop();
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Compra atualizada com sucesso!'
                : 'Compra registrada com sucesso!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      final error = AppException.from(e, origin: 'PurchaseFormDialog');
      if (mounted) {
        setState(() {
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar compra: ${error.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar compra' : 'Nova compra'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da compra',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_cart),
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZÀ-ÿ\s\-]'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome da compra';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  TextInputFormatter.withFunction(
                    (oldValue, newValue) {
                      var text = newValue.text.replaceAll('.', ',');
                      text = text.replaceAll(RegExp(r'[^0-9,]'), '');
                      final commaIndex = text.indexOf(',');
                      if (commaIndex != -1) {
                        text = '${text.substring(0, commaIndex + 1)}'
                            '${text.substring(commaIndex + 1).replaceAll(',', '')}';
                      }
                      final commaPos = text.indexOf(',');
                      if (commaPos != -1 && text.length - commaPos - 1 > 2) {
                        text = text.substring(0, commaPos + 3);
                      }
                      return TextEditingValue(
                        text: text,
                        selection:
                            TextSelection.collapsed(offset: text.length),
                      );
                    },
                  ),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o valor';
                  }
                  final val = double.tryParse(value.replaceAll(',', '.'));
                  if (val == null) return 'Valor inválido';
                  if (val <= 0) return 'Valor deve ser maior que zero';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PurchaseCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_outline),
                ),
                items: PurchaseCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color.fromARGB(255, 47, 9, 54),
                ),
                title: const Text('Data da compra'),
                subtitle: Text(formatDate(_selectedDate)),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Alterar'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.check),
          label: Text(
            _saving
                ? 'Salvando...'
                : _isEditing
                    ? 'Salvar'
                    : 'Adicionar',
          ),
        ),
      ],
    );
  }
}
