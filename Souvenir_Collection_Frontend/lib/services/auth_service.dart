import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_client.dart';
import '../core/utils/secure_storage.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final responseData = response.data['data'];
      final token = responseData['accessToken'];

      // Save token securely
      await SecureStorage.saveTokens(token);

      return User.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to login');
    } catch (e) {
      throw Exception('An unexpected error occurred during login.');
    }
  }

  Future<User> register(String firstName, String lastName, String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'name': '$firstName $lastName'.trim(),
          'email': email,
          'password': password,
          'confirmPassword': password, // Backend expects ConfirmPassword
          'role': 'Customer'
        },
      );

      final responseData = response.data['data'];
      final token = responseData['accessToken'];

      // Save token securely
      await SecureStorage.saveTokens(token);

      return User.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to register');
    } catch (e) {
      throw Exception('An unexpected error occurred during registration.');
    }
  }

  Future<void> logout() async {
    // Clear tokens
    await SecureStorage.clearTokens();
  }

  Future<User?> getCurrentUser() async {
    final token = await SecureStorage.getToken();
    if (token == null) return null;

    try {
      final response = await _apiClient.get('/auth/me');
      final responseData = response.data['data'];
      return User.fromJson(responseData);
    } catch (e) {
      // If fetching user fails (e.g. token expired), we should probably clear it
      await SecureStorage.clearTokens();
      return null;
    }
  }
}
