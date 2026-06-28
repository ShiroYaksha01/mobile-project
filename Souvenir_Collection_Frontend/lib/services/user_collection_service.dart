import '../models/user_collection.dart';
import 'api_client.dart';

class UserCollectionService {
  final ApiClient _apiClient;

  UserCollectionService(this._apiClient);

  Future<List<UserCollection>> getUserCollections(String userId) async {
    try {
      final response = await _apiClient.get('/usercollections/user/$userId');
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>?;
        if (list == null) return [];
        return list.map((e) => UserCollection.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load user collections: $e');
    }
  }

  Future<UserCollection> createCollection(String userId, String name) async {
    try {
      final response = await _apiClient.post('/usercollections/user/$userId?name=$name');
      if (response.statusCode == 200) {
        return UserCollection.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to create collection');
    } catch (e) {
      throw Exception('Failed to create collection: $e');
    }
  }

  Future<bool> deleteCollection(String userId, String collectionId) async {
    try {
      final response = await _apiClient.delete('/usercollections/user/$userId/collection/$collectionId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addOrUpdateItem(String userId, String collectionId, String productId, int quantity) async {
    try {
      final response = await _apiClient.post('/usercollections/user/$userId/collection/$collectionId/product/$productId?quantity=$quantity');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeItem(String userId, String collectionId, String productId) async {
    try {
      final response = await _apiClient.delete('/usercollections/user/$userId/collection/$collectionId/product/$productId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
