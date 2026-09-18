// lib/core/errors/exceptions.dart

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}