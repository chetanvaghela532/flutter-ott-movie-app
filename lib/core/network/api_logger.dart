import 'package:dio/dio.dart';

/// Logger interceptor for debugging API calls
class ApiLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────');
    print('│ REQUEST: ${options.method} ${options.path}');
    print('│ Headers: ${options.headers}');
    if (options.queryParameters.isNotEmpty) {
      print('│ Query Parameters: ${options.queryParameters}');
    }
    if (options.data != null) {
      print('│ Body: ${options.data}');
    }
    print('└─────────────────────────────────────────────────────────');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────');
    print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    print('│ Data: ${response.data}');
    print('└─────────────────────────────────────────────────────────');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────');
    print('│ ERROR: ${err.type}');
    print('│ Path: ${err.requestOptions.path}');
    print('│ Message: ${err.message}');
    if (err.response != null) {
      print('│ Status Code: ${err.response?.statusCode}');
      print('│ Response Data: ${err.response?.data}');
    }
    print('└─────────────────────────────────────────────────────────');
    super.onError(err, handler);
  }
}

