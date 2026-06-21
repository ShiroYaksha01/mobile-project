// artisan.dart
class Artisan {
  final String id;
  final String name; // maps to DisplayName
  final String region;
  final String craft; // maps to CraftType
  final String bio;
  final String imageUrl; // maps to ProfilePhotoUrl
  final String shopAddress;
  final double lat;
  final double lng;
  final bool isVerified;

  const Artisan({
    this.id = '',
    required this.name,
    this.region = '',
    required this.craft,
    this.bio = '',
    required this.imageUrl,
    this.shopAddress = '',
    this.lat = 0.0,
    this.lng = 0.0,
    this.isVerified = false,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      id: json['id']?.toString() ?? '',
      name: json['displayName']?.toString() ?? 'Unknown Artisan',
      region: json['region']?.toString() ?? '',
      craft: json['craftType']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      imageUrl: json['profilePhotoUrl']?.toString() ?? '',
      shopAddress: json['shopAddress']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}