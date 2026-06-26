class Review {
  final String id;
  final String userId;
  final String? productId;
  final String? reviewText;
  final int rating;
  final String image;
  final DateTime? createdAt;

  const Review({
    required this.id,
    required this.userId,
    this.productId,
    this.reviewText,
    this.rating = 0,
    this.image = '',
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      productId: json['productId'] as String?,
      reviewText: json['reviewText'] as String?,
      rating: json['rating'] as int? ?? 0,
      image: json['image'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'productId': productId,
        'reviewText': reviewText,
        'rating': rating,
        'image': image,
        'createdAt': createdAt?.toIso8601String(),
      };
}
