class Currency {
  final String code;
  final String label;

  const Currency({required this.code, required this.label});

  Map<String, dynamic> toMap() {
    return {'code': code, 'label': label};
  }

  factory Currency.fromMap(Map<String, dynamic> map, [String? id]) {
    final code = (map['code'] as String?) ?? id ?? '';
    return Currency(
      code: code,
      label: map['label'] as String? ?? code,
    );
  }
}
