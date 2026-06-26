class User {
  final String id; // Mocked for now since backend doesn't return ID in LoginResponse
  final String email;
  final String name;
  final String role; // e.g., 'Customer', 'Admin', 'Artisan'

  User({
    this.id = '',
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
      role: json['role']?.toString() ?? 'Customer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
