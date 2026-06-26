import 'package:dio/dio.dart';
import '../core/utils/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Attempt to attach the authorization token to every request
    final token = await SecureStorage.getToken();
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If we get a 401 Unauthorized, we could attempt to refresh the token here.
    // For now, we will simply pass the error down.
    if (err.response?.statusCode == 401) {
      // TODO: Handle token refresh logic
      // e.g. call a refresh token endpoint and retry the request
    }
    
    super.onError(err, handler);
  }
}
