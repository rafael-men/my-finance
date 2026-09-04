import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_finance/services/exchange_rate_service.dart';

void main() {
  group('ExchangeRateService', () {
    test('retorna bid para o par código-BRL', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'EURBRL': {
              'code': 'EUR',
              'codein': 'BRL',
              'bid': '5.9486',
              'ask': '5.9506',
            },
          }),
          200,
        ),
      );

      final service = ExchangeRateService(client: client);
      final rate = await service.fetchRateBid('EUR');

      expect(rate, 5.9486);
    });

    test('BRL retorna 1.0 sem chamar a API', () async {
      var called = false;
      final client = MockClient(
        (_) async {
          called = true;
          return http.Response('{}', 200);
        },
      );

      final service = ExchangeRateService(client: client);
      final rate = await service.fetchRateBid('BRL');

      expect(rate, 1.0);
      expect(called, isFalse);
    });

    test('retorna null para par inexistente', () async {
      final client = MockClient((_) async => http.Response('{}', 200));

      final service = ExchangeRateService(client: client);
      final rate = await service.fetchRateBid('XYZ');

      expect(rate, isNull);
    });

    test('retorna null em erro de rede', () async {
      final client = MockClient((_) async => throw Exception('network'));
      final service = ExchangeRateService(client: client);

      final rate = await service.fetchRateBid('EUR');
      expect(rate, isNull);
    });

    test('retorna null quando a API responde erro', () async {
      final client = MockClient((_) async => http.Response('erro', 500));
      final service = ExchangeRateService(client: client);

      final rate = await service.fetchRateBid('EUR');
      expect(rate, isNull);
    });
  });
}