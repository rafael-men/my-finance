import 'app_exception.dart';

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.origin, super.cause});
}
