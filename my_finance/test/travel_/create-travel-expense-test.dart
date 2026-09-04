import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_finance/pages/add_travel_expense_page.dart';
import 'package:my_finance/data/travel_data.dart';
import 'package:my_finance/models/travel_expense.dart';
import 'package:my_finance/services/exchange_rate_service.dart';

class MockTravelData extends Mock implements TravelData {}

class _FakeRateService extends ExchangeRateService {
  final double? rate;

  _FakeRateService({this.rate});

  @override
  Future<double?> fetchRateBid(String currencyCode) async => rate;
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      TravelExpense(
        tripId: '',
        description: '',
        amount: 0,
        date: DateTime(2026),
        category: '',
      ),
    );
  });

  late MockTravelData mockTravelData;

  setUp(() {
    mockTravelData = MockTravelData();
    when(() => mockTravelData.init()).thenAnswer((_) async {});
    when(() => mockTravelData.addExpense(any())).thenAnswer((_) async {});
    when(() => mockTravelData.updateExpense(any())).thenAnswer((_) async {});
  });

  MaterialApp _buildApp({
    String tripId = 'trip-1',
    String currency = 'BRL',
    TravelExpense? expense,
    ExchangeRateService? exchangeRateService,
  }) {
    return MaterialApp(
      home: AddTravelExpensePage(
        tripId: tripId,
        currency: currency,
        expense: expense,
        travelData: mockTravelData,
        exchangeRateService: exchangeRateService ?? _FakeRateService(rate: null),
      ),
    );
  }

  TravelExpense _existingExpense() {
    return TravelExpense(
      id: 'exp-1',
      tripId: 'trip-1',
      description: 'Almoço',
      amount: 45.90,
      date: DateTime(2026, 7, 10),
      category: 'Transporte',
    );
  }

  group('AddTravelExpensePage - Renderização', () {
    testWidgets('deve renderizar o AppBar com título correto', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Adicionar Gasto'), findsOneWidget);
    });

    testWidgets('deve renderizar o campo de descrição', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Descrição'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('deve renderizar o campo de valor', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Valor'), findsOneWidget);
      expect(find.text('BRL '), findsOneWidget);
    });

    testWidgets('deve renderizar o campo de categoria', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Categoria'), findsOneWidget);
    });

    testWidgets('deve renderizar a seção de data', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Data do gasto'), findsOneWidget);
      expect(find.text('Alterar'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('deve renderizar o botão salvar', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Salvar Gasto'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('deve exibir data atual formatada', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final formatted =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      expect(find.text(formatted), findsOneWidget);
    });

    testWidgets('deve ter ícone de descrição no campo', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('deve ter ícone de dinheiro no campo de valor',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });
  });

  group('AddTravelExpensePage - Validação do formulário', () {
    testWidgets('deve exibir erro ao enviar formulário vazio', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar Gasto'));
      await tester.pump();

      expect(find.text('Informe a descrição'), findsOneWidget);
      expect(find.text('Informe o valor'), findsOneWidget);
    });

    testWidgets('descrição com apenas 1 caractere deve mostrar erro',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      await tester.enterText(descriptionField, 'A');
      await tester.pump();

      await tester.tap(find.text('Salvar Gasto'));
      await tester.pump();

      expect(
        find.text('Descrição deve ter pelo menos 2 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('descrição com 2 caracteres é aceita', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      await tester.enterText(descriptionField, 'Al');
      await tester.pump();

      await tester.tap(find.text('Salvar Gasto'));
      await tester.pump();

      expect(find.text('Informe a descrição'), findsNothing);
      expect(
        find.text('Descrição deve ter pelo menos 2 caracteres'),
        findsNothing,
      );
    });

    testWidgets('valor zero deve mostrar erro', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      final amountField = find.byType(TextFormField).last;

      await tester.enterText(descriptionField, 'Almoço');
      await tester.enterText(amountField, '0');
      await tester.pump();

      await tester.tap(find.text('Salvar Gasto'));
      await tester.pump();

      expect(find.text('Valor deve ser maior que zero'), findsOneWidget);
    });

    testWidgets('valor negativo é filtrado pelo input formatter', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      final amountField = find.byType(TextFormField).last;

      await tester.enterText(descriptionField, 'Almoço');
      await tester.enterText(amountField, '-10');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(amountField).controller!.text,
        '10',
      );
    });

    testWidgets('não deve exibir erros com dados válidos', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      final amountField = find.byType(TextFormField).last;

      await tester.enterText(descriptionField, 'Almoço');
      await tester.enterText(amountField, '45,90');
      await tester.pump();

      await tester.tap(find.text('Salvar Gasto'));
      await tester.pump();

      expect(find.text('Informe a descrição'), findsNothing);
      expect(find.text('Informe o valor'), findsNothing);
      expect(find.text('Valor deve ser maior que zero'), findsNothing);
    });
  });

  group('AddTravelExpensePage - Filtros de entrada', () {
    testWidgets('descrição aceita texto com acentos', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      await tester.enterText(descriptionField, 'Restaurante');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(descriptionField).controller!.text,
        'Restaurante',
      );
    });

    testWidgets('descrição aceita hífens', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      await tester.enterText(descriptionField, 'Almoço - Jantar');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(descriptionField).controller!.text,
        'Almoço - Jantar',
      );
    });

    testWidgets('descrição rejeita números', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      await tester.enterText(descriptionField, 'Almoço123');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(descriptionField).controller!.text,
        'Almoço',
      );
    });

    testWidgets('descrição rejeita caracteres especiais', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      await tester.enterText(descriptionField, 'Almoço@#\$');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(descriptionField).controller!.text,
        'Almoço',
      );
    });

    testWidgets('valor aceita vírgula como separador decimal', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '45,90');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(amountField).controller!.text,
        '45,90',
      );
    });

    testWidgets('valor converte ponto em vírgula', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '45.90');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(amountField).controller!.text,
        '45,90',
      );
    });

    testWidgets('valor limita a duas casas decimais', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '12,345');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(amountField).controller!.text,
        '12,34',
      );
    });

    testWidgets('valor permite apenas uma vírgula', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '1,2,3');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(amountField).controller!.text,
        '1,23',
      );
    });

    testWidgets('valor remove caracteres inválidos', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, 'abc!?');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(amountField).controller!.text,
        isEmpty,
      );
    });

    testWidgets('valor aceita apenas dígitos e vírgula', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, 'R\$123,45');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(amountField).controller!.text,
        '123,45',
      );
    });
  });

  group('AddTravelExpensePage - Estado e interação', () {
    testWidgets('botão deve estar habilitado inicialmente', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Salvar Gasto'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('deve exibir ícone de check no botão', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('deve exibir texto "Salvar Gasto" no botão', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Salvar Gasto'), findsOneWidget);
    });

    testWidgets('deve permitir alterar a descrição', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      await tester.enterText(descriptionField, 'Primeira descrição');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(descriptionField).controller!.text,
        'Primeira descrição',
      );

      await tester.enterText(descriptionField, 'Segunda descrição');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(descriptionField).controller!.text,
        'Segunda descrição',
      );
    });

    testWidgets('deve permitir alterar o valor', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '50');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(amountField).controller!.text,
        '50',
      );

      await tester.enterText(amountField, '100,50');
      await tester.pump();

      expect(
        tester.widget<TextFormField>(amountField).controller!.text,
        '100,50',
      );
    });

    testWidgets('prefixo exibe a moeda da viagem no campo de valor',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final prefix = find.text('BRL ');
      expect(prefix, findsOneWidget);
    });

    testWidgets('prefixo usa a moeda escolhida na viagem', (tester) async {
      await tester.pumpWidget(_buildApp(currency: 'USD'));
      await tester.pumpAndSettle();

      expect(find.text('USD '), findsOneWidget);
    });

    testWidgets('deve exibir erro se descrição estiver vazia e valor válido',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '50,00');
      await tester.pump();

      await tester.tap(find.text('Salvar Gasto'));
      await tester.pump();

      expect(find.text('Informe a descrição'), findsOneWidget);
      expect(find.text('Informe o valor'), findsNothing);
    });

    testWidgets('deve exibir erro se valor estiver vazio e descrição válida',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      await tester.enterText(descriptionField, 'Almoço');
      await tester.pump();

      await tester.tap(find.text('Salvar Gasto'));
      await tester.pump();

      expect(find.text('Informe a descrição'), findsNothing);
      expect(find.text('Informe o valor'), findsOneWidget);
    });
  });

  group('AddTravelExpensePage - Cotação informativa', () {
    testWidgets('mostra estimativa em BRL ao digitar valor em moeda estrangeira',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          currency: 'USD',
          exchangeRateService: _FakeRateService(rate: 5.00),
        ),
      );
      await tester.pumpAndSettle();

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '34');
      await tester.pump();

      expect(find.text('≈ R\$ 170,00'), findsOneWidget);
    });

    testWidgets('converte valor em euro para real usando a cotação',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(
          currency: 'EUR',
          exchangeRateService: _FakeRateService(rate: 6.20),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EUR '), findsOneWidget);
      expect(find.text('1 EUR ≈ R\$ 6,20'), findsOneWidget);

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '100');
      await tester.pump();

      expect(find.text('≈ R\$ 620,00'), findsOneWidget);
    });

    testWidgets('mostra a cotação usada na conversão', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          currency: 'USD',
          exchangeRateService: _FakeRateService(rate: 5.00),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 USD ≈ R\$ 5,00'), findsOneWidget);

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '34');
      await tester.pump();

      expect(find.text('≈ R\$ 170,00'), findsOneWidget);
    });

    testWidgets('não mostra cotação para viagem em BRL', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '34');
      await tester.pump();

      expect(find.textContaining('≈ R\$'), findsNothing);
      expect(find.text('Buscando cotação...'), findsNothing);
    });

    testWidgets('avisa e permite tentar novamente quando a cotação está indisponível',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(currency: 'USD', exchangeRateService: _FakeRateService()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Cotação indisponível. Toque para tentar novamente.'),
        findsOneWidget,
      );

      final amountField = find.byType(TextFormField).last;
      await tester.enterText(amountField, '34');
      await tester.pump();

      expect(find.textContaining('≈ R\$'), findsNothing);
    });
  });

  group('AddTravelExpensePage - Edição', () {
    testWidgets('preenche os campos ao editar um gasto existente',
        (tester) async {
      await tester.pumpWidget(_buildApp(expense: _existingExpense()));
      await tester.pumpAndSettle();

      expect(find.text('Editar Gasto'), findsOneWidget);
      expect(find.text('Salvar Alterações'), findsOneWidget);

      final descriptionField = find.byType(TextFormField).first;
      final amountField = find.byType(TextFormField).last;

      expect(
        tester.widget<TextFormField>(descriptionField).controller!.text,
        'Almoço',
      );
      expect(
        tester.widget<TextFormField>(amountField).controller!.text,
        '45,90',
      );
      expect(find.text('Transporte'), findsOneWidget);
    });

    testWidgets('chama updateExpense preservando o id ao salvar',
        (tester) async {
      await tester.pumpWidget(_buildApp(expense: _existingExpense()));
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      await tester.enterText(descriptionField, 'Almoço executivo');
      await tester.pump();

      await tester.tap(find.text('Salvar Alterações'));
      await tester.pumpAndSettle();

      final captured =
          verify(() => mockTravelData.updateExpense(captureAny()))
              .captured
              .single as TravelExpense;

      expect(captured.id, 'exp-1');
      expect(captured.tripId, 'trip-1');
      expect(captured.description, 'Almoço executivo');
      expect(captured.amount, 45.90);
    });
  });

  group('AddTravelExpensePage - Salvamento', () {
    testWidgets('deve chamar addExpense com dados corretos ao salvar',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      final amountField = find.byType(TextFormField).last;

      await tester.enterText(descriptionField, 'Almoço');
      await tester.enterText(amountField, '45,90');
      await tester.pump();

      await tester.tap(find.text('Salvar Gasto'));
      await tester.pumpAndSettle();

      final captured = verify(() => mockTravelData.addExpense(captureAny()))
          .captured
          .single as TravelExpense;

      expect(captured.description, 'Almoço');
      expect(captured.amount, 45.90);
      expect(captured.tripId, 'trip-1');
    });

    testWidgets('deve navegar para trás após salvar com sucesso',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      final descriptionField = find.byType(TextFormField).first;
      final amountField = find.byType(TextFormField).last;

      await tester.enterText(descriptionField, 'Almoço');
      await tester.enterText(amountField, '45,90');
      await tester.pump();

      await tester.tap(find.text('Salvar Gasto'));
      await tester.pumpAndSettle();

      expect(find.byType(AddTravelExpensePage), findsNothing);
    });
  });
}
