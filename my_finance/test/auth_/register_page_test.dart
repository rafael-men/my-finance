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

  group('RegisterPage Widget Tests', () {
    testWidgets('deve renderizar todos os elementos principais',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      expect(find.text('Criar Conta'), findsOneWidget);
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Confirmar senha'), findsOneWidget);
      expect(find.text('Criar conta'), findsOneWidget);
      expect(find.text('Fazer login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('deve mostrar erro se nome estiver vazio',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('Informe o nome'), findsOneWidget);
    });

    testWidgets('deve mostrar erro se nome tiver menos de 2 caracteres',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'A',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(
        find.text('Nome deve ter pelo menos 2 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro se email estiver vazio',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('Informe o email'), findsOneWidget);
    });

    testWidgets('deve mostrar erro se email for inválido (sem @)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'email_invalido',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('deve mostrar erro se email não tiver domínio',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('deve mostrar erro se email tiver domínio sem ponto',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@testecom',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('deve mostrar erro se email tiver espaços',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael @teste.com',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('deve aceitar email em formato correto apenas depois do @',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('Email inválido'), findsNothing);
      expect(find.text('Informe o email'), findsNothing);
    });

    testWidgets('deve mostrar erro se senha estiver vazia',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('Informe a senha'), findsOneWidget);
    });

    testWidgets('deve mostrar erro se senha tiver menos de 8 caracteres',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '123',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 8 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro se senha não tiver letra maiúscula',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'senha@123',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 1 letra maiúscula'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro se senha não tiver número',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Senha@abc',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 1 número'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro se senha não tiver caractere especial',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Senha123',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 1 caractere especial'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro se confirmar senha estiver vazio',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Senha@123',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('Confirme a senha'), findsOneWidget);
    });

    testWidgets('deve mostrar erro se senhas não coincidem',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Senha@123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirmar senha'),
        'Senha@456',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('não deve mostrar erros com dados válidos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Senha@123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirmar senha'),
        'Senha@123',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.text('Informe o nome'), findsNothing);
      expect(find.text('Informe o email'), findsNothing);
      expect(find.text('Informe a senha'), findsNothing);
      expect(find.text('Confirme a senha'), findsNothing);
      expect(
        find.text('A senha deve ter pelo menos 8 caracteres'),
        findsNothing,
      );
      expect(
        find.text('A senha deve ter pelo menos 1 letra minúscula'),
        findsNothing,
      );
      expect(
        find.text('A senha deve ter pelo menos 1 letra maiúscula'),
        findsNothing,
      );
      expect(
        find.text('A senha deve ter pelo menos 1 número'),
        findsNothing,
      );
      expect(
        find.text('A senha deve ter pelo menos 1 caractere especial'),
        findsNothing,
      );
    });

    testWidgets('deve alternar visibilidade da senha ao tocar no ícone',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

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

      final visibilityIcon = find.descendant(
        of: passwordField,
        matching: find.byIcon(Icons.visibility_off_outlined),
      );
      expect(visibilityIcon, findsOneWidget);

      await tester.tap(visibilityIcon);
      await tester.pump();

      expect(
        find.descendant(
          of: passwordField,
          matching: find.byIcon(Icons.visibility_outlined),
        ),
        findsOneWidget,
      );
      expect(isObscured(), isFalse);
    });

    testWidgets('deve mostrar erro se senha não tiver letra minúscula',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'SENHA@123',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 1 letra minúscula'),
        findsOneWidget,
      );
    });

    testWidgets('deve rejeitar senha média (só autoriza senha forte)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Senha123',
      );
      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 1 caractere especial'),
        findsOneWidget,
      );
    });

    testWidgets('não deve exibir barra de força com senha vazia',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      expect(
        find.text('Senha fraca'),
        findsNothing,
      );
      expect(
        find.text('Senha média'),
        findsNothing,
      );
      expect(
        find.text('Senha forte'),
        findsNothing,
      );
    });

    testWidgets('deve exibir barra "Senha fraca" para senha de 3 caracteres',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'abc',
      );
      await tester.pump();

      expect(find.text('Senha fraca'), findsOneWidget);
    });

    testWidgets('deve exibir barra "Senha média" para senha de 6 caracteres',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'senha1',
      );
      await tester.pump();

      expect(find.text('Senha média'), findsOneWidget);
    });

    testWidgets('deve exibir barra "Senha forte" para senha com todos critérios',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Senha@123',
      );
      await tester.pump();

      expect(find.text('Senha forte'), findsOneWidget);
    });

    testWidgets('deve atualizar a barra enquanto a senha é digitada',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      final passwordField =
          find.widgetWithText(TextFormField, 'Senha');

      await tester.enterText(passwordField, 'abc');
      await tester.pump();
      expect(find.text('Senha fraca'), findsOneWidget);

      await tester.enterText(passwordField, 'senha1');
      await tester.pump();
      expect(find.text('Senha média'), findsOneWidget);

      await tester.enterText(passwordField, 'Senha@123');
      await tester.pump();
      expect(find.text('Senha forte'), findsOneWidget);
    });

    testWidgets('deve navegar para LoginPage ao tocar em "Fazer login"',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(const RegisterPage()));

      await tester.ensureVisible(find.text('Fazer login'));
      await tester.tap(find.text('Fazer login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(RegisterPage), findsNothing);
    });

    testWidgets('deve mostrar CircularProgressIndicator durante loading',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      when(() => mockAuth.createUserWithEmailAndPassword(
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
        createTestableWidget(RegisterPage(authService: authService)),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Rafael',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rafael@teste.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'Senha@123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirmar senha'),
        'Senha@123',
      );

      await tester.ensureVisible(find.text('Criar conta'));
      await tester.tap(find.text('Criar conta'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
