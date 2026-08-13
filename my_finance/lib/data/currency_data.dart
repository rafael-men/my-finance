import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_finance/models/currency.dart';
import 'package:my_finance/utils/currencies.dart';

class CurrencyData {
  static final CurrencyData _instance = CurrencyData._internal();

  factory CurrencyData() => _instance;

  CurrencyData._internal();

  Future<List<Currency>>? _cache;

  Future<List<Currency>> getCurrencies() => _cache ??= _load();

  Future<List<Currency>> _load() async {
    final fallback = kDefaultCurrencies;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('currencies')
          .orderBy('label')
          .get();

      if (snapshot.docs.isEmpty) {
        await _seed(fallback);
        return fallback;
      }

      return snapshot.docs
          .map((doc) => Currency.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return fallback;
    }
  }

  Future<void> _seed(List<Currency> currencies) async {
    final ref = FirebaseFirestore.instance.collection('currencies');
    try {
      for (final currency in currencies) {
        await ref.doc(currency.code).set(currency.toMap());
      }
    } catch (e) {
      debugPrint('Não foi possível semear as moedas: $e');
    }
  }
}
