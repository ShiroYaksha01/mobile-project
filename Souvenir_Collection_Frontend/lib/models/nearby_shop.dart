// nearby_shop.dart — maps to GET /api/map/branches response
class NearbyShop {
  final String id;
  final String name;
  final String type;
  final String address;
  final double lat;
  final double lng;
  final double rating;
  final String distance;

  const NearbyShop({
    required this.id,
    required this.name,
    required this.type,
    this.address = '',
    this.lat = 0.0,
    this.lng = 0.0,
    this.rating = 0.0,
    this.distance = '',
  });

  factory NearbyShop.fromJson(Map<String, dynamic> json) {
    return NearbyShop(
      id: json['id']?.toString() ?? '',
      name: json['shopName']?.toString() ?? json['name']?.toString() ?? '',
      type: json['craftType']?.toString() ?? json['type']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      distance: json['distance']?.toString() ?? '',
    );
  }
}
