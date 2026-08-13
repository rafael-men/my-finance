import '../models/currency.dart';

const List<Currency> kDefaultCurrencies = [
  Currency(code: 'USD', label: 'Dólar Americano'),
  Currency(code: 'EUR', label: 'Euro'),
  Currency(code: 'ARS', label: 'Peso Argentino'),
  Currency(code: 'BOB', label: 'Boliviano'),
  Currency(code: 'BRL', label: 'Real Brasileiro'),
  Currency(code: 'CLP', label: 'Peso Chileno'),
  Currency(code: 'COP', label: 'Peso Colombiano'),
  Currency(code: 'CRC', label: 'Colón Costarriquenho'),
  Currency(code: 'CUP', label: 'Peso Cubano'),
  Currency(code: 'DOP', label: 'Peso Dominicano'),
  Currency(code: 'SVC', label: 'Colón Salvadorenho'),
  Currency(code: 'GTQ', label: 'Quetzal Guatemalteco'),
  Currency(code: 'HTG', label: 'Gourde Haitiano'),
  Currency(code: 'HNL', label: 'Lempira Hondurenha'),
  Currency(code: 'MXN', label: 'Peso Mexicano'),
  Currency(code: 'NIO', label: 'Córdoba Nicaraguense'),
  Currency(code: 'PAB', label: 'Balboa Panamenho'),
  Currency(code: 'PYG', label: 'Guarani Paraguaio'),
  Currency(code: 'PEN', label: 'Sol Peruano'),
  Currency(code: 'TTD', label: 'Dólar de Trinidad e Tobago'),
  Currency(code: 'UYU', label: 'Peso Uruguaio'),
  Currency(code: 'VES', label: 'Bolívar Venezuelano'),
];

String currencyCode(String value) {
  final match = RegExp(r'\(([A-Z]{3})\)').firstMatch(value);
  return match?.group(1) ?? value;
}

String currencyLabel(String code) {
  for (final currency in kDefaultCurrencies) {
    if (currency.code == code) return currency.label;
  }
  return code;
}
