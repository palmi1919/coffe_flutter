import '../models/category.dart';
import '../models/product.dart';
import '../models/product_size.dart';

class SeedData {
  static List<Product> getInitialProducts() {
    return [
      // 1. BEBIDAS CALIENTES
      Product(
        id: 'prod_cal_1',
        nombre: 'Capuchino italiano',
        descripcion:
            'Espresso balanceado preparado con granos de altura de Chiapas, leche entera texturizada con una corona densa y espolvoreado con cacao fino.',
        precioBase: 58.0,
        categoria: ProductCategory.bebidasCalientes,
        tamanos: ProductSize.standardBeverageSizes(),
        existencias: 24,
        imagenUrl:
            'https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),
      Product(
        id: 'prod_cal_2',
        nombre: 'Latte de caramelo salado',
        descripcion:
            'Doble carga de espresso suave, leche vaporizada y jarabe casero de caramelo tostado con granos de sal marina de Colima.',
        precioBase: 65.0,
        categoria: ProductCategory.bebidasCalientes,
        tamanos: ProductSize.standardBeverageSizes(),
        existencias: 18,
        imagenUrl:
            'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),
      Product(
        id: 'prod_cal_3',
        nombre: 'Espresso doble especial',
        descripcion:
            'Extracción concentrada de 60 ml con notas cítricas a naranja y un regusto persistente a chocolate amargo.',
        precioBase: 42.0,
        categoria: ProductCategory.bebidasCalientes,
        tamanos: const [
          ProductSize(
            id: 'doble',
            nombre: 'Doble shot',
            descripcionCorta: '2 oz / 60 ml',
            precioAdicional: 0.0,
          ),
        ],
        existencias: 30,
        imagenUrl:
            'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),
      Product(
        id: 'prod_cal_4',
        nombre: 'Chocolate caliente oaxaqueño',
        descripcion:
            'Tradicional tablilla de cacao criollo molido con canela y almendra, batido en leche con molinillo de madera hasta obtener espuma sedosa.',
        precioBase: 55.0,
        categoria: ProductCategory.bebidasCalientes,
        tamanos: ProductSize.standardBeverageSizes(),
        existencias: 15,
        imagenUrl:
            'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),

      // 2. BEBIDAS FRÍAS
      Product(
        id: 'prod_fria_1',
        nombre: 'Cold brew reserva de la casa',
        descripcion:
            'Café macerado en frío durante 18 horas para extraer una acidez aterciopelada y sutiles notas a frutos secos, servido con hielos esfera.',
        precioBase: 62.0,
        categoria: ProductCategory.bebidasFrias,
        tamanos: ProductSize.standardBeverageSizes(),
        existencias: 16,
        imagenUrl:
            'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),
      Product(
        id: 'prod_fria_2',
        nombre: 'Frappé moka y avellana',
        descripcion:
            'Bebida cremosa licuada con hielo, espresso intenso, cocoa belga, crema de avellanas y copete de crema batida con chispas de cacao.',
        precioBase: 74.0,
        categoria: ProductCategory.bebidasFrias,
        tamanos: ProductSize.standardBeverageSizes(),
        existencias: 12,
        imagenUrl:
            'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),
      Product(
        id: 'prod_fria_3',
        nombre: 'Iced matcha latte',
        descripcion:
            'Té verde japonés grado ceremonial batido con leche de almendras y toque dulce de agave orgánico, servido sobre hielo fresco.',
        precioBase: 68.0,
        categoria: ProductCategory.bebidasFrias,
        tamanos: ProductSize.standardBeverageSizes(),
        existencias: 14,
        imagenUrl:
            'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),

      // 3. PANADERÍA
      Product(
        id: 'prod_pan_1',
        nombre: 'Croissant de mantequilla francesa',
        descripcion:
            'Hojaldrado artesanalmente con mantequilla de Nueva Zelanda, corteza dorada y crujiente con un interior tierno y aromático.',
        precioBase: 48.0,
        categoria: ProductCategory.panaderia,
        tamanos: ProductSize.standardFoodSizes(),
        existencias: 10,
        imagenUrl:
            'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),
      Product(
        id: 'prod_pan_2',
        nombre: 'Rol de canela horneado',
        descripcion:
            'Masa brioche esponjosa enrollada con canela de Ceilán y azúcar mascabado, cubierta con abundante glaseado de queso crema.',
        precioBase: 52.0,
        categoria: ProductCategory.panaderia,
        tamanos: ProductSize.standardFoodSizes(),
        existencias: 8,
        imagenUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),
      Product(
        id: 'prod_pan_3',
        nombre: 'Chocolatín hojaldrado',
        descripcion:
            'Pain au chocolat con dos barras internas de chocolate semiamargo al 60% que se funden al hornearse.',
        precioBase: 50.0,
        categoria: ProductCategory.panaderia,
        tamanos: ProductSize.standardFoodSizes(),
        existencias: 6,
        imagenUrl:
            'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),

      // 4. POSTRES
      Product(
        id: 'prod_pos_1',
        nombre: 'Cheesecake neoyorquino con frutos rojos',
        descripcion:
            'Tarta de queso crema suave sobre base de galleta crocante con mantequilla, coronada con coulis artesanal de zarzamoras y fresas frescas.',
        precioBase: 78.0,
        categoria: ProductCategory.postres,
        tamanos: ProductSize.standardFoodSizes(),
        existencias: 7,
        imagenUrl:
            'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),
      Product(
        id: 'prod_pos_2',
        nombre: 'Tiramisú clásico al café',
        descripcion:
            'Soletas bañadas en espresso intenso y licor de café, intercaladas con crema ligera de mascarpone italiano y espolvoreadas con cocoa.',
        precioBase: 72.0,
        categoria: ProductCategory.postres,
        tamanos: ProductSize.standardFoodSizes(),
        existencias: 5,
        imagenUrl:
            'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),

      // 5. ALIMENTOS
      Product(
        id: 'prod_ali_1',
        nombre: 'Chapata caprese con pesto',
        descripcion:
            'Pan chapata recién horneado con rebanadas de mozzarella fresca, jitomate bola maduro, hojas de albahaca y pesto casero al aceite de oliva.',
        precioBase: 95.0,
        categoria: ProductCategory.alimentos,
        tamanos: ProductSize.standardFoodSizes(),
        existencias: 9,
        imagenUrl:
            'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),
      Product(
        id: 'prod_ali_2',
        nombre: 'Baguette de pechuga de pavo y gouda',
        descripcion:
            'Baguette rústica con finas láminas de pechuga de pavo ahumada, queso gouda fundido, espinacas baby y mostaza dijon suave.',
        precioBase: 98.0,
        categoria: ProductCategory.alimentos,
        tamanos: ProductSize.standardFoodSizes(),
        existencias: 11,
        imagenUrl:
            'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=80',
        estaActivo: true,
      ),
    ];
  }

  /// Preset image choices for admin when creating products
  static List<Map<String, String>> presetImages() {
    return [
      {
        'title': 'Capuchino artesanal',
        'url':
            'https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Latte art',
        'url':
            'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Espresso intenso',
        'url':
            'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Cold brew con hielo',
        'url':
            'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Frappé con crema',
        'url':
            'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Matcha latte frío',
        'url':
            'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Croissant dorado',
        'url':
            'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Rol de canela',
        'url':
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Cheesecake frutos rojos',
        'url':
            'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Tiramisú de café',
        'url':
            'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Sándwich gourmet',
        'url':
            'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
      },
      {
        'title': 'Baguette tostada',
        'url':
            'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=80',
      },
    ];
  }
}
