class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final String? address;
  final String? avatar;
  final DateTime? createdAt;

  User({
    this.id = '',
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.address,
    this.avatar,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
      role: json['role']?.toString() ?? 'Customer',
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'address': address,
      'avatar': avatar,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
