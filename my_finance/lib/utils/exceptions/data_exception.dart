import 'app_exception.dart';

class DataException extends AppException {
  const DataException(super.message, {super.origin, super.cause});
}
