import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/product_image.dart';
import '../models/product_size.dart';
import '../models/user.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_db_service.dart';

class CoffeeShopState extends ChangeNotifier {
  final LocalStorageService _storageService;

  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  List<ProductSize> _masterSizes = [];
  List<CoffeeOrder> _orders = [];
  final List<CartItem> _cartItems = [];

  AppUser? _currentUser;
  ProductCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;
  String? _lastOrderError;

  CoffeeShopState(this._storageService) {
    _currentUser = _storageService.loadUser();
    loadData();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get lastOrderError => _lastOrderError;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  ProductCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get allProducts => List.unmodifiable(_products);
  List<ProductCategory> get categories => List.unmodifiable(_categories);
  List<ProductSize> get masterSizes => List.unmodifiable(_masterSizes);
  List<CoffeeOrder> get allOrders => List.unmodifiable(_orders);

  /// Catálogo visible para el cliente (únicamente productos con estatus activo)
  List<Product> get customerMenuProducts {
    return _products.where((p) {
      if (!p.estaActivo) return false;
      if (_selectedCategory != null && p.fkCategoria != _selectedCategory!.id) {
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

  /// Lista de productos para la pantalla de administración
  List<Product> get adminProducts {
    if (_searchQuery.trim().isEmpty) {
      return List.unmodifiable(_products);
    }
    final query = _searchQuery.toLowerCase().trim();
    return _products.where((p) {
      final matchCat = p.categoria?.nombre.toLowerCase().contains(query) ?? false;
      return p.nombre.toLowerCase().contains(query) || matchCat;
    }).toList();
  }

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get totalCartItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get cartSubtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

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

  // ==========================================
  // CARGA DE DATOS DESDE SUPABASE
  // ==========================================
  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedCategories = await SupabaseDbService.fetchCategories();
      final fetchedSizes = await SupabaseDbService.fetchAllMasterSizes();
      final fetchedProducts = await SupabaseDbService.fetchProducts();

      _categories = fetchedCategories;
      _masterSizes = fetchedSizes;
      _products = fetchedProducts;

      await loadOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar datos en CoffeeShopState: $e');
      _errorMessage = 'No se pudo conectar a la base de datos de Supabase. Revisa tu conexión e intenta de nuevo.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    try {
      if (_currentUser == null) {
        _orders = [];
        return;
      }
      if (_currentUser!.isAdmin) {
        _orders = await SupabaseDbService.fetchOrders();
      } else {
        _orders = await SupabaseDbService.fetchOrders(userId: _currentUser!.id);
      }
    } catch (e) {
      debugPrint('Error al cargar pedidos: $e');
    }
  }

  // ==========================================
  // AUTENTICACIÓN Y SESIÓN
  // ==========================================
  Future<void> login(AppUser user) async {
    _currentUser = user;
    await _storageService.saveUser(user);
    await loadOrders();
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _cartItems.clear();
    _orders = [];
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

  Product? findProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // OPERACIONES DEL CARRITO
  // ==========================================
  int getQuantityInCart(int productId) {
    return _cartItems
        .where((item) => item.product.id == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  int getAvailableStockForProduct(int productId) {
    final product = findProductById(productId);
    if (product == null) return 0;
    final inCart = getQuantityInCart(productId);
    final remaining = product.existencias - inCart;
    return remaining > 0 ? remaining : 0;
  }

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

  void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // ==========================================
  // CONFIRMACIÓN DE PEDIDO EN SUPABASE
  // ==========================================
  Future<CoffeeOrder?> placeOrder() async {
    _lastOrderError = null;
    if (_cartItems.isEmpty) {
      _lastOrderError = 'El carrito está vacío.';
      return null;
    }
    if (_currentUser == null) {
      _lastOrderError = 'Debes iniciar sesión para realizar un pedido.';
      return null;
    }

    // Verificar existencias locales
    for (final item in _cartItems) {
      final product = findProductById(item.product.id);
      if (product == null) {
        _lastOrderError =
            'El producto "${item.product.nombre}" ya no está disponible en el menú.';
        return null;
      }
      if (product.existencias < item.quantity) {
        _lastOrderError =
            'No hay suficientes existencias de "${item.product.nombre}" (disponibles: ${product.existencias}).';
        return null;
      }
    }

    try {
      final order = await SupabaseDbService.createOrder(
        userId: _currentUser!.id,
        cartItems: _cartItems,
        total: cartTotal,
      );

      _orders.insert(0, order);

      // Descontar existencias en memoria local
      for (final item in _cartItems) {
        final pIdx = _products.indexWhere((p) => p.id == item.product.id);
        if (pIdx >= 0) {
          final cur = _products[pIdx];
          final nStock = max(0, cur.existencias - item.quantity);
          _products[pIdx] = cur.copyWith(existencias: nStock);
        }
      }

      _cartItems.clear();
      notifyListeners();
      return order;
    } catch (e) {
      debugPrint('Error al registrar pedido en Supabase: $e');
      _lastOrderError = e.toString();
      return null;
    }
  }

  // ==========================================
  // OPERACIONES DEL ADMINISTRADOR EN SUPABASE
  // ==========================================
  Future<void> addProduct({
    required String nombre,
    required String descripcion,
    required double precioBase,
    required int categoriaId,
    required int existencias,
    required List<ProductSize> tamanos,
    required List<Uint8List> newImagesBytes,
    int? principalImageIndex,
  }) async {
    try {
      final newProd = await SupabaseDbService.createProduct(
        nombre: nombre,
        descripcion: descripcion,
        precioBase: precioBase,
        categoriaId: categoriaId,
        existencias: existencias,
        tamanos: tamanos,
        newImagesBytes: newImagesBytes,
        principalImageIndex: principalImageIndex,
      );

      _products.insert(0, newProd);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al agregar producto: $e');
      rethrow;
    }
  }

  Future<void> updateProduct({
    required int productId,
    required String nombre,
    required String descripcion,
    required double precioBase,
    required int categoriaId,
    required int existencias,
    required bool estaActivo,
    required List<ProductSize> tamanos,
    required List<ProductImage> existingImages,
    required List<Uint8List> newImagesBytes,
    int? principalExistingImageId,
    int? principalNewImageIndex,
    required List<int> deleteImageIds,
  }) async {
    try {
      final updated = await SupabaseDbService.updateProduct(
        productId: productId,
        nombre: nombre,
        descripcion: descripcion,
        precioBase: precioBase,
        categoriaId: categoriaId,
        existencias: existencias,
        estaActivo: estaActivo,
        tamanos: tamanos,
        existingImages: existingImages,
        newImagesBytes: newImagesBytes,
        principalExistingImageId: principalExistingImageId,
        principalNewImageIndex: principalNewImageIndex,
        deleteImageIds: deleteImageIds,
      );

      final idx = _products.indexWhere((p) => p.id == productId);
      if (idx >= 0) {
        _products[idx] = updated;
      }

      // Actualizar referencias dentro del carrito
      for (var i = 0; i < _cartItems.length; i++) {
        if (_cartItems[i].product.id == productId) {
          _cartItems[i] = _cartItems[i].copyWith(product: updated);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error al editar producto: $e');
      rethrow;
    }
  }

  Future<void> updateProductStock(int productId, int newStock) async {
    try {
      await SupabaseDbService.updateStock(productId, newStock);
      final idx = _products.indexWhere((p) => p.id == productId);
      if (idx >= 0) {
        _products[idx] = _products[idx].copyWith(existencias: max(0, newStock));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al actualizar existencias: $e');
      rethrow;
    }
  }

  Future<void> adjustProductStock(int productId, int delta) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx >= 0) {
      final newStock = max(0, _products[idx].existencias + delta);
      await updateProductStock(productId, newStock);
    }
  }

  Future<void> toggleProductStatus(int productId) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx >= 0) {
      final current = _products[idx];
      final newStatus = !current.estaActivo;
      await SupabaseDbService.toggleProductStatus(productId, current.estaActivo);
      _products[idx] = current.copyWith(estaActivo: newStatus);

      if (!newStatus) {
        _cartItems.removeWhere((item) => item.product.id == productId);
      }
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await SupabaseDbService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      _cartItems.removeWhere((item) => item.product.id == productId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al eliminar producto: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    try {
      await SupabaseDbService.updateOrderStatus(orderId, newStatus.id);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) {
        _orders[idx] = _orders[idx].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al actualizar estado del pedido: $e');
      rethrow;
    }
  }
}
