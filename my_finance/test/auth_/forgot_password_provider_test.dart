import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  group('sendResetEmail', () {
    test('deve enviar email com sucesso', () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenAnswer((_) async {});

      await provider.sendResetEmail('teste@email.com');

      expect(provider.emailSent, isTrue);
      expect(provider.error, isNull);
      verify(() => mockAuth.sendPasswordResetEmail('teste@email.com'))
          .called(1);
    });

    test('deve trimar o email antes de enviar', () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenAnswer((_) async {});

      await provider.sendResetEmail('  teste@email.com  ');

      verify(() => mockAuth.sendPasswordResetEmail('teste@email.com'))
          .called(1);
    });

    test('deve definir emailSent como false ao falhar', () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await provider.sendResetEmail('inexistente@email.com');

      expect(provider.emailSent, isFalse);
    });

    test('deve retornar erro quando email não existe', () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await provider.sendResetEmail('inexistente@email.com');

      expect(
        provider.error,
        'Nenhuma conta encontrada com este email.',
      );
    });

    test('deve retornar erro quando email é inválido', () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenThrow(FirebaseAuthException(code: 'invalid-email'));

      await provider.sendResetEmail('email-invalido');

      expect(provider.error, 'Email inválido.');
    });

    test('deve retornar erro quando há muitas tentativas', () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenThrow(FirebaseAuthException(code: 'too-many-requests'));

      await provider.sendResetEmail('teste@email.com');

      expect(
        provider.error,
        'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
      );
    });

    test('deve retornar erro quando falha a conexão', () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      await provider.sendResetEmail('teste@email.com');

      expect(
        provider.error,
        'Falha de conexão. Verifique sua internet.',
      );
    });

    test('deve retornar erro genérico para outros erros', () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenThrow(FirebaseAuthException(code: 'unknown'));

      await provider.sendResetEmail('teste@email.com');

      expect(
        provider.error,
        'Erro ao enviar email. Tente novamente.',
      );
    });

    test('deve retornar erro genérico para exceções não-Firebase',
        () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenThrow(Exception('erro inesperado'));

      await provider.sendResetEmail('teste@email.com');

      expect(
        provider.error,
        'Erro ao enviar email. Tente novamente.',
      );
    });

    test('deve alternar isLoading durante a operação', () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenAnswer((_) async {});

      expect(provider.isLoading, isFalse);

      final future = provider.sendResetEmail('teste@email.com');

      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
    });

    test('deve limpar erro anterior ao enviar novamente', () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await provider.sendResetEmail('inexistente@email.com');
      expect(provider.error, isNotNull);

      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenAnswer((_) async {});

      await provider.sendResetEmail('valido@email.com');
      expect(provider.error, isNull);
      expect(provider.emailSent, isTrue);
    });
  });

  group('confirmReset', () {
    test('deve confirmar redefinição com sucesso', () async {
      when(() => mockAuth.confirmPasswordReset(
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async {});

      final result = await provider.confirmReset(
        code: 'valid-code',
        newPassword: 'NovaSenh@123',
      );

      expect(result, isTrue);
      expect(provider.error, isNull);
      verify(() => mockAuth.confirmPasswordReset(
            code: 'valid-code',
            newPassword: 'NovaSenh@123',
          )).called(1);
    });

    test('deve retornar false quando código expirou', () async {
      when(() => mockAuth.confirmPasswordReset(
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          )).thenThrow(FirebaseAuthException(code: 'expired-action-code'));

      final result = await provider.confirmReset(
        code: 'expired-code',
        newPassword: 'NovaSenh@123',
      );

      expect(result, isFalse);
      expect(
        provider.error,
        'O código expirou. Solicite um novo link de recuperação.',
      );
    });

    test('deve retornar false quando código é inválido', () async {
      when(() => mockAuth.confirmPasswordReset(
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          )).thenThrow(FirebaseAuthException(code: 'invalid-action-code'));

      final result = await provider.confirmReset(
        code: 'invalid-code',
        newPassword: 'NovaSenh@123',
      );

      expect(result, isFalse);
      expect(
        provider.error,
        'Código inválido. Solicite um novo link de recuperação.',
      );
    });

    test('deve retornar false quando conta está desativada', () async {
      when(() => mockAuth.confirmPasswordReset(
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          )).thenThrow(FirebaseAuthException(code: 'user-disabled'));

      final result = await provider.confirmReset(
        code: 'code',
        newPassword: 'NovaSenh@123',
      );

      expect(result, isFalse);
      expect(provider.error, 'Esta conta está desativada.');
    });

    test('deve retornar false para erro genérico', () async {
      when(() => mockAuth.confirmPasswordReset(
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          )).thenThrow(FirebaseAuthException(code: 'unknown'));

      final result = await provider.confirmReset(
        code: 'code',
        newPassword: 'NovaSenh@123',
      );

      expect(result, isFalse);
      expect(
        provider.error,
        'Erro ao redefinir a senha. Tente novamente.',
      );
    });

    test('deve retornar false para exceções não-Firebase', () async {
      when(() => mockAuth.confirmPasswordReset(
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          )).thenThrow(Exception('erro'));

      final result = await provider.confirmReset(
        code: 'code',
        newPassword: 'NovaSenh@123',
      );

      expect(result, isFalse);
      expect(
        provider.error,
        'Erro ao redefinir a senha. Tente novamente.',
      );
    });

    test('deve alternar isLoading durante a operação', () async {
      when(() => mockAuth.confirmPasswordReset(
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async {});

      expect(provider.isLoading, isFalse);

      final future = provider.confirmReset(
        code: 'code',
        newPassword: 'NovaSenh@123',
      );

      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
    });
  });

  group('reset', () {
    test('deve limpar todo o estado', () async {
      when(() => mockAuth.sendPasswordResetEmail(any()))
          .thenAnswer((_) async {});

      await provider.sendResetEmail('teste@email.com');
      expect(provider.emailSent, isTrue);

      provider.reset();

      expect(provider.emailSent, isFalse);
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    });
  });
}
