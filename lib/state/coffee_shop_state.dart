import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/product_size.dart';
import '../models/cart_item.dart';
import '../models/user.dart';
import '../services/local_storage_service.dart';

class CoffeeShopState extends ChangeNotifier {
  final LocalStorageService _storageService;

  List<Product> _products = [];
  List<CoffeeOrder> _orders = [];
  final List<CartItem> _cartItems = [];

  AppUser? _currentUser;
  ProductCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = true;

  CoffeeShopState(this._storageService) {
    _loadInitialData();
  }

  bool get isLoading => _isLoading;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  ProductCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get allProducts => List.unmodifiable(_products);
  List<CoffeeOrder> get allOrders => List.unmodifiable(_orders);

  /// Catálogo visible para el cliente (únicamente productos con estatus activo)
  List<Product> get customerMenuProducts {
    return _products.where((p) {
      if (!p.estaActivo) return false;
      if (_selectedCategory != null && p.categoria != _selectedCategory) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        final matchName = p.nombre.toLowerCase().contains(query);
        final matchDesc = p.descripcion.toLowerCase().contains(query);
        if (!matchName && !matchDesc) return false;
      }
      return true;
    }).toList();
  }

  /// Lista de productos para la pantalla de edición del administrador
  List<Product> get adminProducts {
    if (_searchQuery.trim().isEmpty) {
      return List.unmodifiable(_products);
    }
    final query = _searchQuery.toLowerCase().trim();
    return _products.where((p) {
      return p.nombre.toLowerCase().contains(query) ||
          p.categoria.nombre.toLowerCase().contains(query);
    }).toList();
  }

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get totalCartItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get cartSubtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Total de la compra en pesos mexicanos (IVA incluido)
  double get cartTotal => cartSubtotal;

  // ==========================================
  // ESTADÍSTICAS Y MÉTRICAS PARA ADMIN
  // ==========================================
  double get totalRevenue => _orders
      .where((o) => o.status != OrderStatus.cancelado)
      .fold(0.0, (sum, o) => sum + o.total);

  int get totalOrdersCount => _orders.length;

  int get pendingOrdersCount => _orders
      .where((o) =>
          o.status == OrderStatus.pendiente ||
          o.status == OrderStatus.enPreparacion)
      .length;

  int get activeProductsCount => _products.where((p) => p.estaActivo).length;

  int get lowStockProductsCount =>
      _products.where((p) => p.existencias > 0 && p.existencias <= 5).length;

  int get outOfStockProductsCount =>
      _products.where((p) => p.existencias == 0).length;

  void _loadInitialData() {
    _products = _storageService.loadProducts();
    _orders = _storageService.loadOrders();
    _currentUser = _storageService.loadUser();
    _isLoading = false;
    notifyListeners();
  }

  // ==========================================
  // AUTENTICACIÓN Y SESIÓN
  // ==========================================
  Future<void> login(AppUser user) async {
    _currentUser = user;
    await _storageService.saveUser(user);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _cartItems.clear();
    await _storageService.saveUser(null);
    notifyListeners();
  }

  void setSelectedCategory(ProductCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Product? findProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // OPERACIONES DEL CARRITO
  // ==========================================

  /// Cantidad actual de un producto (cualquier tamaño) en el carrito
  int getQuantityInCart(String productId) {
    return _cartItems
        .where((item) => item.product.id == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  /// Existencias restantes disponibles tomando en cuenta lo que ya está en el carrito
  int getAvailableStockForProduct(String productId) {
    final product = findProductById(productId);
    if (product == null) return 0;
    final inCart = getQuantityInCart(productId);
    final remaining = product.existencias - inCart;
    return remaining > 0 ? remaining : 0;
  }

  /// Agrega un producto con un tamaño específico al carrito
  bool addToCart(Product product, ProductSize size, int quantityToAdd) {
    final liveProduct = findProductById(product.id) ?? product;

    if (!liveProduct.estaDisponible) return false;

    final inCart = getQuantityInCart(liveProduct.id);
    if (inCart + quantityToAdd > liveProduct.existencias) {
      return false;
    }

    final existingIndex = _cartItems.indexWhere(
      (item) =>
          item.product.id == liveProduct.id && item.selectedSize.id == size.id,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantityToAdd;
    } else {
      _cartItems.add(
        CartItem(
          product: liveProduct,
          selectedSize: size,
          quantity: quantityToAdd,
        ),
      );
    }

    notifyListeners();
    return true;
  }

  /// Incrementa en 1 la cantidad de un artículo en el carrito
  bool incrementCartItem(String cartItemId) {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return false;

    final item = _cartItems[index];
    final liveProduct = findProductById(item.product.id) ?? item.product;
    final totalInCart = getQuantityInCart(liveProduct.id);

    if (totalInCart + 1 > liveProduct.existencias) {
      return false;
    }

    item.quantity += 1;
    notifyListeners();
    return true;
  }

  /// Disminuye en 1 la cantidad; si llega a 0 se elimina
  void decrementCartItem(String cartItemId) {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return;

    if (_cartItems[index].quantity > 1) {
      _cartItems[index].quantity -= 1;
    } else {
      _cartItems.removeAt(index);
    }
    notifyListeners();
  }

  /// Elimina un artículo del carrito
  void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  /// Vacía por completo el carrito
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// Confirma el pedido: descuenta existencias en la base de datos,
  /// registra la orden en el historial del sistema y vacía el carrito.
  Future<CoffeeOrder?> placeOrder() async {
    if (_cartItems.isEmpty) return null;

    // Verificar existencias
    for (final item in _cartItems) {
      final product = findProductById(item.product.id);
      if (product == null || product.existencias < item.quantity) {
        return null;
      }
    }

    // Descontar existencias de los productos
    for (final item in _cartItems) {
      final productIndex =
          _products.indexWhere((p) => p.id == item.product.id);
      if (productIndex >= 0) {
        final current = _products[productIndex];
        final newStock = current.existencias - item.quantity;
        _products[productIndex] = current.copyWith(
          existencias: newStock < 0 ? 0 : newStock,
        );
      }
    }

    final orderId = 'CA-${1000 + Random().nextInt(9000)}';
    final orderSummaries =
        _cartItems.map((ci) => OrderProductSummary.fromCartItem(ci)).toList();
    final totalPaid = cartTotal;

    final order = CoffeeOrder(
      id: orderId,
      customerName: _currentUser?.name ?? 'Cliente Mostrador',
      customerEmail: _currentUser?.email ?? 'cliente@cafe.com',
      date: DateTime.now(),
      items: orderSummaries,
      total: totalPaid,
      status: OrderStatus.pendiente,
    );

    _orders.insert(0, order);

    // Guardar productos y órdenes actualizadas
    await _storageService.saveProducts(_products);
    await _storageService.saveOrders(_orders);

    // Vaciar carrito
    _cartItems.clear();
    notifyListeners();
    return order;
  }

  // ==========================================
  // OPERACIONES DEL ADMINISTRADOR
  // ==========================================

  /// Registra un nuevo producto en la base de datos local
  Future<void> addProduct(Product newProduct) async {
    _products.insert(0, newProduct);
    await _storageService.saveProducts(_products);
    notifyListeners();
  }

  /// Actualiza los datos de un producto existente
  Future<void> updateProduct(Product updatedProduct) async {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index >= 0) {
      _products[index] = updatedProduct;

      // Actualizar referencias dentro del carrito si existiese
      for (var i = 0; i < _cartItems.length; i++) {
        if (_cartItems[i].product.id == updatedProduct.id) {
          _cartItems[i] = _cartItems[i].copyWith(product: updatedProduct);
        }
      }

      await _storageService.saveProducts(_products);
      notifyListeners();
    }
  }

  /// Modifica directamente las existencias de un producto
  Future<void> updateProductStock(String productId, int newStock) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final updated = _products[index].copyWith(
        existencias: newStock < 0 ? 0 : newStock,
      );
      _products[index] = updated;
      await _storageService.saveProducts(_products);
      notifyListeners();
    }
  }

  /// Incrementa o decrementa existencias
  Future<void> adjustProductStock(String productId, int delta) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final current = _products[index];
      final newStock = max(0, current.existencias + delta);
      _products[index] = current.copyWith(existencias: newStock);
      await _storageService.saveProducts(_products);
      notifyListeners();
    }
  }

  /// Cambia el estatus del producto (activo / dado de baja) sin eliminarlo
  Future<void> toggleProductStatus(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final current = _products[index];
      final newStatus = !current.estaActivo;
      _products[index] = current.copyWith(estaActivo: newStatus);

      // Si se da de baja, remover del carrito
      if (!newStatus) {
        _cartItems.removeWhere((item) => item.product.id == productId);
      }

      await _storageService.saveProducts(_products);
      notifyListeners();
    }
  }

  /// Actualiza el estatus de una orden (Pendiente, En preparación, Entregado, etc.)
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      await _storageService.saveOrders(_orders);
      notifyListeners();
    }
  }

  /// Restaura los datos del catálogo inicial para demostración académica
  Future<void> restoreSeedData() async {
    await _storageService.resetToSeedData();
    _products = _storageService.loadProducts();
    _orders = _storageService.loadOrders();
    _cartItems.clear();
    notifyListeners();
  }
}
