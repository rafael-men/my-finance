enum PasswordStrength { weak, medium, strong }

PasswordStrength getPasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.weak;

  final hasLower = RegExp(r'[a-z]').hasMatch(password);
  final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
  final hasDigit = RegExp(r'[0-9]').hasMatch(password);
  final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(password);

  if (password.length >= 8 && hasLower && hasUpper && hasDigit && hasSpecial) {
    return PasswordStrength.strong;
  }

  if (password.length >= 6) {
    return PasswordStrength.medium;
  }

  return PasswordStrength.weak;
}

String? validateStrongPassword(String? value) {
  if (value == null || value.isEmpty) return 'Informe a senha';
  if (value.length < 8) return 'A senha deve ter pelo menos 8 caracteres';
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'A senha deve ter pelo menos 1 letra minúscula';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'A senha deve ter pelo menos 1 letra maiúscula';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'A senha deve ter pelo menos 1 número';
  }
  if (!RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
    return 'A senha deve ter pelo menos 1 caractere especial';
  }
  return null;
}