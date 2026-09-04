import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_finance/models/travel_expense.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/services/exchange_rate_service.dart';
import 'package:my_finance/utils/currencies.dart';
import 'package:my_finance/utils/date_formatters.dart';
import 'package:my_finance/utils/exceptions/exceptions.dart';

class AddTravelExpensePage extends StatefulWidget {
  final String tripId;
  final String currency;
  final TravelExpense? expense;
  final TravelData? travelData;
  final ExchangeRateService? exchangeRateService;

  const AddTravelExpensePage({
    super.key,
    required this.tripId,
    this.currency = 'BRL',
    this.expense,
    this.travelData,
    this.exchangeRateService,
  });

  @override
  State<AddTravelExpensePage> createState() => _AddTravelExpensePageState();
}

class _AddTravelExpensePageState extends State<AddTravelExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Alimentação';
  DateTime _selectedDate = DateTime.now();
  late final TravelData _travelData = widget.travelData ?? TravelData();
  late final ExchangeRateService _exchangeRateService =
      widget.exchangeRateService ?? ExchangeRateService();
  double? _rate;
  bool _rateLoading = false;
  bool _saving = false;

  bool get _isEditing => widget.expense != null;

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'Alimentação', 'icon': Icons.restaurant_outlined, 'color': Color(0xFF2E7D32)},
    {'label': 'Transporte', 'icon': Icons.directions_bus_outlined, 'color': Color(0xFF1565C0)},
    {'label': 'Hospedagem', 'icon': Icons.hotel_outlined, 'color': Color(0xFF6A1B9A)},
    {'label': 'Lazer', 'icon': Icons.sports_esports_outlined, 'color': Color(0xFFEF6C00)},
    {'label': 'Compras', 'icon': Icons.shopping_bag_outlined, 'color': Color(0xFFC62828)},
    {'label': 'Outros', 'icon': Icons.category_outlined, 'color': Color(0xFF546E7A)},
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.expense;
    if (existing != null) {
      _descriptionController.text = existing.description;
      _amountController.text =
          existing.amount.toStringAsFixed(2).replaceAll('.', ',');
      _selectedCategory =
          existing.category.isEmpty ? 'Alimentação' : existing.category;
      _selectedDate = existing.date;
    }
    _travelData.init();
    if (widget.currency != 'BRL') {
      _rateLoading = true;
      unawaited(_loadRate());
    }
  }

  Future<void> _loadRate() async {
    final rate = await _exchangeRateService.fetchRateBid(widget.currency);
    if (!mounted) return;
    setState(() {
      _rate = rate;
      _rateLoading = false;
    });
  }

  Future<void> _retryLoadRate() async {
    setState(() {
      _rateLoading = true;
      _rate = null;
    });
    await _loadRate();
  }

  double? _brlEstimate() {
    final normalizedAmount = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(normalizedAmount);
    if (amount == null || amount <= 0 || _rate == null) return null;
    return amount * _rate!;
  }

  String _formatBRL(double value) {
    return '≈ R\$ ${value.toStringAsFixed(2).replaceFirst('.', ',')}';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final normalizedAmount = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(normalizedAmount);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valor inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      final expense = TravelExpense(
        id: _isEditing ? widget.expense!.id : '',
        tripId: widget.tripId,
        description: _descriptionController.text.trim(),
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory,
      );

      if (_isEditing) {
        await _travelData.updateExpense(expense);
      } else {
        await _travelData.addExpense(expense);
      }

      if (mounted) {
        Navigator.pop(context);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Gasto atualizado com sucesso!'
                : 'Gasto registrado com sucesso!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      final error = AppException.from(e, origin: 'AddTravelExpensePage');
      if (mounted) {
        setState(() {
          _saving = false;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar gasto: ${error.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Gasto' : 'Adicionar Gasto'),
        backgroundColor: const Color.fromARGB(255, 47, 9, 54),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZÀ-ÿ\s\-]'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a descrição';
                  }
                  if (value.trim().length < 2) {
                    return 'Descrição deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Valor',
                  border: const OutlineInputBorder(),
                  prefixText: '${currencyCode(widget.currency)} ',
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  setState(() {});
                },
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
              if (widget.currency != 'BRL') ...[
                const SizedBox(height: 8),
                if (_rateLoading)
                  Text(
                    'Buscando cotação...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  )
                else if (_rate != null) ...[
                  Text(
                    '1 ${currencyCode(widget.currency)} ≈ R\$ '
                    '${_rate!.toStringAsFixed(2).replaceFirst('.', ',')}',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  if (_brlEstimate() != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatBRL(_brlEstimate()!),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 47, 9, 54),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ] else
                  InkWell(
                    onTap: _retryLoadRate,
                    child: Text(
                      'Cotação indisponível. Toque para tentar novamente.',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label_outline),
                ),
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat['label'] as String,
                        child: Row(
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              color: cat['color'] as Color,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(cat['label'] as String),
                          ],
                        ),
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
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color.fromARGB(255, 47, 9, 54),
                ),
                title: const Text('Data do gasto'),
                subtitle: Text(formatDate(_selectedDate)),
                trailing: TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Alterar'),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saving ? null : _saveExpense,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _saving
                      ? 'Salvando...'
                      : (_isEditing ? 'Salvar Alterações' : 'Salvar Gasto'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 47, 9, 54),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
