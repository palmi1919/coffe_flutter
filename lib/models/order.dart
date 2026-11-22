import 'cart_item.dart';

enum OrderStatus {
  pendiente,
  enPreparacion,
  listo,
  entregado,
  cancelado;

  String get displayName {
    switch (this) {
      case OrderStatus.pendiente:
        return 'Pendiente';
      case OrderStatus.enPreparacion:
        return 'En preparación';
      case OrderStatus.listo:
        return 'Listo para entrega';
      case OrderStatus.entregado:
        return 'Entregado';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }
}

class OrderProductSummary {
  final String productId;
  final String productName;
  final String sizeName;
  final int quantity;
  final double unitPrice;

  const OrderProductSummary({
    required this.productId,
    required this.productName,
    required this.sizeName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'sizeName': sizeName,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory OrderProductSummary.fromJson(Map<String, dynamic> json) {
    return OrderProductSummary(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? 'Café',
      sizeName: json['sizeName'] as String? ?? 'Estándar',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory OrderProductSummary.fromCartItem(CartItem item) {
    return OrderProductSummary(
      productId: item.product.id,
      productName: item.product.nombre,
      sizeName: item.selectedSize.nombre,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
    );
  }
}

class CoffeeOrder {
  final String id;
  final String customerName;
  final String customerEmail;
  final DateTime date;
  final List<OrderProductSummary> items;
  final double total;
  final OrderStatus status;

  const CoffeeOrder({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.date,
    required this.items,
    required this.total,
    this.status = OrderStatus.pendiente,
  });

  int get totalItemsCount => items.fold(0, (sum, i) => sum + i.quantity);

  CoffeeOrder copyWith({
    String? id,
    String? customerName,
    String? customerEmail,
    DateTime? date,
    List<OrderProductSummary>? items,
    double? total,
    OrderStatus? status,
  }) {
    return CoffeeOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      date: date ?? this.date,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'total': total,
        'status': status.name,
      };

  factory CoffeeOrder.fromJson(Map<String, dynamic> json) {
    return CoffeeOrder(
      id: json['id'] as String? ?? '',
      customerName: json['customerName'] as String? ?? 'Cliente',
      customerEmail: json['customerEmail'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => OrderProductSummary.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.pendiente,
      ),
    );
  }
}
