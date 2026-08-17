import 'package:flutter/material.dart';
import 'package:my_finance/models/trip_item.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/data/currency_data.dart';
import 'package:my_finance/models/currency.dart';
import 'package:my_finance/utils/currencies.dart';
import 'package:my_finance/utils/date_formatters.dart';
import 'package:my_finance/utils/exceptions/exceptions.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  String? _selectedCurrency;
  late Future<List<Currency>> _currenciesFuture;
  bool _saving = false;

  final _notesController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  final TravelData _travelData = TravelData();

  @override
  void initState() {
    super.initState();
    _currenciesFuture = CurrencyData().getCurrencies();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      final currency = _selectedCurrency ?? '';
      final newTrip = TripItem(
        destination: _destinationController.text.trim(),
        currency: currency,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await _travelData.addTrip(newTrip);

      if (mounted) {
        Navigator.pop(context, true);
      }
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Viagem criada com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      final error = AppException.from(e, origin: 'CreateTripPage');
      if (mounted) {
        setState(() {
          _saving = false;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text('Erro ao criar viagem: ${error.message}'),
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
        title: const Text('Nova Viagem'),
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
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o destino';
                  }
                  if (value.trim().length < 2) {
                    return 'Destino deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Currency>>(
                future: _currenciesFuture,
                builder: (context, snapshot) {
                  final currencies = snapshot.data ?? kDefaultCurrencies;
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Moeda Local',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_exchange),
                    ),
                    hint: const Text('Selecione a moeda'),
                    onChanged: _saving
                        ? null
                        : (String? newValue) {
                            setState(() {
                              _selectedCurrency = newValue;
                            });
                          },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Selecione a moeda' : null,
                    items: currencies.map<DropdownMenuItem<String>>(
                      (currency) {
                        return DropdownMenuItem<String>(
                          value: currency.code,
                          child: Text(currency.label),
                        );
                      },
                    ).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color.fromARGB(255, 47, 9, 54),
                ),
                title: const Text('Data de Início'),
                subtitle: Text(formatDate(_startDate)),
                trailing: TextButton(
                  onPressed: () => _selectDate(context, true),
                  child: const Text('Alterar'),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.calendar_today,
                  color: Color.fromARGB(255, 47, 9, 54),
                ),
                title: const Text('Data de Término'),
                subtitle: Text(formatDate(_endDate)),
                trailing: TextButton(
                  onPressed: () => _selectDate(context, false),
                  child: const Text('Alterar'),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saving ? null : _saveTrip,
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
                label: Text(_saving ? 'Salvando...' : 'Salvar Viagem'),
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
