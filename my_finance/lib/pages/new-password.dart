import 'package:flutter/material.dart';
import 'package:my_finance/pages/login_page.dart';
import 'package:my_finance/providers/forgot_password_provider.dart';
import 'package:my_finance/widgets/auth/auth_header.dart';
import 'package:my_finance/widgets/auth/auth_link.dart';
import 'package:my_finance/widgets/auth/auth_scaffold.dart';
import 'package:my_finance/widgets/auth/auth_submit_button.dart';
import 'package:my_finance/widgets/auth/auth_text_field.dart';

class NewPasswordPage extends StatefulWidget {
  final String code;
  final ForgotPasswordProvider? provider;

  const NewPasswordPage({
    super.key,
    required this.code,
    this.provider,
  });

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final ForgotPasswordProvider _provider =
      widget.provider ?? ForgotPasswordProvider();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _provider.confirmReset(
      code: widget.code,
      newPassword: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha redefinida com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else if (_provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_provider.error!),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe a nova senha';
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um número';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um caractere especial';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AuthHeader(
              icon: Icons.lock_outline,
              title: 'Nova senha',
              subtitle: 'Crie uma nova senha para sua conta',
              showIcon: true,
            ),
            const SizedBox(height: 32),
            AuthTextField(
              controller: _passwordController,
              label: 'Nova senha',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmPasswordController,
              label: 'Confirmar senha',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirme a nova senha';
                }
                if (value != _passwordController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: _provider,
              builder: (context, _) => AuthSubmitButton(
                label: 'Redefinir senha',
                isLoading: _provider.isLoading,
                onPressed: _resetPassword,
              ),
            ),
            const SizedBox(height: 16),
            AuthLink(
              text: '',
              linkLabel: 'Voltar ao login',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}