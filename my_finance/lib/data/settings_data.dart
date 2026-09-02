import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class SpendingLimitStore {
  Future<double> getSpendingLimit();

  Future<void> saveSpendingLimit(double limit);
}

class FirestoreSpendingLimitStore implements SpendingLimitStore {
  final FirebaseFirestore _firestore;
  final String _uid;

  FirestoreSpendingLimitStore({
    FirebaseFirestore? firestore,
    String? uid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uid = uid ?? FirebaseAuth.instance.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      _firestore
          .collection('users')
          .doc(_uid)
          .collection('settings')
          .doc('spending');

  @override
  Future<double> getSpendingLimit() async {
    final doc = await _settingsDoc.get();
    if (!doc.exists) return 0.0;
    return (doc.data()?['spendingLimit'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Future<void> saveSpendingLimit(double limit) async {
    await _settingsDoc.set({'spendingLimit': limit});
  }
}

class SettingsData {
  static SettingsData? _instance;

  final SpendingLimitStore _store;

  factory SettingsData({SpendingLimitStore? store}) {
    if (store != null) return SettingsData._(store);
    _instance ??= SettingsData._(FirestoreSpendingLimitStore());
    return _instance!;
  }

  SettingsData._(this._store);

  Future<double> getSpendingLimit() => _store.getSpendingLimit();

  Future<void> saveSpendingLimit(double limit) => _store.saveSpendingLimit(limit);
}