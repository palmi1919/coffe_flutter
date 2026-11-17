import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'seed_data.dart';

class LocalStorageService {
  static const String _productsKey = 'cafe_aroma_products_v1';
  static const String _initializedKey = 'cafe_aroma_initialized_v1';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalStorageService(prefs);
    await service._ensureInitialized();
    return service;
  }

  Future<void> _ensureInitialized() async {
    final isInitialized = _prefs.getBool(_initializedKey) ?? false;
    final existingData = _prefs.getString(_productsKey);

    if (!isInitialized || existingData == null || existingData.isEmpty) {
      final initialProducts = SeedData.getInitialProducts();
      await saveProducts(initialProducts);
      await _prefs.setBool(_initializedKey, true);
    }
  }

  List<Product> loadProducts() {
    final rawJson = _prefs.getString(_productsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return SeedData.getInitialProducts();
    }
    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return SeedData.getInitialProducts();
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    final jsonList = products.map((p) => p.toJson()).toList();
    final encoded = jsonEncode(jsonList);
    await _prefs.setString(_productsKey, encoded);
  }

  Future<void> resetToSeedData() async {
    final initialProducts = SeedData.getInitialProducts();
    await saveProducts(initialProducts);
  }
}
