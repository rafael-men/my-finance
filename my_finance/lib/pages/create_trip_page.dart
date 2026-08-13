import 'package:flutter/material.dart';
import 'package:my_finance/models/trip_item.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/data/currency_data.dart';
import 'package:my_finance/models/currency.dart';
import 'package:my_finance/utils/currencies.dart';
import 'package:my_finance/utils/date_formatters.dart';

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
    if (_formKey.currentState!.validate()) {
      final currency = _selectedCurrency ?? '';
      final newTrip = TripItem(
        destination: _destinationController.text,
        currency: currency,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await _travelData.addTrip(newTrip);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Viagem'),
        backgroundColor: Colors.deepPurple,
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
                  prefixIcon: Icon(Icons.place),
                ),
                validator: (value) => value!.isEmpty ? 'Informe o destino' : null,
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
                      prefixIcon: Icon(Icons.currency_exchange),
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Selecione a moeda'),
                    onChanged: (String? newValue) {
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
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data de Início'),
                subtitle: Text(formatDate(_startDate)),
                trailing: TextButton(
                  onPressed: () => _selectDate(context, true),
                  child: const Text('Alterar'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
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
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Salvar Viagem',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}