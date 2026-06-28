class Promotion {
  final String id;
  final String title;
  final String code;
  final String description;
  final String image;
  final String discountType; // 'Percentage' | 'FixedAmount'
  final double discount;
  final int usageLimit;
  final int usageCount;
  final String status; // 'Active' | 'Inactive' | 'Expired' | 'Scheduled'
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  const Promotion({
    required this.id,
    required this.title,
    required this.code,
    this.description = '',
    this.image = '',
    this.discountType = 'Percentage',
    this.discount = 0,
    this.usageLimit = 0,
    this.usageCount = 0,
    this.status = 'Active',
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      discountType: json['discountType'] as String? ?? 'Percentage',
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      usageLimit: json['usageLimit'] as int? ?? 0,
      usageCount: json['usageCount'] as int? ?? 0,
      status: json['status'] as String? ?? 'Active',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'code': code,
        'description': description,
        'image': image,
        'discountType': discountType,
        'discount': discount,
        'usageLimit': usageLimit,
        'usageCount': usageCount,
        'status': status,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
      };

  bool get isActive => status == 'Active';

  String get discountLabel {
    if (discountType == 'Percentage') {
      return '${discount.toStringAsFixed(0)}% OFF';
    }
    return '\$${discount.toStringAsFixed(2)} OFF';
  }
}
