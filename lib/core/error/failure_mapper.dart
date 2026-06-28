import '../error/exceptions.dart';
import '../error/failures.dart';

/// Maps exceptions to failures
class FailureMapper {
  static Failure mapExceptionToFailure(AppException exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is AuthenticationException) {
      return AuthenticationFailure(exception.message);
    } else {
      return UnknownFailure(exception.message);
    }
  }

  static Failure mapErrorToFailure(Object error) {
    if (error is AppException) {
      return mapExceptionToFailure(error);
    }
    return UnknownFailure(error.toString());
  }
}

