import 'dart:convert';

import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const String baseUrl = 'https://economia.awesomeapi.com.br/json/last/';

  final http.Client _client;

  ExchangeRateService({http.Client? client}) : _client = client ?? http.Client();

  /// Returns how much 1 unit of [currencyCode] costs in BRL,
  /// or null when unavailable (unsupported pair or API error).
  Future<double?> fetchRateBid(String currencyCode) async {
    final code = currencyCode.trim().toUpperCase();
    if (code == 'BRL') return 1.0;

    try {
      final response = await _client
          .get(Uri.parse('$baseUrl$code-BRL'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      Map<String, dynamic>? entry;
      final expectedKey = '$code-BRL'.replaceAll('-', '');
      for (final key in decoded.keys) {
        if (key.toUpperCase().replaceAll('-', '') ==
            expectedKey.toUpperCase()) {
          final value = decoded[key];
          if (value is Map<String, dynamic>) entry = value;
          break;
        }
      }
      if (entry == null) return null;

      return double.tryParse(entry['bid'].toString());
    } catch (_) {
      return null;
    }
  }
}