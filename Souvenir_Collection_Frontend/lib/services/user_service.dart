import '../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  /// GET /api/user/{id}
  Future<User> getProfile(String userId) async {
    try {
      final response = await _apiClient.get('/user/$userId');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return User.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Failed to load profile');
    } catch (e) {
      rethrow;
    }
  }

  /// PUT /api/user/{id} — body: { name, phone, address, avatar }
  Future<User> updateProfile(String userId, {
    required String name,
    String? phone,
    String? address,
    String? avatar,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name,
      };
      if (phone != null) body['phone'] = phone;
      if (address != null) body['address'] = address;
      if (avatar != null) body['avatar'] = avatar;

      final response = await _apiClient.put('/user/$userId', data: body);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return User.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Failed to update profile');
    } catch (e) {
      rethrow;
    }
  }

  /// PUT /api/user/{id}/password — body: raw password string
  Future<bool> updatePassword(String userId, String newPassword) async {
    try {
      final response = await _apiClient.put(
        '/user/$userId/password',
        data: '"$newPassword"',
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT /api/user/{id}/avatar — body: raw avatar URL string
  Future<String> updateAvatar(String userId, String avatarUrl) async {
    try {
      final response = await _apiClient.put(
        '/user/$userId/avatar',
        data: '"$avatarUrl"',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data['avatar'] as String? ?? '';
      }
      throw Exception('Failed to update avatar');
    } catch (e) {
      rethrow;
    }
  }
}
