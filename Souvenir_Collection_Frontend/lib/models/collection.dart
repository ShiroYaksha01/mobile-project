class Collection {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String type;
  final String image;
  final DateTime? createdAt;

  const Collection({
    required this.id,
    required this.title,
    this.slug = '',
    this.description = '',
    this.type = '',
    this.image = '',
    this.createdAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? '',
      image: json['image'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slug': slug,
        'description': description,
        'type': type,
        'image': image,
        'createdAt': createdAt?.toIso8601String(),
      };
}
