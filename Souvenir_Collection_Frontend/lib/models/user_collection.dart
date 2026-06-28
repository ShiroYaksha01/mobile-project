import 'product.dart';

class CollectionItem {
  final Product product;
  int quantity;

  CollectionItem({
    required this.product,
    this.quantity = 1,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class UserCollection {
  final String id;
  final String name;
  final List<CollectionItem> items;

  UserCollection({
    required this.id,
    required this.name,
    List<CollectionItem>? items,
  }) : items = items ?? [];

  factory UserCollection.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List<dynamic>? ?? [];
    return UserCollection(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      items: itemsList.map((i) => CollectionItem.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }
}
