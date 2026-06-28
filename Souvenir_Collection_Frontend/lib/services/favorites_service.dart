import '../models/product.dart';
import 'api_client.dart';

class FavoritesService {
  final ApiClient _apiClient;

  FavoritesService(this._apiClient);

  /// Get all favorited products for a user from the backend
  Future<List<Product>> getFavoriteProducts(String userId) async {
    try {
      final response = await _apiClient.get('/favorites/user/$userId/products');
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>?;
        if (list == null) return [];
        return list.map((e) {
          // Favorite has nested product
          final productJson = e['product'] as Map<String, dynamic>?;
          if (productJson != null) {
            return Product.fromJson(productJson);
          }
          return Product.fromJson(e as Map<String, dynamic>);
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  /// Toggle a product favorite via the backend API
  Future<bool> toggleFavorite(String userId, String productId) async {
    try {
      final response = await _apiClient.patch(
        '/favorites/user/$userId/product/$productId/toggle',
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']?['isFavorited'] ?? false;
      }
      throw Exception('Toggle failed');
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Check if a product is favorited
  Future<bool> isFavorited(String userId, String productId) async {
    try {
      final response = await _apiClient.get(
        '/favorites/user/$userId/product/$productId/check',
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']?['favorited'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
