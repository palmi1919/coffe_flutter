import 'package:flutter_test/flutter_test.dart';
import 'package:coffe/models/category.dart';
import 'package:coffe/models/product.dart';
import 'package:coffe/models/product_size.dart';
import 'package:coffe/models/cart_item.dart';

void main() {
  group('Pruebas unitarias del modelo de Cafetería con Supabase', () {
    test('Cálculo correcto de precios según el tamaño del café', () {
      const product = Product(
        id: 1,
        nombre: 'Capuchino artesanal',
        descripcion: 'Café de prueba',
        precioBase: 50.0,
        categoria: ProductCategory(id: 1, nombre: 'Bebidas calientes'),
        tamanos: [
          ProductSize(id: 1, nombre: 'Chico', descripcionCorta: '8 oz', precioAdicional: 0),
          ProductSize(id: 2, nombre: 'Mediano', descripcionCorta: '12 oz', precioAdicional: 12),
          ProductSize(id: 3, nombre: 'Grande', descripcionCorta: '16 oz', precioAdicional: 22),
        ],
        existencias: 10,
        imagenUrl: '',
        estaActivo: true,
      );

      final chico = product.tamanos.firstWhere((t) => t.id == 1);
      final mediano = product.tamanos.firstWhere((t) => t.id == 2);
      final grande = product.tamanos.firstWhere((t) => t.id == 3);

      expect(product.precioConTamano(chico), 50.0);
      expect(product.precioConTamano(mediano), 62.0); // 50 + 12
      expect(product.precioConTamano(grande), 72.0); // 50 + 22
    });

    test('Cálculo de subtotal en elementos del carrito', () {
      const product = Product(
        id: 2,
        nombre: 'Latte frío',
        descripcion: 'Bebida fría',
        precioBase: 60.0,
        categoria: ProductCategory(id: 2, nombre: 'Bebidas frías'),
        tamanos: [
          ProductSize(id: 2, nombre: 'Mediano', descripcionCorta: '12 oz', precioAdicional: 12),
        ],
        existencias: 5,
        imagenUrl: '',
        estaActivo: true,
      );

      final mediano = product.tamanos.first;
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
      const availableProduct = Product(
        id: 3,
        nombre: 'Con stock',
        descripcion: '',
        precioBase: 40.0,
        categoria: ProductCategory(id: 3, nombre: 'Panadería'),
        tamanos: [
          ProductSize(id: 4, nombre: 'Individual', descripcionCorta: '1 pza', precioAdicional: 0),
        ],
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
  });
}
