// lib/core/errors/failures.dart

abstract class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, {this.cause});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode, super.cause});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.cause});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.cause});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause});
}

class UnsupportedFailure extends Failure {
  const UnsupportedFailure(super.message, {super.cause});
}
