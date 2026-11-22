class ProductSize {
  final int id;
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
    Map<String, dynamic>? tamanoData;
    if (json['tamano'] is Map<String, dynamic>) {
      tamanoData = json['tamano'] as Map<String, dynamic>;
    } else if (json['tamano'] is List && (json['tamano'] as List).isNotEmpty) {
      tamanoData = (json['tamano'] as List).first as Map<String, dynamic>;
    }

    final idVal = json['pk_tamano'] as int? ??
        (json['fk_tamano'] as int? ??
            (tamanoData?['pk_tamano'] as int? ??
                (json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 1)));

    final nomVal = tamanoData?['nom_tamano'] as String? ??
        (json['nom_tamano'] as String? ?? (json['nombre'] as String? ?? 'Estándar'));

    final descVal = tamanoData?['descripcion_corta'] as String? ??
        (json['descripcion_corta'] as String? ?? (json['descripcionCorta'] as String? ?? ''));

    final precioVal = (json['precio_adicional'] as num?)?.toDouble() ??
        ((json['precioAdicional'] as num?)?.toDouble() ?? 0.0);

    return ProductSize(
      id: idVal,
      nombre: nomVal,
      descripcionCorta: descVal,
      precioAdicional: precioVal,
    );
  }

  ProductSize copyWith({
    int? id,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductSize && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
