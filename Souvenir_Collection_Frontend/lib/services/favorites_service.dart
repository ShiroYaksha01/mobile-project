import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'api_client.dart';

class FavoritesService {
  final ApiClient _apiClient;

  FavoritesService(this._apiClient);

  /// Get all favorited products for a user from shared_preferences
  Future<List<Product>> getFavoriteProducts(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favIds = prefs.getStringList('favorites_$userId') ?? [];
      
      if (favIds.isEmpty) return [];

      // Fetch all products from API and filter based on local saved IDs
      final response = await _apiClient.get('/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final allProducts = data.map((json) => Product.fromJson(json)).toList();
        
        return allProducts.where((p) {
          if (favIds.contains(p.id)) {
            p.isFavorite = true;
            return true;
          }
          return false;
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load local favorites: $e');
    }
  }

  /// Toggle a product favorite in shared_preferences
  Future<bool> toggleFavorite(String userId, String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'favorites_$userId';
      final favIds = prefs.getStringList(key) ?? [];

      bool isNowFavorited;
      if (favIds.contains(productId)) {
        favIds.remove(productId);
        isNowFavorited = false;
      } else {
        favIds.add(productId);
        isNowFavorited = true;
      }
      
      await prefs.setStringList(key, favIds);
      return isNowFavorited;
    } catch (e) {
      throw Exception('Failed to toggle local favorite: $e');
    }
  }

  /// Check if a product is favorited in shared_preferences
  Future<bool> isFavorited(String userId, String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favIds = prefs.getStringList('favorites_$userId') ?? [];
      return favIds.contains(productId);
    } catch (e) {
      return false;
    }
  }
}
