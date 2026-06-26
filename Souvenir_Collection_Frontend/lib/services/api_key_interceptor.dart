import 'package:dio/dio.dart';

class ApiKeyInterceptor extends Interceptor {
  static const String _apiKey = 'mobile-key123';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-API-KEY'] = _apiKey;
    handler.next(options);
  }
}
