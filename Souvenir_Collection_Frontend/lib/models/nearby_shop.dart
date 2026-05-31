// nearby_shop.dart
class NearbyShop {
  final String name, type, distance;
  final double rating, mapX, mapY;
  const NearbyShop({
    required this.name, required this.type,
    required this.rating, required this.distance,
    required this.mapX, required this.mapY,
  });
}