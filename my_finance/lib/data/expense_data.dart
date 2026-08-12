import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/expense_item.dart';

class ExpenseData extends ChangeNotifier {
  late final CollectionReference<Map<String, dynamic>> _expensesRef;
  List<ExpenseItem> _expenses = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  Future<void> init() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses');

    final snapshot =
        await _expensesRef.orderBy('date', descending: true).get();
    _expenses = snapshot.docs
        .map((doc) => ExpenseItem.fromMap(doc.data(), doc.id))
        .toList();
    notifyListeners();

    _subscription = _expensesRef
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _expenses = snapshot.docs
          .map((doc) => ExpenseItem.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    }, onError: (Object error) {
      debugPrint('Erro ao ouvir despesas: $error');
    });
  }

  List<ExpenseItem> getAllExpenseList() {
    return List.from(_expenses);
  }

  Future<void> addExpense(ExpenseItem expense) async {
    await _expensesRef.add(expense.toMap());
  }

  Future<void> updateExpense(
      ExpenseItem oldExpense, ExpenseItem updatedExpense) async {
    if (oldExpense.id.isNotEmpty) {
      await _expensesRef.doc(oldExpense.id).update(updatedExpense.toMap());
    }
  }

  Future<void> deleteExpense(ExpenseItem expense) async {
    if (expense.id.isNotEmpty) {
      await _expensesRef.doc(expense.id).delete();
    }
  }

  Future<void> close() async {
    await _subscription?.cancel();
  }

  int getExpenseCount() {
    return _expenses.length;
  }

  List<ExpenseItem> getExpensesByWeekday(int weekday) {
    return _expenses.where((expense) {
      return expense.date.weekday == weekday;
    }).toList();
  }

  Map<int, List<ExpenseItem>> getExpensesGroupedByWeekday() {
    final Map<int, List<ExpenseItem>> groupedExpenses = {};

    for (int i = 1; i <= 7; i++) {
      groupedExpenses[i] = [];
    }

    for (var expense in _expenses) {
      final weekday = expense.date.weekday;
      groupedExpenses[weekday]!.add(expense);
    }

    return groupedExpenses;
  }

  double getTotalByWeekday(int weekday) {
    final expenses = getExpensesByWeekday(weekday);
    return expenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  List<ExpenseItem> getExpensesByMonth(int month, int year) {
    final expenses = _expenses
        .where((expense) =>
            expense.date.month == month && expense.date.year == year)
        .toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }
}
