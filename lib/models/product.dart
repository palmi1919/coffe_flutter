import 'category.dart';
import 'product_size.dart';

class Product {
  final String id;
  final String nombre;
  final String descripcion;
  final double precioBase;
  final ProductCategory categoria;
  final List<ProductSize> tamanos;
  final int existencias;
  final String imagenUrl;
  final bool estaActivo;

  const Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioBase,
    required this.categoria,
    required this.tamanos,
    required this.existencias,
    required this.imagenUrl,
    this.estaActivo = true,
  });

  bool get tieneExistencias => existencias > 0;
  bool get estaDisponible => estaActivo && tieneExistencias;

  double precioConTamano(ProductSize tamano) {
    return precioBase + tamano.precioAdicional;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'precioBase': precioBase,
        'categoriaId': categoria.id,
        'tamanos': tamanos.map((t) => t.toJson()).toList(),
        'existencias': existencias,
        'imagenUrl': imagenUrl,
        'estaActivo': estaActivo,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      precioBase: (json['precioBase'] as num).toDouble(),
      categoria: ProductCategory.fromId(json['categoriaId'] as String),
      tamanos: (json['tamanos'] as List<dynamic>?)
              ?.map((t) => ProductSize.fromJson(t as Map<String, dynamic>))
              .toList() ??
          ProductSize.standardBeverageSizes(),
      existencias: json['existencias'] as int? ?? 0,
      imagenUrl: json['imagenUrl'] as String? ?? '',
      estaActivo: json['estaActivo'] as bool? ?? true,
    );
  }

  Product copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    double? precioBase,
    ProductCategory? categoria,
    List<ProductSize>? tamanos,
    int? existencias,
    String? imagenUrl,
    bool? estaActivo,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioBase: precioBase ?? this.precioBase,
      categoria: categoria ?? this.categoria,
      tamanos: tamanos ?? this.tamanos,
      existencias: existencias ?? this.existencias,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      estaActivo: estaActivo ?? this.estaActivo,
    );
  }
}
