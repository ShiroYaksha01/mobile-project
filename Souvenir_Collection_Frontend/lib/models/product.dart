// product.dart
class Product {
  final String id, name, subtitle, imageUrl, badge, category;
  final double price;
  bool isFavorite;
  int cartQty;

  Product({
    required this.id, required this.name, required this.subtitle,
    required this.imageUrl, required this.price,
    this.badge = '', required this.category,
    this.isFavorite = false, this.cartQty = 0,
  });
}