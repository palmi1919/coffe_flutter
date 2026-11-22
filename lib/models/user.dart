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
  final int id;
  final String username;
  final String name;
  final UserRole role;
  final int? personaId;

  const AppUser({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.personaId,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isCustomer => role == UserRole.customer;

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'role': role.name,
        'personaId': personaId,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int? ?? (json['pk_usuario'] as int? ?? 0),
      username: json['username'] as String? ?? (json['nom_usuario'] as String? ?? ''),
      name: json['name'] as String? ?? '',
      role: json['role'] == 'admin' || json['fk_tipo_usu'] == 1
          ? UserRole.admin
          : UserRole.customer,
      personaId: json['personaId'] as int? ?? json['fk_persona'] as int?,
    );
  }
}
