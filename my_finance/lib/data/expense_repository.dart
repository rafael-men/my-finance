import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_finance/models/expense_item.dart';
import 'package:my_finance/utils/exceptions/exceptions.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseItem>> fetchAll();

  Stream<List<ExpenseItem>> watchAll();

  Future<void> add(ExpenseItem expense);

  Future<void> update(ExpenseItem oldExpense, ExpenseItem updatedExpense);

  Future<void> delete(ExpenseItem expense);
}

class FirebaseExpenseRepository implements ExpenseRepository {
  CollectionReference<Map<String, dynamic>> _collection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw AuthenticationException(
        'Usuário não autenticado.',
        origin: 'ExpenseRepository',
      );
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses');
  }

  @override
  Future<List<ExpenseItem>> fetchAll() async {
    final snapshot =
        await _collection().orderBy('date', descending: true).get();
    return snapshot.docs
        .map((doc) => ExpenseItem.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Stream<List<ExpenseItem>> watchAll() {
    return _collection().orderBy('date', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseItem.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<void> add(ExpenseItem expense) async {
    await _collection().add(expense.toMap());
  }

  @override
  Future<void> update(
    ExpenseItem oldExpense,
    ExpenseItem updatedExpense,
  ) async {
    if (oldExpense.id.isNotEmpty) {
      await _collection().doc(oldExpense.id).update(updatedExpense.toMap());
    }
  }

  @override
  Future<void> delete(ExpenseItem expense) async {
    if (expense.id.isNotEmpty) {
      await _collection().doc(expense.id).delete();
    }
  }
}
