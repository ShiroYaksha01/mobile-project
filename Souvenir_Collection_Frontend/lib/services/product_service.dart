import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService(this._apiClient);

  // ─── Products ───────────────────────────────────────────────

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _apiClient.get('/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to load products');
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response = await _apiClient.get('/products/$id');
      if (response.statusCode == 200) {
        return Product.fromJson(response.data['data']);
      }
      throw Exception('Failed to load product');
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _apiClient.get('/products/category/$categoryId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to load products by category');
    } catch (e) {
      throw Exception('Failed to load products by category: $e');
    }
  }

  Future<List<Product>> getProductsByArtisan(String artisanId) async {
    try {
      final response = await _apiClient.get('/products/artisan/$artisanId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to load products by artisan');
    } catch (e) {
      throw Exception('Failed to load products by artisan: $e');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _apiClient.get(
        '/products/search',
        queryParameters: {'query': query},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to search products');
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // ─── Categories ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
