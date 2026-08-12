import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/models/travel_expense.dart';
import 'package:my_finance/models/trip_item.dart';

class TravelData extends ChangeNotifier {
  static final TravelData _instance = TravelData._internal();

  factory TravelData() {
    return _instance;
  }

  TravelData._internal();

  late final CollectionReference<Map<String, dynamic>> _tripRef;
  late final CollectionReference<Map<String, dynamic>> _expenseRef;
  List<TripItem> _trips = [];
  List<TravelExpense> _expenses = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tripSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _expenseSub;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    _tripRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('trips');
    _expenseRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('travel_expenses');

    final tripsSnapshot =
        await _tripRef.orderBy('startDate', descending: true).get();
    _trips = tripsSnapshot.docs
        .map((doc) => TripItem.fromMap(doc.data(), doc.id))
        .toList();

    final expensesSnapshot =
        await _expenseRef.orderBy('date', descending: true).get();
    _expenses = expensesSnapshot.docs
        .map((doc) => TravelExpense.fromMap(doc.data(), doc.id))
        .toList();

    notifyListeners();
    _initialized = true;

    _tripSub = _tripRef.orderBy('startDate', descending: true).snapshots().listen(
      (snapshot) {
        _trips = snapshot.docs
            .map((doc) => TripItem.fromMap(doc.data(), doc.id))
            .toList();
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Erro ao ouvir viagens: $error');
      },
    );

    _expenseSub = _expenseRef
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _expenses = snapshot.docs
          .map((doc) => TravelExpense.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    }, onError: (Object error) {
      debugPrint('Erro ao ouvir gastos de viagem: $error');
    });
  }

  List<TripItem> getAllTrips() => List.from(_trips);

  Future<void> addTrip(TripItem trip) async {
    await _tripRef.add(trip.toMap());
    notifyListeners();
  }

  Future<void> deleteTrip(String tripId) async {
    final expensesSnapshot =
        await _expenseRef.where('tripId', isEqualTo: tripId).get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in expensesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_tripRef.doc(tripId));

    await batch.commit();
    notifyListeners();
  }

  Future<void> addExpense(TravelExpense expense) async {
    await _expenseRef.add(expense.toMap());
    notifyListeners();
  }

  List<TravelExpense> getExpensesForTrip(String tripId) {
    return _expenses.where((e) => e.tripId == tripId).toList();
  }

  double getTotalExpensesForTrip(String tripId) {
    return getExpensesForTrip(tripId)
        .fold(0.0, (acc, expense) => acc + expense.amount);
  }

  Future<void> close() async {
    await _tripSub?.cancel();
    await _expenseSub?.cancel();
  }
}
