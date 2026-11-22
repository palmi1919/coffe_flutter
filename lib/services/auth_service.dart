import '../models/user.dart';

class AuthService {
  static const String adminEmail = 'admin@cafe.com';
  static const String adminUser = 'admin';
  static const String adminPass = 'admin123';

  static const String customerEmail = 'cliente@cafe.com';
  static const String customerUser = 'cliente';
  static const String customerPass = 'cliente123';

  static AppUser? authenticate({
    required String identifier,
    required String password,
  }) {
    final cleanId = identifier.trim().toLowerCase();
    final cleanPass = password.trim();

    // Credenciales de Administrador
    if ((cleanId == adminEmail || cleanId == adminUser) &&
        (cleanPass == adminPass || cleanPass == 'admin')) {
      return const AppUser(
        id: 'usr_admin',
        name: 'Administrador General',
        email: 'admin@cafe.com',
        role: UserRole.admin,
      );
    }

    // Credenciales de Cliente predeterminado
    if ((cleanId == customerEmail || cleanId == customerUser) &&
        (cleanPass == customerPass || cleanPass == 'cliente')) {
      return const AppUser(
        id: 'usr_client',
        name: 'Carlos Mendoza',
        email: 'cliente@cafe.com',
        role: UserRole.customer,
      );
    }

    // Si escribe una cuenta con "admin" en el nombre, entra como admin
    if (cleanId.contains('admin') && cleanPass.isNotEmpty) {
      return AppUser(
        id: 'usr_admin_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Admin ($cleanId)',
        email: cleanId.contains('@') ? cleanId : '$cleanId@cafe.com',
        role: UserRole.admin,
      );
    }

    // Cualquier otro usuario que ingrese con contraseña válida se registra como cliente
    if (cleanId.isNotEmpty && cleanPass.isNotEmpty) {
      final nameFormatted = cleanId.contains('@')
          ? cleanId.split('@').first
          : cleanId;
      return AppUser(
        id: 'usr_client_${DateTime.now().millisecondsSinceEpoch}',
        name: nameFormatted[0].toUpperCase() + nameFormatted.substring(1),
        email: cleanId.contains('@') ? cleanId : '$cleanId@gmail.com',
        role: UserRole.customer,
      );
    }

    return null;
  }

  static AppUser get quickAdminUser => const AppUser(
        id: 'usr_admin_quick',
        name: 'Administrador General',
        email: 'admin@cafe.com',
        role: UserRole.admin,
      );

  static AppUser get quickCustomerUser => const AppUser(
        id: 'usr_client_quick',
        name: 'Carlos Mendoza',
        email: 'carlos.mendoza@email.com',
        role: UserRole.customer,
      );
}
