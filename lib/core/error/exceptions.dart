/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

/// Server-related exceptions (4xx, 5xx)
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Network-related exceptions (timeout, no connection)
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Authentication exceptions
class AuthenticationException extends AppException {
  const AuthenticationException(super.message);
}

/// Unknown exceptions
class UnknownException extends AppException {
  const UnknownException(super.message);
}

