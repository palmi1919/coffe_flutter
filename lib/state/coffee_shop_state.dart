import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/product_size.dart';
import '../models/cart_item.dart';
import '../services/local_storage_service.dart';

class CoffeeShopState extends ChangeNotifier {
  final LocalStorageService _storageService;

  List<Product> _products = [];
  final List<CartItem> _cartItems = [];

  ProductCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = true;

  CoffeeShopState(this._storageService) {
    _loadInitialData();
  }

  bool get isLoading => _isLoading;
  ProductCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get allProducts => List.unmodifiable(_products);

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

  void _loadInitialData() {
    _products = _storageService.loadProducts();
    _isLoading = false;
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
      (item) => item.product.id == liveProduct.id && item.selectedSize.id == size.id,
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

  /// Confirma el pedido: descuenta existencias en la base de datos y vacía el carrito
  Future<bool> placeOrder() async {
    if (_cartItems.isEmpty) return false;

    // Verificar que todas las existencias sigan siendo suficientes
    for (final item in _cartItems) {
      final product = findProductById(item.product.id);
      if (product == null || product.existencias < item.quantity) {
        return false;
      }
    }

    // Descontar existencias
    for (final item in _cartItems) {
      final productIndex = _products.indexWhere((p) => p.id == item.product.id);
      if (productIndex >= 0) {
        final current = _products[productIndex];
        final newStock = current.existencias - item.quantity;
        _products[productIndex] = current.copyWith(
          existencias: newStock < 0 ? 0 : newStock,
        );
      }
    }

    // Guardar en almacenamiento local
    await _storageService.saveProducts(_products);

    // Vaciar carrito
    _cartItems.clear();
    notifyListeners();
    return true;
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

  /// Restaura los datos del catálogo inicial para demostración académica
  Future<void> restoreSeedData() async {
    await _storageService.resetToSeedData();
    _products = _storageService.loadProducts();
    _cartItems.clear();
    notifyListeners();
  }
}
