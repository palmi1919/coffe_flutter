import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'seed_data.dart';

class LocalStorageService {
  static const String _productsKey = 'cafe_aroma_products_v1';
  static const String _ordersKey = 'cafe_aroma_orders_v1';
  static const String _userKey = 'cafe_aroma_current_user_v1';
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
      // Agregar órdenes iniciales de demostración para el panel de administración
      await _seedDemoOrders();
      await _prefs.setBool(_initializedKey, true);
    }
  }

  Future<void> _seedDemoOrders() async {
    final now = DateTime.now();
    final demoOrders = [
      CoffeeOrder(
        id: 'CA-1024',
        customerName: 'Carlos Mendoza',
        customerEmail: 'carlos@ejemplo.com',
        date: now.subtract(const Duration(minutes: 18)),
        items: const [
          OrderProductSummary(
            productId: 'prod_1',
            productName: 'Café Espresso Doble',
            sizeName: 'Mediano (12 oz)',
            quantity: 2,
            unitPrice: 57.0,
          ),
          OrderProductSummary(
            productId: 'prod_2',
            productName: 'Cappuccino Italiano',
            sizeName: 'Grande (16 oz)',
            quantity: 1,
            unitPrice: 77.0,
          ),
        ],
        total: 191.0,
        status: OrderStatus.enPreparacion,
      ),
      CoffeeOrder(
        id: 'CA-1023',
        customerName: 'Valeria Sánchez',
        customerEmail: 'valeria@ejemplo.com',
        date: now.subtract(const Duration(hours: 1, minutes: 40)),
        items: const [
          OrderProductSummary(
            productId: 'prod_3',
            productName: 'Caramel Macchiato',
            sizeName: 'Mediano (12 oz)',
            quantity: 1,
            unitPrice: 80.0,
          ),
        ],
        total: 80.0,
        status: OrderStatus.listo,
      ),
      CoffeeOrder(
        id: 'CA-1022',
        customerName: 'Andrés López',
        customerEmail: 'andres@ejemplo.com',
        date: now.subtract(const Duration(hours: 3)),
        items: const [
          OrderProductSummary(
            productId: 'prod_4',
            productName: 'Mocha Artesanal',
            sizeName: 'Chico (8 oz)',
            quantity: 3,
            unitPrice: 62.0,
          ),
        ],
        total: 186.0,
        status: OrderStatus.entregado,
      ),
    ];
    await saveOrders(demoOrders);
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

  List<CoffeeOrder> loadOrders() {
    final rawJson = _prefs.getString(_ordersKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => CoffeeOrder.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveOrders(List<CoffeeOrder> orders) async {
    final jsonList = orders.map((o) => o.toJson()).toList();
    final encoded = jsonEncode(jsonList);
    await _prefs.setString(_ordersKey, encoded);
  }

  AppUser? loadUser() {
    final rawJson = _prefs.getString(_userKey);
    if (rawJson == null || rawJson.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      return AppUser.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(AppUser? user) async {
    if (user == null) {
      await _prefs.remove(_userKey);
    } else {
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    }
  }

  Future<void> resetToSeedData() async {
    final initialProducts = SeedData.getInitialProducts();
    await saveProducts(initialProducts);
    await _seedDemoOrders();
  }
}
