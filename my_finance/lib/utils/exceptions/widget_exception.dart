import 'app_exception.dart';

class WidgetException extends AppException {
  const WidgetException(super.message, {super.origin, super.cause});
}
