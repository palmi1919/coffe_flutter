enum UserRole {
  admin,
  customer;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.customer:
        return 'Cliente';
    }
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isCustomer => role == UserRole.customer;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? 'usr_1',
      name: json['name'] as String? ?? 'Usuario',
      email: json['email'] as String? ?? '',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.customer,
    );
  }
}
