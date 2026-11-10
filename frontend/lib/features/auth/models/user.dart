class User {
  final String id;
  final String? username;
  final String email;
  final String? phone;
  final String role;

  User({
    required this.id,
    this.username,
    required this.email,
    this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: (json['id'] ?? json['userId'] ?? '').toString(),
    username: json['username'] as String?,
    email: (json['email'] ?? '').toString(),
    phone: json['phone'] as String?,
    role: (json['role'] ?? 'USER').toString(),
  );
}
