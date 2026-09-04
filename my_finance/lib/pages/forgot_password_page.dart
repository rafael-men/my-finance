import 'package:flutter/material.dart';
import 'package:my_finance/pages/login_page.dart';
import 'package:my_finance/providers/forgot_password_provider.dart';
import 'package:my_finance/widgets/auth/auth_header.dart';
import 'package:my_finance/widgets/auth/auth_link.dart';
import 'package:my_finance/widgets/auth/auth_scaffold.dart';
import 'package:my_finance/widgets/auth/auth_submit_button.dart';
import 'package:my_finance/widgets/auth/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  final ForgotPasswordProvider? provider;

  const ForgotPasswordPage({super.key, this.provider});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  late final ForgotPasswordProvider _provider =
      widget.provider ?? ForgotPasswordProvider();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    await _provider.sendResetEmail(_emailController.text);
    if (!mounted) return;

    if (_provider.emailSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enviamos um link de recuperação para o seu email.'),
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

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AuthHeader(
              icon: Icons.lock_reset_outlined,
              title: 'Recuperar senha',
              subtitle: 'Informe seu email para receber um link',
              showIcon: true,
            ),
            const SizedBox(height: 32),
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe o email';
                if (!value.contains('@')) return 'Email inválido';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: _provider,
              builder: (context, _) => AuthSubmitButton(
                label: 'Enviar link',
                isLoading: _provider.isLoading,
                onPressed: _sendResetLink,
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