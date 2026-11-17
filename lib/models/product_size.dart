class ProductSize {
  final String id;
  final String nombre;
  final String descripcionCorta;
  final double precioAdicional;

  const ProductSize({
    required this.id,
    required this.nombre,
    required this.descripcionCorta,
    this.precioAdicional = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcionCorta': descripcionCorta,
        'precioAdicional': precioAdicional,
      };

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcionCorta: json['descripcionCorta'] as String? ?? '',
      precioAdicional: (json['precioAdicional'] as num?)?.toDouble() ?? 0.0,
    );
  }

  ProductSize copyWith({
    String? id,
    String? nombre,
    String? descripcionCorta,
    double? precioAdicional,
  }) {
    return ProductSize(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcionCorta: descripcionCorta ?? this.descripcionCorta,
      precioAdicional: precioAdicional ?? this.precioAdicional,
    );
  }

  static List<ProductSize> standardBeverageSizes() {
    return const [
      ProductSize(
        id: 'chico',
        nombre: 'Chico',
        descripcionCorta: '8 oz / 240 ml',
        precioAdicional: 0.0,
      ),
      ProductSize(
        id: 'mediano',
        nombre: 'Mediano',
        descripcionCorta: '12 oz / 360 ml',
        precioAdicional: 12.0,
      ),
      ProductSize(
        id: 'grande',
        nombre: 'Grande',
        descripcionCorta: '16 oz / 480 ml',
        precioAdicional: 22.0,
      ),
    ];
  }

  static List<ProductSize> standardFoodSizes() {
    return const [
      ProductSize(
        id: 'individual',
        nombre: 'Individual',
        descripcionCorta: '1 pieza',
        precioAdicional: 0.0,
      ),
      ProductSize(
        id: 'doble',
        nombre: 'Doble',
        descripcionCorta: '2 piezas',
        precioAdicional: 35.0,
      ),
    ];
  }
}
