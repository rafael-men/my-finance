import 'app_exception.dart';

class ValidationException extends AppException {
  const ValidationException(super.message, {super.origin, super.cause});
}
