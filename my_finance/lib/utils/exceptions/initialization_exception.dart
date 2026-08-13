import 'app_exception.dart';

class InitializationException extends AppException {
  const InitializationException(super.message, {super.origin, super.cause});
}
