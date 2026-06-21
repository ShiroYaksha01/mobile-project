import '../data/static_data.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService(this._apiClient);

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

  static List<Product> get favorites =>
      StaticData.products.where((p) => p.isFavorite).toList();

  static List<Product> get cartItems =>
      StaticData.products.where((p) => p.cartQty > 0).toList();

  static int get cartCount => cartItems.length;

  static void toggleFavorite(String id) {
    final product = StaticData.products.firstWhere(
          (p) => p.id == id,
    );

    product.isFavorite = !product.isFavorite;
  }
}