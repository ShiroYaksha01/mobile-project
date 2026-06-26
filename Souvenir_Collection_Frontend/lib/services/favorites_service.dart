import '../models/product.dart';
import 'api_client.dart';

class FavoritesService {
  final ApiClient _apiClient;

  FavoritesService(this._apiClient);

  /// Get all favorited products for a user
  Future<List<Product>> getFavoriteProducts(String userId) async {
    try {
      final response = await _apiClient.get('/favorites/user/$userId/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) {
          // Favorite response nests Product inside
          final productJson = json['product'] as Map<String, dynamic>? ?? json;
          final product = Product.fromJson(productJson);
          product.isFavorite = true;
          return product;
        }).toList();
      }
      throw Exception('Failed to load favorites');
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  /// Toggle a product favorite (adds if not favorited, removes if already)
  /// Returns true if now favorited, false if removed
  Future<bool> toggleFavorite(String userId, String productId) async {
    try {
      final response = await _apiClient.patch(
        '/favorites/user/$userId/product/$productId/toggle',
      );
      if (response.statusCode == 200) {
        final result = response.data['data'];
        return result['isFavorited'] as bool? ?? false;
      }
      throw Exception('Failed to toggle favorite');
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
      if (response.statusCode == 200) {
        final result = response.data['data'];
        return result['favorited'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
