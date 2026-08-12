import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsData {
  static final SettingsData _instance = SettingsData._internal();

  factory SettingsData() => _instance;

  SettingsData._internal();

  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('settings')
          .doc('spending');

  Future<double> getSpendingLimit() async {
    final doc = await _settingsDoc.get();
    if (!doc.exists) return 0.0;
    return (doc.data()?['spendingLimit'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> saveSpendingLimit(double limit) async {
    await _settingsDoc.set({'spendingLimit': limit});
  }
}
