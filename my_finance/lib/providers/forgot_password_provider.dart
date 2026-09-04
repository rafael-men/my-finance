import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_finance/services/auth_service.dart' show AuthService;

class ForgotPasswordProvider extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  bool _emailSent = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get emailSent => _emailSent;
  String? get error => _error;

  ForgotPasswordProvider({AuthService? authService})
      : _authService = authService ?? AuthService.getShared();

  Future<void> sendResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email.trim());
      _emailSent = true;
    } on FirebaseAuthException catch (e) {
      _error = _mapError(e);
    } catch (e) {
      _error = 'Erro ao enviar email. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmReset({
    required String code,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapResetError(e);
      return false;
    } catch (e) {
      _error = 'Erro ao redefinir a senha. Tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _emailSent = false;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  String _mapResetError(FirebaseAuthException e) {
    switch (e.code) {
      case 'expired-action-code':
        return 'O código expirou. Solicite um novo link de recuperação.';
      case 'invalid-action-code':
        return 'Código inválido. Solicite um novo link de recuperação.';
      case 'user-disabled':
        return 'Esta conta está desativada.';
      default:
        return 'Erro ao redefinir a senha. Tente novamente.';
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este email.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet.';
      default:
        return 'Erro ao enviar email. Tente novamente.';
    }
  }
}
