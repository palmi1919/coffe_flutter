import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/user.dart';

class AuthService {
  static Future<AppUser?> authenticate({
    required String identifier,
    required String password,
  }) async {
    final cleanId = identifier.trim();
    final cleanPass = password.trim();

    if (cleanId.isEmpty || cleanPass.isEmpty) {
      return null;
    }

    try {
      final client = SupabaseConfig.client;
      final res = await client
          .from('usuario')
          .select('''
            pk_usuario,
            nom_usuario,
            contrasena,
            fk_tipo_usu,
            estatus,
            persona (pk_persona, nom_persona, apaterno, amaterno),
            tipo_usu (pk_tipo_usu, nom_tipo)
          ''')
          .eq('nom_usuario', cleanId)
          .eq('contrasena', cleanPass)
          .eq('estatus', true)
          .maybeSingle();

      if (res == null) {
        return null;
      }

      Map<String, dynamic>? personaMap;
      if (res['persona'] is Map<String, dynamic>) {
        personaMap = res['persona'] as Map<String, dynamic>;
      } else if (res['persona'] is List && (res['persona'] as List).isNotEmpty) {
        personaMap = (res['persona'] as List).first as Map<String, dynamic>;
      }
      String fullName = res['nom_usuario'] as String? ?? '';
      if (personaMap != null) {
        final nom = personaMap['nom_persona'] as String? ?? '';
        final ap = personaMap['apaterno'] as String? ?? '';
        final am = personaMap['amaterno'] as String? ?? '';
        fullName = '$nom $ap $am'.trim();
        if (fullName.isEmpty) {
          fullName = res['nom_usuario'] as String? ?? 'Usuario';
        }
      }

      final int tipoUsu = (res['fk_tipo_usu'] as num?)?.toInt() ?? 2;
      final role = (tipoUsu == 1) ? UserRole.admin : UserRole.customer;

      return AppUser(
        id: (res['pk_usuario'] as num).toInt(),
        username: res['nom_usuario'] as String? ?? cleanId,
        name: fullName,
        role: role,
        personaId: personaMap?['pk_persona'] != null
            ? (personaMap!['pk_persona'] as num).toInt()
            : null,
      );
    } catch (e) {
      debugPrint('Error al autenticar: $e');
      rethrow;
    }
  }

  static Future<void> registerClient({
    required String nombre,
    required String apaterno,
    String? amaterno,
    required String username,
    required String password,
  }) async {
    try {
      final client = SupabaseConfig.client;
      await client.rpc('registrar_cliente', params: {
        'p_nom_persona': nombre.trim(),
        'p_apaterno': apaterno.trim(),
        'p_amaterno': (amaterno != null && amaterno.trim().isNotEmpty)
            ? amaterno.trim()
            : null,
        'p_nom_usuario': username.trim(),
        'p_contrasena': password.trim(),
      });
    } catch (e) {
      debugPrint('Error en registro de cliente: $e');
      rethrow;
    }
  }
}
