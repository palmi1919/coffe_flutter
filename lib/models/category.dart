import 'package:flutter/material.dart';

enum ProductCategory {
  bebidasCalientes(
    id: 'calientes',
    nombre: 'Bebidas calientes',
    icono: Icons.local_cafe_rounded,
    descripcion: 'Espressos, capuchinos, lattes y chocolates artesanales.',
  ),
  bebidasFrias(
    id: 'frias',
    nombre: 'Bebidas frías',
    icono: Icons.ac_unit_rounded,
    descripcion: 'Cold brew, frappés refrescantes e iced lattes.',
  ),
  panaderia(
    id: 'panaderia',
    nombre: 'Panadería',
    icono: Icons.bakery_dining_rounded,
    descripcion: 'Croissants recién horneados, roles de canela y muffins.',
  ),
  postres(
    id: 'postres',
    nombre: 'Postres',
    icono: Icons.cake_rounded,
    descripcion: 'Rebanadas de pastel, tartas finas y cheesecakes.',
  ),
  alimentos(
    id: 'alimentos',
    nombre: 'Alimentos',
    icono: Icons.lunch_dining_rounded,
    descripcion: 'Chapatas, baguettes preparados y sándwiches gourmet.',
  );

  final String id;
  final String nombre;
  final IconData icono;
  final String descripcion;

  const ProductCategory({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.descripcion,
  });

  static ProductCategory fromId(String id) {
    return ProductCategory.values.firstWhere(
      (cat) => cat.id == id,
      orElse: () => ProductCategory.bebidasCalientes,
    );
  }
}
