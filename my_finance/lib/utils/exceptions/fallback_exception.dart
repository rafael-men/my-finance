import 'app_exception.dart';

class FallbackException extends AppException {
  const FallbackException(super.message, {super.origin, super.cause});
}
