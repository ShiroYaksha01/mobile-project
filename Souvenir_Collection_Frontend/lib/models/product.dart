// product.dart
class Product {
  final String id, name, subtitle, imageUrl, badge, category, description;
  final String artisanId, categoryId;
  final double price;
  bool isFavorite;
  int cartQty;
  int stockQty;
  bool isAvailable;

  Product({
    required this.id, 
    required this.name, 
    this.subtitle = '', 
    required this.imageUrl, 
    required this.price,
    this.badge = '', 
    this.category = '',
    this.description = '',
    this.artisanId = '',
    this.categoryId = '',
    this.stockQty = 0,
    this.isAvailable = true,
    this.isFavorite = false, 
    this.cartQty = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Product',
      description: json['description']?.toString() ?? '',
      subtitle: json['description']?.toString() ?? '', // fallback subtitle
      imageUrl: json['image']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      badge: '', // computed in UI later if needed
      category: json['categoryName']?.toString() ?? '', // We'll need backend to send categoryName or resolve it
      artisanId: json['artisanId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      stockQty: json['stockQty'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      isFavorite: false,
      cartQty: 0,
    );
  }
}