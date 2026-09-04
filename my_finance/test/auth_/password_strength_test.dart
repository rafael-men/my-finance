import 'package:flutter_test/flutter_test.dart';
import 'package:my_finance/utils/password_strength.dart';

void main() {
  group('getPasswordStrength', () {
    test('senha vazia é fraca', () {
      expect(getPasswordStrength(''), PasswordStrength.weak);
    });

    test('senha curta é fraca', () {
      expect(getPasswordStrength('abc'), PasswordStrength.weak);
      expect(getPasswordStrength('12'), PasswordStrength.weak);
    });

    test('senha de 6 caracteres sem todas as regras é média', () {
      expect(getPasswordStrength('senha1'), PasswordStrength.medium);
      expect(getPasswordStrength('SENHA1'), PasswordStrength.medium);
    });

    test('senha de 7 caracteres é média mesmo com todas as regras', () {
      expect(getPasswordStrength('Senh@12'), PasswordStrength.medium);
    });

    test('senha de 8 caracteres com todas as regras é forte', () {
      expect(
        getPasswordStrength('Senha@12'),
        PasswordStrength.strong,
      );
      expect(
        getPasswordStrength('Abcd@123'),
        PasswordStrength.strong,
      );
    });

    test('senha forte requer maiúscula, minúscula, número e especial',
        () {
      expect(getPasswordStrength('abcdefgh'), PasswordStrength.medium);
      expect(getPasswordStrength('ABCDEFGH'), PasswordStrength.medium);
      expect(getPasswordStrength('abcd1234'), PasswordStrength.medium);
      expect(getPasswordStrength('Abcd1234'), PasswordStrength.medium);
      expect(getPasswordStrength('Abcd@123'), PasswordStrength.strong);
    });

    test('senha de 8 caracteres sem especial não é forte', () {
      expect(getPasswordStrength('Senha123'), PasswordStrength.medium);
    });
  });

  group('validateStrongPassword', () {
    test('senha vazia retorna erro', () {
      expect(validateStrongPassword(''), 'Informe a senha');
      expect(validateStrongPassword(null), 'Informe a senha');
    });

    test('senha curta retorna erro de tamanho', () {
      expect(
        validateStrongPassword('abc'),
        'A senha deve ter pelo menos 8 caracteres',
      );
    });

    test('senha sem minúscula retorna erro', () {
      expect(
        validateStrongPassword('SENHA@123'),
        'A senha deve ter pelo menos 1 letra minúscula',
      );
    });

    test('senha sem maiúscula retorna erro', () {
      expect(
        validateStrongPassword('senha@123'),
        'A senha deve ter pelo menos 1 letra maiúscula',
      );
    });

    test('senha sem número retorna erro', () {
      expect(
        validateStrongPassword('Senha@abc'),
        'A senha deve ter pelo menos 1 número',
      );
    });

    test('senha sem caractere especial retorna erro', () {
      expect(
        validateStrongPassword('Senha123'),
        'A senha deve ter pelo menos 1 caractere especial',
      );
    });

    test('senha forte passa na validação', () {
      expect(validateStrongPassword('Senha@123'), isNull);
    });
  });
}