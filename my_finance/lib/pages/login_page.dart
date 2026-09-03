import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/pages/register_page.dart';
import 'package:my_finance/services/auth_service.dart';
import 'package:my_finance/widgets/auth/auth_header.dart';
import 'package:my_finance/widgets/auth/auth_link.dart';
import 'package:my_finance/widgets/auth/auth_scaffold.dart';
import 'package:my_finance/widgets/auth/auth_submit_button.dart';
import 'package:my_finance/widgets/auth/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  final AuthService? authService;

  const LoginPage({super.key, this.authService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  AuthService get _authService =>
      widget.authService ?? AuthService.getShared();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Usuário não encontrado.';
        case 'wrong-password':
          return 'Senha incorreta.';
        case 'invalid-email':
          return 'Email inválido.';
        case 'invalid-credential':
          return 'Email ou senha incorretos.';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente mais tarde.';
        case 'user-disabled':
          return 'Esta conta está desativada.';
        case 'network-request-failed':
          return 'Falha de conexão. Verifique sua internet.';
      }
    }
    return 'Erro ao fazer login. Tente novamente.';
  }

  void _goToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
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
              title: 'My Finance',
              subtitle: 'Entre na sua conta',
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
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              label: 'Senha',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe a senha';
                if (value.length < 6) {
                  return 'A senha deve ter pelo menos 6 caracteres';
                }
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Esqueceu a senha?',
                style: TextStyle(
                  color: Color.fromARGB(255, 61, 12, 94),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            AuthSubmitButton(
              label: 'Entrar',
              isLoading: _isLoading,
              onPressed: _login,
            ),
            const SizedBox(height: 16),
            AuthLink(
              text: 'Não tem conta? ',
              linkLabel: 'Criar conta',
              onPressed: _goToRegister,
            ),
          ],
        ),
      ),
    );
  }
}
