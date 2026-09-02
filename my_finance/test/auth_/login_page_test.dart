import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_finance/pages/login_page.dart';
import 'package:my_finance/pages/register_page.dart';
import 'package:my_finance/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserStore extends Mock implements UserStore {}

void main() {
  Widget createTestableWidget(Widget child) {
    return MaterialApp(home: child);
  }

  group('LoginPage Widget Tests', () {
    testWidgets('deve renderizar todos os elementos principais',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      expect(find.text('My Finance'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Criar conta'), findsOneWidget);
    });

    testWidgets('deve mostrar erro se email estiver vazio',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Informe o email'), findsOneWidget);
    });

    testWidgets('deve mostrar erro se email for inválido (sem @)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'email_invalido',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('deve mostrar erro se senha estiver vazia',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'teste@teste.com',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Informe a senha'), findsOneWidget);
    });

    testWidgets('deve mostrar erro se senha tiver menos de 6 caracteres',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'teste@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '123',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('não deve mostrar erros com email e senha válidos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'teste@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '123456',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Informe o email'), findsNothing);
      expect(find.text('Email inválido'), findsNothing);
      expect(find.text('Informe a senha'), findsNothing);
      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsNothing,
      );
    });

    testWidgets('deve alternar visibilidade da senha ao tocar no ícone',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      final passwordField = find.widgetWithText(TextFormField, 'Senha');
      bool isObscured() {
        return tester
            .widget<EditableText>(
              find.descendant(
                of: passwordField,
                matching: find.byType(EditableText),
              ),
            )
            .obscureText;
      }

      expect(isObscured(), isTrue);

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(isObscured(), isFalse);
    });

    testWidgets('deve navegar para RegisterPage ao tocar em "Criar conta"',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const LoginPage()));

      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('deve mostrar CircularProgressIndicator durante loading',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      when(() => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) => Completer<UserCredential>().future);
      when(() => mockAuth.authStateChanges()).thenAnswer(
        (_) => const Stream<User?>.empty(),
      );

      final authService = AuthService(
        auth: mockAuth,
        userStore: MockUserStore(),
      );

      await tester.pumpWidget(
        createTestableWidget(LoginPage(authService: authService)),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'teste@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '123456',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}