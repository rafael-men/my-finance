import 'package:flutter/material.dart';

enum PurchaseCategory {
  alimentacao,
  roupas,
  entretenimento,
  outros;

  String get label {
    switch (this) {
      case PurchaseCategory.alimentacao:
        return 'Alimentação';
      case PurchaseCategory.roupas:
        return 'Roupas';
      case PurchaseCategory.entretenimento:
        return 'Entretenimento';
      case PurchaseCategory.outros:
        return 'Outros';
    }
  }

  IconData get icon {
    switch (this) {
      case PurchaseCategory.alimentacao:
        return Icons.restaurant_outlined;
      case PurchaseCategory.roupas:
        return Icons.checkroom_outlined;
      case PurchaseCategory.entretenimento:
        return Icons.movie_outlined;
      case PurchaseCategory.outros:
        return Icons.category_outlined;
    }
  }

  Color get color {
    switch (this) {
      case PurchaseCategory.alimentacao:
        return const Color(0xFF2E7D32);
      case PurchaseCategory.roupas:
        return const Color(0xFF1565C0);
      case PurchaseCategory.entretenimento:
        return const Color(0xFFEF6C00);
      case PurchaseCategory.outros:
        return const Color(0xFF546E7A);
    }
  }

  static PurchaseCategory fromValue(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'alimentacao':
        return PurchaseCategory.alimentacao;
      case 'roupas':
        return PurchaseCategory.roupas;
      case 'entretenimento':
        return PurchaseCategory.entretenimento;
      case 'outros':
        return PurchaseCategory.outros;
      default:
        return PurchaseCategory.outros;
    }
  }
}
