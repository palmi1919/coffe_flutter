import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userKey = 'cafe_aroma_user_session_v2';
  static const String _legacyUserKey = 'cafe_aroma_user';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    // Limpiar siempre cualquier sesión almacenada previamente al iniciar
    await prefs.remove(_userKey);
    await prefs.remove(_legacyUserKey);
    return LocalStorageService(prefs);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_legacyUserKey);
  }
}
