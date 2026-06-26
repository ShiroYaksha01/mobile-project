import '../../models/product.dart';
import '../../models/artisan.dart';
import '../../models/nearby_shop.dart';

// static_data.dart
class StaticData {
  StaticData._();

  static final List<Product> products = [
    Product(id: 'p1', name: 'Songkran Gift Set',  subtitle: 'Festive Curation',
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
        price: 48, badge: 'New Season', category: 'Textile'),
    Product(id: 'p2', name: 'Royal Gold Silk',    subtitle: 'Heirloom Quality',
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&q=80',
        price: 120, badge: 'Limited', category: 'Textile'),
    Product(id: 'p3', name: 'Angkor Silver Ring', subtitle: 'Temple-Inspired',
        imageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400&q=80',
        price: 35, category: 'Silver', isFavorite: true),
    Product(id: 'p4', name: 'Khmer Ceramic Vase', subtitle: 'Hand-Thrown Clay',
        imageUrl: 'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=400&q=80',
        price: 65, badge: 'Artisan Pick', category: 'Ceramics'),
    Product(id: 'p5', name: 'Teak Wood Box',      subtitle: 'Relief Carved',
        imageUrl: 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400&q=80',
        price: 54, category: 'Wood', isFavorite: true),
    Product(id: 'p6', name: 'Krama Scarf',        subtitle: 'Traditional Cotton',
        imageUrl: 'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=400&q=80',
        price: 22, badge: 'Bestseller', category: 'Textile'),
    Product(id: 'p7', name: 'Bamboo Weave Tray',  subtitle: 'Eco Handcraft',
        imageUrl: 'https://images.unsplash.com/photo-1524678606370-a47ad25cb82a?w=400&q=80',
        price: 18, category: 'Wood'),
    Product(id: 'p8', name: 'Apsara Pendant',     subtitle: 'Sterling Silver',
        imageUrl: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=400&q=80',
        price: 42, badge: 'New', category: 'Jewelry'),
  ];

  static const List<Artisan> artisans = [
    Artisan(name: 'Serey Vanna',  craft: 'Wood Carving',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80'),
    Artisan(name: 'Channary K.',  craft: 'Silk Weaving',
        imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80'),
    Artisan(name: 'Dara Meas',    craft: 'Silver Work',
        imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80'),
    Artisan(name: 'Sreymom L.',   craft: 'Ceramics',
        imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80'),
  ];

  static const List<String> categories = [
    'All', 'Textile', 'Silver', 'Wood', 'Jewelry', 'Ceramics', 'Home Decor', 'Edible',
  ];

  static const List<NearbyShop> nearbyShops = [
    NearbyShop(name: 'Silk Studio',   type: 'Textile',      rating: 4.9, distance: '0.3 km', mapX: 0.35, mapY: 0.40),
    NearbyShop(name: 'Ceramics Co.',  type: 'Pottery',      rating: 4.7, distance: '0.6 km', mapX: 0.60, mapY: 0.60),
    NearbyShop(name: 'Jewelry Arts',  type: 'Silver & Gold', rating: 4.8, distance: '1.1 km', mapX: 0.75, mapY: 0.25),
    NearbyShop(name: 'Wood Carvers',  type: 'Woodwork',     rating: 4.6, distance: '1.4 km', mapX: 0.45, mapY: 0.82),
    NearbyShop(name: 'Kbach Gallery', type: 'Mixed Craft',  rating: 4.9, distance: '0.8 km', mapX: 0.15, mapY: 0.75),
  ];
}