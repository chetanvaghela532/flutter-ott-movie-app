import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import 'api_interceptor.dart';
import 'api_logger.dart';

class DioClient {
  final Dio _dio;
  final String baseUrl;

  DioClient({
    required this.baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: Duration(milliseconds: connectTimeout ?? 30000),
            receiveTimeout: Duration(milliseconds: receiveTimeout ?? 30000),
            sendTimeout: Duration(milliseconds: sendTimeout ?? 30000),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      ApiLogger(),
      ApiInterceptor(),
    ]);
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 
                       error.response?.data?['error'] ?? 
                       'Server error occurred';
        
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            if (statusCode == 401) {
              return AuthenticationException('Unauthorized. Please login again.');
            }
            return ServerException('Client error: $message');
          } else if (statusCode >= 500) {
            return ServerException('Server error: $message');
          }
        }
        return ServerException(message);
      
      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled');
      
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('Failed host lookup') == true) {
          return NetworkException('No internet connection. Please check your network.');
        }
        return NetworkException(error.message ?? 'Unknown network error');
      
      default:
        return NetworkException('Network error occurred');
    }
  }

  Dio get dio => _dio;
}

