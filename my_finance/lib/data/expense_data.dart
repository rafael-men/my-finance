import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/utils/exceptions/exceptions.dart';
import 'expense_repository.dart';

class ExpenseData extends ChangeNotifier {
  static final ExpenseData _instance =
      ExpenseData.withRepository(FirebaseExpenseRepository());

  factory ExpenseData() => _instance;

  ExpenseData.withRepository(this._repository);

  final ExpenseRepository _repository;
  List<ExpenseItem> _expenses = [];
  StreamSubscription<List<ExpenseItem>>? _subscription;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    _expenses = await _repository.fetchAll();
    _initialized = true;
    notifyListeners();

    _subscription = _repository.watchAll().listen((list) {
      _expenses = list;
      notifyListeners();
    }, onError: (Object error) {
      debugPrint(
        'Erro ao ouvir despesas: '
        '${AppException.from(error, origin: 'ExpenseData')}',
      );
    });
  }

  List<ExpenseItem> getAllExpenseList() {
    return List.from(_expenses);
  }

  Future<void> addExpense(ExpenseItem expense) async {
    await _repository.add(expense);
  }

  Future<void> updateExpense(
      ExpenseItem oldExpense, ExpenseItem updatedExpense) async {
    await _repository.update(oldExpense, updatedExpense);
  }

  Future<void> deleteExpense(ExpenseItem expense) async {
    await _repository.delete(expense);
  }

  Future<void> close() async {
    await _subscription?.cancel();
    _initialized = false;
  }

  int getExpenseCount() {
    return _expenses.length;
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
