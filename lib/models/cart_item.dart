import 'product.dart';
import 'product_size.dart';

class CartItem {
  final Product product;
  final ProductSize selectedSize;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedSize,
    this.quantity = 1,
  });

  String get id => '${product.id}_${selectedSize.id}';

  double get unitPrice => product.precioConTamano(selectedSize);

  double get subtotal => unitPrice * quantity;

  CartItem copyWith({
    Product? product,
    ProductSize? selectedSize,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      selectedSize: selectedSize ?? this.selectedSize,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'sizeId': selectedSize.id,
        'quantity': quantity,
      };
}
