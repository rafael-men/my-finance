import 'package:flutter_test/flutter_test.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/models/travel_expense.dart';
import 'package:my_finance/models/trip_item.dart';

void main() {
  group('TravelData - Singleton', () {
    test('deve retornar a mesma instância', () {
      final instance1 = TravelData();
      final instance2 = TravelData();
      expect(identical(instance1, instance2), isTrue);
    });

    test('getAllTrips retorna lista vazia antes de init', () {
      final data = TravelData();
      final trips = data.getAllTrips();
      expect(trips, isEmpty);
    });

    test('getExpensesForTrip retorna lista vazia para viagem inexistente',
        () {
      final data = TravelData();
      final expenses = data.getExpensesForTrip('nonexistent');
      expect(expenses, isEmpty);
    });

    test('getTotalExpensesForTrip retorna zero para viagem inexistente',
        () {
      final data = TravelData();
      final total = data.getTotalExpensesForTrip('nonexistent');
      expect(total, 0.0);
    });

    test('getAllTrips retorna uma cópia da lista', () {
      final data = TravelData();
      final trips1 = data.getAllTrips();
      final trips2 = data.getAllTrips();
      expect(trips1, isNot(same(trips2)));
      expect(trips1, equals(trips2));
    });
  });

  group('TravelExpense - Modelo', () {
    TravelExpense _expense({
      String id = '',
      String tripId = 'trip-1',
      String description = 'Almoço',
      double amount = 45.50,
      DateTime? date,
      String category = 'Alimentação',
    }) {
      return TravelExpense(
        id: id,
        tripId: tripId,
        description: description,
        amount: amount,
        date: date ?? DateTime(2026, 8, 10),
        category: category,
      );
    }

    test('cria expense com campos obrigatórios', () {
      final expense = _expense();

      expect(expense.id, '');
      expect(expense.tripId, 'trip-1');
      expect(expense.description, 'Almoço');
      expect(expense.amount, 45.50);
      expect(expense.category, 'Alimentação');
    });

    test('cria expense com id customizado', () {
      final expense = _expense(id: 'exp-123');
      expect(expense.id, 'exp-123');
    });

    test('toMap serializa corretamente', () {
      final date = DateTime(2026, 8, 10, 12, 0, 0);
      final expense = _expense(date: date);
      final map = expense.toMap();

      expect(map['tripId'], 'trip-1');
      expect(map['description'], 'Almoço');
      expect(map['amount'], 45.50);
      expect(map['category'], 'Alimentação');
      expect(map['date'], isNotNull);
    });

    test('toMap não inclui id', () {
      final expense = _expense(id: 'exp-1');
      final map = expense.toMap();
      expect(map.containsKey('id'), isFalse);
    });

    test('fromMap deserializa corretamente', () {
      final date = DateTime(2026, 8, 10, 12, 0, 0);
      final map = {
        'tripId': 'trip-1',
        'description': 'Jantar',
        'amount': 89.90,
        'date': date,
        'category': 'Alimentação',
      };

      final expense = TravelExpense.fromMap(map, 'exp-1');

      expect(expense.id, 'exp-1');
      expect(expense.tripId, 'trip-1');
      expect(expense.description, 'Jantar');
      expect(expense.amount, 89.90);
      expect(expense.date, date);
      expect(expense.category, 'Alimentação');
    });

    test('fromMap usa valores padrão para campos ausentes', () {
      final expense = TravelExpense.fromMap({});

      expect(expense.id, '');
      expect(expense.tripId, '');
      expect(expense.description, '');
      expect(expense.amount, 0.0);
      expect(expense.category, '');
    });

    test('fromMap usa id padrão quando não fornecido', () {
      final expense = TravelExpense.fromMap({
        'tripId': 'trip-1',
        'description': 'Teste',
        'amount': 10.0,
        'date': DateTime.now(),
        'category': 'Outros',
      });

      expect(expense.id, '');
    });

    test('toMap e fromMap são inversos', () {
      final original = _expense(id: 'exp-2');
      final map = original.toMap();
      final restored = TravelExpense.fromMap(map, 'exp-2');

      expect(restored.id, original.id);
      expect(restored.tripId, original.tripId);
      expect(restored.description, original.description);
      expect(restored.amount, original.amount);
      expect(restored.category, original.category);
    });

    test('fromMap aceita amount como int', () {
      final map = {
        'tripId': 'trip-1',
        'description': 'Teste',
        'amount': 50,
        'date': DateTime.now(),
        'category': 'Outros',
      };

      final expense = TravelExpense.fromMap(map);
      expect(expense.amount, 50.0);
    });

    test('fromMap aceita amount como double', () {
      final map = {
        'tripId': 'trip-1',
        'description': 'Teste',
        'amount': 50.5,
        'date': DateTime.now(),
        'category': 'Outros',
      };

      final expense = TravelExpense.fromMap(map);
      expect(expense.amount, 50.5);
    });
  });

  group('TripItem - Modelo', () {
    TripItem _trip({
      String id = '',
      String destination = 'Paris',
      String currency = 'EUR',
      DateTime? startDate,
      DateTime? endDate,
      String? notes,
    }) {
      return TripItem(
        id: id,
        destination: destination,
        currency: currency,
        startDate: startDate ?? DateTime(2026, 9, 1),
        endDate: endDate ?? DateTime(2026, 9, 15),
        notes: notes,
      );
    }

    test('cria trip com campos obrigatórios', () {
      final trip = _trip();

      expect(trip.id, '');
      expect(trip.destination, 'Paris');
      expect(trip.currency, 'EUR');
      expect(trip.notes, isNull);
    });

    test('cria trip com id customizado', () {
      final trip = _trip(id: 'trip-123');
      expect(trip.id, 'trip-123');
    });

    test('cria trip com notes', () {
      final trip = _trip(notes: 'Férias de verão');
      expect(trip.notes, 'Férias de verão');
    });

    test('toMap serializa corretamente', () {
      final start = DateTime(2026, 9, 1);
      final end = DateTime(2026, 9, 15);
      final trip = _trip(startDate: start, endDate: end, notes: 'Anotações');
      final map = trip.toMap();

      expect(map['destination'], 'Paris');
      expect(map['currency'], 'EUR');
      expect(map['startDate'], isNotNull);
      expect(map['endDate'], isNotNull);
      expect(map['notes'], 'Anotações');
    });

    test('toMap não inclui id', () {
      final trip = _trip(id: 'trip-1');
      final map = trip.toMap();
      expect(map.containsKey('id'), isFalse);
    });

    test('toMap serializa notes como null quando não fornecido', () {
      final trip = _trip();
      final map = trip.toMap();
      expect(map['notes'], isNull);
    });

    test('fromMap deserializa corretamente', () {
      final start = DateTime(2026, 9, 1);
      final end = DateTime(2026, 9, 15);
      final map = {
        'destination': 'Tóquio',
        'currency': 'JPY',
        'startDate': start,
        'endDate': end,
        'notes': 'Trabalho',
      };

      final trip = TripItem.fromMap(map, 'trip-1');

      expect(trip.id, 'trip-1');
      expect(trip.destination, 'Tóquio');
      expect(trip.currency, 'JPY');
      expect(trip.startDate, start);
      expect(trip.endDate, end);
      expect(trip.notes, 'Trabalho');
    });

    test('fromMap usa valores padrão para campos ausentes', () {
      final trip = TripItem.fromMap({});

      expect(trip.id, '');
      expect(trip.destination, '');
      expect(trip.currency, '');
      expect(trip.notes, isNull);
    });

    test('fromMap usa id padrão quando não fornecido', () {
      final trip = TripItem.fromMap({
        'destination': 'Roma',
        'currency': 'EUR',
        'startDate': DateTime.now(),
        'endDate': DateTime.now(),
      });

      expect(trip.id, '');
    });

    test('fromMap aceita notes nulo', () {
      final map = {
        'destination': 'Londres',
        'currency': 'GBP',
        'startDate': DateTime.now(),
        'endDate': DateTime.now(),
        'notes': null,
      };

      final trip = TripItem.fromMap(map);
      expect(trip.notes, isNull);
    });

    test('toMap e fromMap são inversos', () {
      final original = _trip(id: 'trip-3', notes: 'Anotações');
      final map = original.toMap();
      final restored = TripItem.fromMap(map, 'trip-3');

      expect(restored.id, original.id);
      expect(restored.destination, original.destination);
      expect(restored.currency, original.currency);
      expect(restored.startDate, original.startDate);
      expect(restored.endDate, original.endDate);
      expect(restored.notes, original.notes);
    });

    test('fromMap aceita startDate como DateTime', () {
      final date = DateTime(2026, 10, 1);
      final map = {
        'destination': 'Dubai',
        'currency': 'AED',
        'startDate': date,
        'endDate': DateTime(2026, 10, 10),
      };

      final trip = TripItem.fromMap(map);
      expect(trip.startDate, date);
    });
  });
}
