import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_finance/pages/forgot_password_page.dart';
import 'package:my_finance/pages/login_page.dart';
import 'package:my_finance/providers/forgot_password_provider.dart';
import 'package:my_finance/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuth;
  late ForgotPasswordProvider provider;

  setUpAll(() {
    registerFallbackValue(FirebaseAuthException(code: 'test', message: 'test'));
  });

  setUp(() {
    mockAuth = MockAuthService();
    provider = ForgotPasswordProvider(authService: mockAuth);
  });

  Widget buildApp({ForgotPasswordProvider? prov}) {
    return MaterialApp(
      home: ForgotPasswordPage(provider: prov ?? provider),
    );
  }

  group('ForgotPasswordPage - Renderização', () {
    testWidgets('deve renderizar o título e subtítulo', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Recuperar senha'), findsOneWidget);
      expect(
        find.text('Informe seu email para receber um link'),
        findsOneWidget,
      );
    });

    testWidgets('deve renderizar o campo de email', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('deve renderizar o botão enviar', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Enviar link'), findsOneWidget);
    });

    testWidgets('deve renderizar o link voltar ao login', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Voltar ao login'), findsOneWidget);
    });

    testWidgets('deve ter ícone de cadeado no header', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_reset_outlined), findsOneWidget);
    });

    testWidgets('deve ter ícone de email no campo', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });
  });

  group('ForgotPasswordPage - Validação', () {
    testWidgets('deve mostrar erro quando email está vazio', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enviar link'));
      await tester.pump();

      expect(find.text('Informe o email'), findsOneWidget);
    });

    testWidgets('deve mostrar erro quando email é inválido', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'email-invalido',
      );
      await tester.tap(find.text('Enviar link'));
      await tester.pump();

      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('não deve mostrar erros com email válido', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'teste@email.com',
      );
      await tester.tap(find.text('Enviar link'));
      await tester.pump();

      expect(find.text('Informe o email'), findsNothing);
      expect(find.text('Email inválido'), findsNothing);
    });
  });

  group('ForgotPasswordPage - Envio de email', () {
    testWidgets('deve chamar sendResetEmail com o email informado',
        (tester) async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'teste@email.com',
      );
      await tester.tap(find.text('Enviar link'));
      await tester.pumpAndSettle();

      verify(() => mockAuth.sendPasswordResetEmail('teste@email.com'))
          .called(1);
    });

    testWidgets('deve mostrar indicador de loading durante o envio',
        (tester) async {
      final completer = Completer<void>();
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'teste@email.com',
      );
      await tester.tap(find.text('Enviar link'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Enviar link'), findsNothing);

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('deve navegar para LoginPage após envio bem-sucedido',
        (tester) async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenAnswer((_) async {});

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'teste@email.com',
      );
      await tester.tap(find.text('Enviar link'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(ForgotPasswordPage), findsNothing);
    });

    testWidgets(
        'deve mostrar snackbar de erro quando email não existe',
        (tester) async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'inexistente@email.com',
      );
      await tester.tap(find.text('Enviar link'));
      await tester.pumpAndSettle();

      expect(
        find.text('Nenhuma conta encontrada com este email.'),
        findsOneWidget,
      );
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
    });

    testWidgets(
        'deve permanecer na página quando ocorre erro',
        (tester) async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'inexistente@email.com',
      );
      await tester.tap(find.text('Enviar link'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets(
        'deve mostrar erro genérico para exceções inesperadas',
        (tester) async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenThrow(Exception('erro'));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'teste@email.com',
      );
      await tester.tap(find.text('Enviar link'));
      await tester.pumpAndSettle();

      expect(
        find.text('Erro ao enviar email. Tente novamente.'),
        findsOneWidget,
      );
    });
  });

  group('ForgotPasswordPage - Navegação', () {
    testWidgets('deve navegar para LoginPage ao tocar em voltar',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Voltar ao login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(ForgotPasswordPage), findsNothing);
    });
  });
}
