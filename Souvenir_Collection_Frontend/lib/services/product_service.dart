import '../data/static_data.dart';
import '../models/product.dart';

class ProductService {
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