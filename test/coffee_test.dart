import 'package:flutter_test/flutter_test.dart';
import 'package:coffe/models/category.dart';
import 'package:coffe/models/product.dart';
import 'package:coffe/models/product_size.dart';
import 'package:coffe/models/cart_item.dart';
import 'package:coffe/services/seed_data.dart';

void main() {
  group('Pruebas unitarias del modelo de Cafetería', () {
    test('Cálculo correcto de precios según el tamaño del café', () {
      final product = Product(
        id: 'test_1',
        nombre: 'Capuchino artesanal',
        descripcion: 'Café de prueba',
        precioBase: 50.0,
        categoria: ProductCategory.bebidasCalientes,
        tamanos: ProductSize.standardBeverageSizes(),
        existencias: 10,
        imagenUrl: '',
        estaActivo: true,
      );

      final chico = product.tamanos.firstWhere((t) => t.id == 'chico');
      final mediano = product.tamanos.firstWhere((t) => t.id == 'mediano');
      final grande = product.tamanos.firstWhere((t) => t.id == 'grande');

      expect(product.precioConTamano(chico), 50.0);
      expect(product.precioConTamano(mediano), 62.0); // 50 + 12
      expect(product.precioConTamano(grande), 72.0); // 50 + 22
    });

    test('Cálculo de subtotal en elementos del carrito', () {
      final product = Product(
        id: 'test_2',
        nombre: 'Latte frío',
        descripcion: 'Bebida fría',
        precioBase: 60.0,
        categoria: ProductCategory.bebidasFrias,
        tamanos: ProductSize.standardBeverageSizes(),
        existencias: 5,
        imagenUrl: '',
        estaActivo: true,
      );

      final mediano = product.tamanos.firstWhere((t) => t.id == 'mediano');
      final item = CartItem(
        product: product,
        selectedSize: mediano,
        quantity: 3,
      );

      // Precio mediano = 60 + 12 = 72; Subtotal x3 = 216
      expect(item.unitPrice, 72.0);
      expect(item.subtotal, 216.0);
    });

    test('Validación de existencias y disponibilidad', () {
      final availableProduct = Product(
        id: 'p1',
        nombre: 'Con stock',
        descripcion: '',
        precioBase: 40.0,
        categoria: ProductCategory.panaderia,
        tamanos: ProductSize.standardFoodSizes(),
        existencias: 5,
        imagenUrl: '',
        estaActivo: true,
      );

      final outOfStockProduct = availableProduct.copyWith(existencias: 0);
      final inactiveProduct = availableProduct.copyWith(estaActivo: false);

      expect(availableProduct.estaDisponible, isTrue);
      expect(outOfStockProduct.estaDisponible, isFalse);
      expect(inactiveProduct.estaDisponible, isFalse);
    });

    test('Catálogo semilla contiene elementos válidos en todas las categorías', () {
      final products = SeedData.getInitialProducts();
      expect(products.isNotEmpty, isTrue);

      final categoriesInSeed = products.map((p) => p.categoria).toSet();
      expect(categoriesInSeed.contains(ProductCategory.bebidasCalientes), isTrue);
      expect(categoriesInSeed.contains(ProductCategory.bebidasFrias), isTrue);
      expect(categoriesInSeed.contains(ProductCategory.panaderia), isTrue);
      expect(categoriesInSeed.contains(ProductCategory.postres), isTrue);
      expect(categoriesInSeed.contains(ProductCategory.alimentos), isTrue);
    });
  });
}
