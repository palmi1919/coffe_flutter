import 'cart_item.dart';

enum OrderStatus {
  pendiente,
  enPreparacion,
  listo,
  entregado,
  cancelado;

  int get id {
    switch (this) {
      case OrderStatus.pendiente:
        return 1;
      case OrderStatus.enPreparacion:
        return 2;
      case OrderStatus.listo:
        return 3;
      case OrderStatus.entregado:
        return 4;
      case OrderStatus.cancelado:
        return 5;
    }
  }

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

  static OrderStatus fromId(int id) {
    switch (id) {
      case 1:
        return OrderStatus.pendiente;
      case 2:
        return OrderStatus.enPreparacion;
      case 3:
        return OrderStatus.listo;
      case 4:
        return OrderStatus.entregado;
      case 5:
        return OrderStatus.cancelado;
      default:
        return OrderStatus.pendiente;
    }
  }
}

class OrderProductSummary {
  final int? id;
  final int productId;
  final String productName;
  final int? sizeId;
  final String sizeName;
  final int quantity;
  final double unitPrice;

  const OrderProductSummary({
    this.id,
    required this.productId,
    required this.productName,
    this.sizeId,
    required this.sizeName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        if (id != null) 'pk_detalle': id,
        'fk_producto': productId,
        'fk_tamano': sizeId,
        'cantidad': quantity,
        'precio_unitario': unitPrice,
      };

  factory OrderProductSummary.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? prodMap;
    if (json['producto'] is Map<String, dynamic>) {
      prodMap = json['producto'] as Map<String, dynamic>;
    } else if (json['producto'] is List && (json['producto'] as List).isNotEmpty) {
      prodMap = (json['producto'] as List).first as Map<String, dynamic>;
    }

    Map<String, dynamic>? tamanoMap;
    if (json['tamano'] is Map<String, dynamic>) {
      tamanoMap = json['tamano'] as Map<String, dynamic>;
    } else if (json['tamano'] is List && (json['tamano'] as List).isNotEmpty) {
      tamanoMap = (json['tamano'] as List).first as Map<String, dynamic>;
    }

    final pId = (json['fk_producto'] as num?)?.toInt() ??
        ((prodMap?['pk_producto'] as num?)?.toInt() ??
            ((json['productId'] as num?)?.toInt() ?? 0));
    final pName = prodMap?['nom_producto'] as String? ??
        (json['productName'] as String? ?? 'Café');

    final sId = (json['fk_tamano'] as num?)?.toInt() ??
        ((tamanoMap?['pk_tamano'] as num?)?.toInt() ?? (json['sizeId'] as num?)?.toInt());
    final sName = tamanoMap?['nom_tamano'] as String? ??
        (json['sizeName'] as String? ?? 'Estándar');

    final qty = (json['cantidad'] as num?)?.toInt() ?? ((json['quantity'] as num?)?.toInt() ?? 1);
    final unitP = (json['precio_unitario'] as num?)?.toDouble() ??
        ((json['unitPrice'] as num?)?.toDouble() ?? 0.0);

    return OrderProductSummary(
      id: (json['pk_detalle'] as num?)?.toInt(),
      productId: pId,
      productName: pName,
      sizeId: sId,
      sizeName: sName,
      quantity: qty,
      unitPrice: unitP,
    );
  }

  factory OrderProductSummary.fromCartItem(CartItem item) {
    return OrderProductSummary(
      productId: item.product.id,
      productName: item.product.nombre,
      sizeId: item.selectedSize.id,
      sizeName: item.selectedSize.nombre,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
    );
  }
}

class CoffeeOrder {
  final int id;
  final int userId;
  final String customerName;
  final DateTime date;
  final List<OrderProductSummary> items;
  final double total;
  final OrderStatus status;

  const CoffeeOrder({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.date,
    required this.items,
    required this.total,
    this.status = OrderStatus.pendiente,
  });

  String get orderCode => '#CA-$id';

  int get totalItemsCount => items.fold(0, (sum, i) => sum + i.quantity);

  CoffeeOrder copyWith({
    int? id,
    int? userId,
    String? customerName,
    DateTime? date,
    List<OrderProductSummary>? items,
    double? total,
    OrderStatus? status,
  }) {
    return CoffeeOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
    );
  }

  factory CoffeeOrder.fromJson(Map<String, dynamic> json) {
    final pk = (json['pk_pedido'] as num?)?.toInt() ?? ((json['id'] as num?)?.toInt() ?? 0);
    final uId = (json['fk_usuario'] as num?)?.toInt() ?? ((json['userId'] as num?)?.toInt() ?? 0);

    // Cliente nombre parse from pedido -> usuario -> persona
    String cName = 'Cliente';
    dynamic rawUser = json['usuario'];
    if (rawUser is List && rawUser.isNotEmpty) {
      rawUser = rawUser.first;
    }
    final userMap = rawUser as Map<String, dynamic>?;

    if (userMap != null) {
      dynamic rawPersona = userMap['persona'];
      if (rawPersona is List && rawPersona.isNotEmpty) {
        rawPersona = rawPersona.first;
      }
      final personaMap = rawPersona as Map<String, dynamic>?;

      if (personaMap != null) {
        final nom = personaMap['nom_persona'] as String? ?? '';
        final ap = personaMap['apaterno'] as String? ?? '';
        cName = '$nom $ap'.trim();
        if (cName.isEmpty) cName = userMap['nom_usuario'] as String? ?? 'Cliente';
      } else {
        cName = userMap['nom_usuario'] as String? ?? 'Cliente';
      }
    } else if (json['customerName'] is String) {
      cName = json['customerName'] as String;
    }

    final dateVal = json['fecha'] != null
        ? DateTime.tryParse(json['fecha'] as String) ?? DateTime.now()
        : DateTime.now();

    final totVal = (json['total'] as num?)?.toDouble() ?? 0.0;

    final stId = (json['fk_estatus_pedido'] as num?)?.toInt() ?? 1;
    final stEnum = OrderStatus.fromId(stId);

    final rawDetalles = json['detalle_pedido'] as List<dynamic>? ??
        (json['items'] as List<dynamic>? ?? []);
    final itemsList = rawDetalles
        .map((d) => OrderProductSummary.fromJson(d as Map<String, dynamic>))
        .toList();

    return CoffeeOrder(
      id: pk,
      userId: uId,
      customerName: cName,
      date: dateVal,
      items: itemsList,
      total: totVal,
      status: stEnum,
    );
  }
}
