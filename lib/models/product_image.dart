class ProductImage {
  final int? id;
  final int fkProducto;
  final String url;
  final bool esPrincipal;
  final int orden;

  const ProductImage({
    this.id,
    required this.fkProducto,
    required this.url,
    this.esPrincipal = false,
    this.orden = 1,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['pk_imagen'] as int? ?? json['id'] as int?,
      fkProducto: json['fk_producto'] as int? ?? json['fkProducto'] as int? ?? 0,
      url: json['url'] as String? ?? '',
      esPrincipal: json['es_principal'] as bool? ?? json['esPrincipal'] as bool? ?? false,
      orden: json['orden'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'pk_imagen': id,
        'fk_producto': fkProducto,
        'url': url,
        'es_principal': esPrincipal,
        'orden': orden,
      };

  ProductImage copyWith({
    int? id,
    int? fkProducto,
    String? url,
    bool? esPrincipal,
    int? orden,
  }) {
    return ProductImage(
      id: id ?? this.id,
      fkProducto: fkProducto ?? this.fkProducto,
      url: url ?? this.url,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      orden: orden ?? this.orden,
    );
  }
}
