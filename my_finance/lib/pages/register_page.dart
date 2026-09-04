import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/pages/login_page.dart';
import 'package:my_finance/services/auth_service.dart';
import 'package:my_finance/utils/password_strength.dart';
import 'package:my_finance/widgets/auth/auth_header.dart';
import 'package:my_finance/widgets/auth/auth_link.dart';
import 'package:my_finance/widgets/auth/auth_scaffold.dart';
import 'package:my_finance/widgets/auth/auth_submit_button.dart';
import 'package:my_finance/widgets/auth/auth_text_field.dart';
import 'package:my_finance/widgets/auth/password_strength_bar.dart';

class RegisterPage extends StatefulWidget {
  final AuthService? authService;

  const RegisterPage({super.key, this.authService});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  AuthService get _authService =>
      widget.authService ?? AuthService.getShared();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await _authService.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Conta criada com sucesso! Faça login para continuar.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
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
        case 'email-already-in-use':
          return 'Este email já está em uso.';
        case 'invalid-email':
          return 'Email inválido.';
        case 'weak-password':
          return 'A senha é muito fraca.';
        case 'network-request-failed':
          return 'Falha de conexão. Verifique sua internet.';
      }
    }
    return 'Erro ao criar conta. Tente novamente.';
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
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
              icon: Icons.person_add_outlined,
              title: 'Criar Conta',
              subtitle: 'Preencha seus dados para se cadastrar',
              showIcon: true,
            ),
            const SizedBox(height: 32),
            AuthTextField(
              controller: _nameController,
              label: 'Nome',
              icon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe o nome';
                if (value.trim().length < 2) {
                  return 'Nome deve ter pelo menos 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe o email';
                if (!_isValidEmail(value)) return 'Email inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              label: 'Senha',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: validateStrongPassword,
            ),
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              PasswordStrengthBar(password: _passwordController.text),
            ],
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmPasswordController,
              label: 'Confirmar senha',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Confirme a senha';
                if (value != _passwordController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            AuthSubmitButton(
              label: 'Criar conta',
              isLoading: _isLoading,
              onPressed: _register,
            ),
            const SizedBox(height: 16),
            AuthLink(
              text: 'Já tem conta? ',
              linkLabel: 'Fazer login',
              onPressed: _goToLogin,
            ),
          ],
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }
}
