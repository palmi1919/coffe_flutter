import 'category.dart';
import 'product_image.dart';
import 'product_size.dart';

class Product {
  final int id;
  final String nombre;
  final String descripcion;
  final double precioBase;
  final int? fkCategoria;
  final ProductCategory? categoria;
  final List<ProductSize> tamanos;
  final int existencias;
  final String? imagenUrl;
  final List<ProductImage> imagenes;
  final bool estaActivo;

  const Product({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioBase,
    this.fkCategoria,
    this.categoria,
    required this.tamanos,
    required this.existencias,
    this.imagenUrl,
    this.imagenes = const [],
    this.estaActivo = true,
  });

  bool get tieneExistencias => existencias > 0;
  bool get estaDisponible => estaActivo && tieneExistencias;

  String get primaryImageUrl {
    // Buscar imagen marcada como principal
    if (imagenes.isNotEmpty) {
      final principal = imagenes.firstWhere(
        (img) => img.esPrincipal,
        orElse: () => imagenes.first,
      );
      if (principal.url.trim().isNotEmpty) {
        return principal.url;
      }
    }
    if (imagenUrl != null && imagenUrl!.trim().isNotEmpty) {
      return imagenUrl!;
    }
    return '';
  }

  double precioConTamano(ProductSize tamano) {
    return precioBase + tamano.precioAdicional;
  }

  Map<String, dynamic> toDbJson() => {
        'nom_producto': nombre,
        'descripcion': descripcion,
        'precio_base': precioBase,
        'fk_categoria': fkCategoria ?? categoria?.id,
        'existencias': existencias,
        'estatus': estaActivo,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    final pk = json['pk_producto'] as int? ?? (json['id'] as int? ?? 0);
    final nom = json['nom_producto'] as String? ?? (json['nombre'] as String? ?? '');
    final desc = json['descripcion'] as String? ?? '';
    final precio = (json['precio_base'] as num?)?.toDouble() ??
        ((json['precioBase'] as num?)?.toDouble() ?? 0.0);
    final stock = json['existencias'] as int? ?? 0;
    final imgUrl = json['imagen_url'] as String? ?? json['imagenUrl'] as String?;
    final activo = json['estatus'] as bool? ?? (json['estaActivo'] as bool? ?? true);
    final catFk = json['fk_categoria'] as int?;

    // Categoría parse
    ProductCategory? cat;
    if (json['categoria'] is Map<String, dynamic>) {
      cat = ProductCategory.fromJson(json['categoria'] as Map<String, dynamic>);
    } else if (json['categoria'] is List && (json['categoria'] as List).isNotEmpty) {
      cat = ProductCategory.fromJson((json['categoria'] as List).first as Map<String, dynamic>);
    } else if (catFk != null) {
      cat = ProductCategory(id: catFk, nombre: 'Categoría $catFk');
    }

    // Imágenes parse
    final rawImgs = json['imagen_producto'] as List<dynamic>?;
    final List<ProductImage> imgs = rawImgs != null
        ? rawImgs.map((img) => ProductImage.fromJson(img as Map<String, dynamic>)).toList()
        : [];
    imgs.sort((a, b) => a.orden.compareTo(b.orden));

    // Tamaños parse
    final rawTamanos = json['producto_tamano'] as List<dynamic>?;
    List<ProductSize> sizes = [];
    if (rawTamanos != null && rawTamanos.isNotEmpty) {
      sizes = rawTamanos
          .map((pt) => ProductSize.fromJson(pt as Map<String, dynamic>))
          .toList();
    } else if (json['tamanos'] is List) {
      sizes = (json['tamanos'] as List)
          .map((s) => ProductSize.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    if (sizes.isEmpty) {
      sizes = [
        const ProductSize(id: 1, nombre: 'Chico', descripcionCorta: '8 oz', precioAdicional: 0),
        const ProductSize(id: 2, nombre: 'Mediano', descripcionCorta: '12 oz', precioAdicional: 12),
        const ProductSize(id: 3, nombre: 'Grande', descripcionCorta: '16 oz', precioAdicional: 22),
      ];
    }

    return Product(
      id: pk,
      nombre: nom,
      descripcion: desc,
      precioBase: precio,
      fkCategoria: catFk ?? cat?.id,
      categoria: cat,
      tamanos: sizes,
      existencias: stock,
      imagenUrl: imgUrl,
      imagenes: imgs,
      estaActivo: activo,
    );
  }

  Product copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precioBase,
    int? fkCategoria,
    ProductCategory? categoria,
    List<ProductSize>? tamanos,
    int? existencias,
    String? imagenUrl,
    List<ProductImage>? imagenes,
    bool? estaActivo,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precioBase: precioBase ?? this.precioBase,
      fkCategoria: fkCategoria ?? this.fkCategoria,
      categoria: categoria ?? this.categoria,
      tamanos: tamanos ?? this.tamanos,
      existencias: existencias ?? this.existencias,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      imagenes: imagenes ?? this.imagenes,
      estaActivo: estaActivo ?? this.estaActivo,
    );
  }
}
