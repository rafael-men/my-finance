import 'fallback_exception.dart';

abstract class AppException implements Exception {
  const AppException(this.message, {this.origin, this.cause});

  final String message;
  final String? origin;
  final Object? cause;

  factory AppException.fallback(
    String message, {
    String? origin,
    Object? cause,
  }) =>
      FallbackException(message, origin: origin, cause: cause);

  factory AppException.from(Object error, {String? origin}) {
    if (error is AppException) {
      return error;
    }
    return AppException.fallback(
      error is Exception ? error.toString() : 'Erro inesperado.',
      origin: origin,
      cause: error,
    );
  }

  @override
  String toString() {
    final source = origin;
    if (source != null && source.isNotEmpty) {
      return '$message (origem: $source)';
    }
    return message;
  }
}
