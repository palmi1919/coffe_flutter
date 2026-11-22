import 'package:flutter/material.dart';

class ProductCategory {
  final int id;
  final String nombre;
  final String? descripcion;
  final bool estatus;

  const ProductCategory({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.estatus = true,
  });

  IconData get icono {
    final lower = nombre.toLowerCase();
    if (lower.contains('caliente')) return Icons.local_fire_department_rounded;
    if (lower.contains('fría') || lower.contains('fria')) return Icons.ac_unit_rounded;
    if (lower.contains('panader')) return Icons.bakery_dining_rounded;
    if (lower.contains('postre')) return Icons.cake_rounded;
    if (lower.contains('alimento') || lower.contains('comida')) return Icons.lunch_dining_rounded;
    return Icons.coffee_rounded;
  }

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['pk_categoria'] as int? ?? (json['id'] as int? ?? 0),
      nombre: json['nom_categoria'] as String? ?? (json['nombre'] as String? ?? ''),
      descripcion: json['descripcion'] as String?,
      estatus: json['estatus'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'pk_categoria': id,
        'nom_categoria': nombre,
        'descripcion': descripcion,
        'estatus': estatus,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductCategory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
