class UserModel {
  final int id;
  final String username;
  final String name;
  final String role;
  final String email;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      role: json['role'] ?? json['role_name'] ?? 'proktor',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role,
      'email': email,
    };
  }
}
