import 'package:flutter/material.dart';
import 'package:my_finance/utils/password_strength.dart';

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = getPasswordStrength(password);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i < _filledSegments(strength)
                        ? _colorFor(strength)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _labelFor(strength),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _colorFor(strength),
          ),
        ),
      ],
    );
  }

  int _filledSegments(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 1;
      case PasswordStrength.medium:
        return 2;
      case PasswordStrength.strong:
        return 3;
    }
  }

  Color _colorFor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  String _labelFor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Senha fraca';
      case PasswordStrength.medium:
        return 'Senha média';
      case PasswordStrength.strong:
        return 'Senha forte';
    }
  }
}