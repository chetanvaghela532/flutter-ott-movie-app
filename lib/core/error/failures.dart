import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server failure (4xx, 5xx)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Network failure (timeout, no connection)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Authentication failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

