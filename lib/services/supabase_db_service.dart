import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/category.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/product_image.dart';
import '../models/product_size.dart';

class SupabaseDbService {
  static SupabaseClient get _client => SupabaseConfig.client;

  // =========================================================================
  // CATEGORÍAS
  // =========================================================================
  static Future<List<ProductCategory>> fetchCategories() async {
    try {
      final res = await _client
          .from('categoria')
          .select('*')
          .eq('estatus', true)
          .order('pk_categoria');

      return (res as List<dynamic>)
          .map((item) => ProductCategory.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error al obtener categorías de Supabase: $e');
      rethrow;
    }
  }

  // =========================================================================
  // TAMAÑOS MAESTROS
  // =========================================================================
  static Future<List<ProductSize>> fetchAllMasterSizes() async {
    try {
      final res = await _client.from('tamano').select('*').order('pk_tamano');
      return (res as List<dynamic>)
          .map((item) => ProductSize.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error al obtener tamaños de Supabase: $e');
      return [];
    }
  }

  // =========================================================================
  // PRODUCTOS
  // =========================================================================
  static Future<List<Product>> fetchProducts() async {
    try {
      final res = await _client
          .from('producto')
          .select('''
            pk_producto,
            nom_producto,
            descripcion,
            precio_base,
            fk_categoria,
            existencias,
            estatus,
            categoria (pk_categoria, nom_categoria, descripcion, estatus),
            producto_tamano (fk_producto, fk_tamano, precio_adicional, tamano (pk_tamano, nom_tamano, descripcion_corta)),
            imagen_producto (pk_imagen, fk_producto, url, es_principal, orden)
          ''')
          .order('pk_producto');

      return (res as List<dynamic>)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error al obtener productos de Supabase: $e');
      rethrow;
    }
  }

  static Future<Product> createProduct({
    required String nombre,
    required String descripcion,
    required double precioBase,
    required int categoriaId,
    required int existencias,
    required List<ProductSize> tamanos,
    required List<Uint8List> newImagesBytes,
    int? principalImageIndex,
  }) async {
    try {
      // 1. Insertar producto
      final insertRes = await _client
          .from('producto')
          .insert({
            'nom_producto': nombre,
            'descripcion': descripcion,
            'precio_base': precioBase,
            'fk_categoria': categoriaId,
            'existencias': existencias,
            'estatus': true,
          })
          .select()
          .single();

      final int newProdId = insertRes['pk_producto'] as int;

      // 2. Insertar tamaños en producto_tamano
      if (tamanos.isNotEmpty) {
        final ptRows = tamanos.map((s) => {
              'fk_producto': newProdId,
              'fk_tamano': s.id,
              'precio_adicional': s.precioAdicional,
            }).toList();
        await _client.from('producto_tamano').insert(ptRows);
      }

      // 3. Subir imágenes a Storage y registrar en imagen_producto
      if (newImagesBytes.isNotEmpty) {
        try {
          for (int i = 0; i < newImagesBytes.length; i++) {
            final bytes = newImagesBytes[i];
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final fileName = 'prod_${newProdId}_${timestamp}_$i.jpg';

            await _client.storage
                .from(SupabaseConfig.bucketProductos)
                .uploadBinary(
                  fileName,
                  bytes,
                  fileOptions: const FileOptions(
                    contentType: 'image/jpeg',
                    upsert: true,
                  ),
                );

            final publicUrl = _client.storage
                .from(SupabaseConfig.bucketProductos)
                .getPublicUrl(fileName);

            final isPrincipal = (principalImageIndex != null && principalImageIndex == i) ||
                (principalImageIndex == null && i == 0);

            await _client.from('imagen_producto').insert({
              'fk_producto': newProdId,
              'url': publicUrl,
              'es_principal': isPrincipal,
              'orden': i + 1,
            });
          }
        } catch (storageError) {
          // Si falló el bucket de storage, limpiar el producto recién insertado para evitar duplicados
          try {
            await _client.from('producto_tamano').delete().eq('fk_producto', newProdId);
            await _client.from('producto').delete().eq('pk_producto', newProdId);
          } catch (_) {}

          debugPrint('Error en storage: $storageError');
          throw Exception(
            'No se pudieron guardar las imágenes del producto. Intenta de nuevo.',
          );
        }
      }

      // Re-consultar el producto completo
      final fullRes = await _client
          .from('producto')
          .select('''
            pk_producto,
            nom_producto,
            descripcion,
            precio_base,
            fk_categoria,
            existencias,
            estatus,
            categoria (pk_categoria, nom_categoria, descripcion, estatus),
            producto_tamano (fk_producto, fk_tamano, precio_adicional, tamano (pk_tamano, nom_tamano, descripcion_corta)),
            imagen_producto (pk_imagen, fk_producto, url, es_principal, orden)
          ''')
          .eq('pk_producto', newProdId)
          .single();

      return Product.fromJson(fullRes);
    } catch (e) {
      debugPrint('Error al crear producto en Supabase: $e');
      rethrow;
    }
  }

  static Future<Product> updateProduct({
    required int productId,
    required String nombre,
    required String descripcion,
    required double precioBase,
    required int categoriaId,
    required int existencias,
    required bool estaActivo,
    required List<ProductSize> tamanos,
    required List<ProductImage> existingImages,
    required List<Uint8List> newImagesBytes,
    int? principalExistingImageId,
    int? principalNewImageIndex,
    required List<int> deleteImageIds,
  }) async {
    try {
      // 1. Actualizar producto base
      await _client.from('producto').update({
        'nom_producto': nombre,
        'descripcion': descripcion,
        'precio_base': precioBase,
        'fk_categoria': categoriaId,
        'existencias': existencias,
        'estatus': estaActivo,
      }).eq('pk_producto', productId);

      // 2. Actualizar tamaños (eliminar existentes y reinsertar)
      await _client
          .from('producto_tamano')
          .delete()
          .eq('fk_producto', productId);

      if (tamanos.isNotEmpty) {
        final ptRows = tamanos.map((s) => {
              'fk_producto': productId,
              'fk_tamano': s.id,
              'precio_adicional': s.precioAdicional,
            }).toList();
        await _client.from('producto_tamano').insert(ptRows);
      }

      // 3. Eliminar imágenes marcadas
      if (deleteImageIds.isNotEmpty) {
        await _client
            .from('imagen_producto')
            .delete()
            .inFilter('pk_imagen', deleteImageIds);
      }

      // 4. Subir nuevas imágenes
      if (newImagesBytes.isNotEmpty) {
        final startOrder = existingImages.length + 1;
        for (int i = 0; i < newImagesBytes.length; i++) {
          final bytes = newImagesBytes[i];
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'prod_${productId}_${timestamp}_$i.jpg';

          await _client.storage
              .from(SupabaseConfig.bucketProductos)
              .uploadBinary(
                fileName,
                bytes,
                fileOptions: const FileOptions(
                  contentType: 'image/jpeg',
                  upsert: true,
                ),
              );

          final publicUrl = _client.storage
              .from(SupabaseConfig.bucketProductos)
              .getPublicUrl(fileName);

          final isPrincipal = (principalNewImageIndex != null && principalNewImageIndex == i);

          await _client.from('imagen_producto').insert({
            'fk_producto': productId,
            'url': publicUrl,
            'es_principal': isPrincipal,
            'orden': startOrder + i,
          });
        }
      }

      // 5. Ajustar es_principal para imágenes existentes
      for (final img in existingImages) {
        if (!deleteImageIds.contains(img.id)) {
          final isPrincipal = (principalExistingImageId == img.id);
          await _client
              .from('imagen_producto')
              .update({'es_principal': isPrincipal})
              .eq('pk_imagen', img.id!);
        }
      }

      // 6. Retornar producto actualizado
      final fullRes = await _client
          .from('producto')
          .select('''
            pk_producto,
            nom_producto,
            descripcion,
            precio_base,
            fk_categoria,
            existencias,
            estatus,
            categoria (pk_categoria, nom_categoria, descripcion, estatus),
            producto_tamano (fk_producto, fk_tamano, precio_adicional, tamano (pk_tamano, nom_tamano, descripcion_corta)),
            imagen_producto (pk_imagen, fk_producto, url, es_principal, orden)
          ''')
          .eq('pk_producto', productId)
          .single();

      return Product.fromJson(fullRes);
    } catch (e) {
      debugPrint('Error al actualizar producto en Supabase: $e');
      rethrow;
    }
  }

  static Future<void> updateStock(int productId, int newStock) async {
    try {
      await _client
          .from('producto')
          .update({'existencias': max(0, newStock)})
          .eq('pk_producto', productId);
    } catch (e) {
      debugPrint('Error al actualizar existencias: $e');
      rethrow;
    }
  }

  static Future<void> toggleProductStatus(int productId, bool currentStatus) async {
    try {
      await _client
          .from('producto')
          .update({'estatus': !currentStatus})
          .eq('pk_producto', productId);
    } catch (e) {
      debugPrint('Error al cambiar estatus del producto: $e');
      rethrow;
    }
  }

  static Future<void> deleteProduct(int productId) async {
    try {
      await _client.from('imagen_producto').delete().eq('fk_producto', productId);
      await _client.from('producto_tamano').delete().eq('fk_producto', productId);
      await _client.from('producto').delete().eq('pk_producto', productId);
    } catch (e) {
      debugPrint('Error al eliminar producto en Supabase: $e');
      rethrow;
    }
  }

  // =========================================================================
  // PEDIDOS
  // =========================================================================
  static Future<List<CoffeeOrder>> fetchOrders({int? userId}) async {
    try {
      var query = _client.from('pedido').select('''
        pk_pedido,
        fk_usuario,
        fecha,
        total,
        fk_estatus_pedido,
        estatus_pedido (nom_estatus),
        usuario (
          pk_usuario,
          nom_usuario,
          persona (nom_persona, apaterno, amaterno)
        ),
        detalle_pedido (
          pk_detalle,
          fk_producto,
          fk_tamano,
          cantidad,
          precio_unitario,
          producto (pk_producto, nom_producto),
          tamano (pk_tamano, nom_tamano)
        )
      ''');

      if (userId != null) {
        query = query.eq('fk_usuario', userId);
      }

      final res = await query.order('fecha', ascending: false);

      return (res as List<dynamic>)
          .map((item) => CoffeeOrder.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error al obtener pedidos de Supabase: $e');
      rethrow;
    }
  }

  static Future<CoffeeOrder> createOrder({
    required int userId,
    required List<CartItem> cartItems,
    required double total,
  }) async {
    try {
      // 1. Insertar cabecera de pedido
      final insertPedido = await _client
          .from('pedido')
          .insert({
            'fk_usuario': userId,
            'fecha': DateTime.now().toIso8601String(),
            'total': total,
            'fk_estatus_pedido': 1, // Pendiente
          })
          .select()
          .single();

      final int pedidoId = (insertPedido['pk_pedido'] as num).toInt();

      // 2. Insertar detalles de pedido
      final detallesRows = cartItems.map((item) => {
            'fk_pedido': pedidoId,
            'fk_producto': item.product.id,
            'fk_tamano': item.selectedSize.id,
            'cantidad': item.quantity,
            'precio_unitario': item.unitPrice,
          }).toList();

      await _client.from('detalle_pedido').insert(detallesRows);

      // 3. Descontar existencias en la tabla producto
      for (final item in cartItems) {
        final newStock = max(0, item.product.existencias - item.quantity);
        await _client
            .from('producto')
            .update({'existencias': newStock})
            .eq('pk_producto', item.product.id);
      }

      // 4. Consultar orden completa para retornar
      final fullOrder = await _client
          .from('pedido')
          .select('''
            pk_pedido,
            fk_usuario,
            fecha,
            total,
            fk_estatus_pedido,
            estatus_pedido (nom_estatus),
            usuario (
              pk_usuario,
              nom_usuario,
              persona (nom_persona, apaterno, amaterno)
            ),
            detalle_pedido (
              pk_detalle,
              fk_producto,
              fk_tamano,
              cantidad,
              precio_unitario,
              producto (pk_producto, nom_producto),
              tamano (pk_tamano, nom_tamano)
            )
          ''')
          .eq('pk_pedido', pedidoId)
          .single();

      return CoffeeOrder.fromJson(fullOrder);
    } catch (e) {
      debugPrint('Error al crear orden en Supabase: $e');
      rethrow;
    }
  }

  static Future<void> updateOrderStatus(int orderId, int newStatusId) async {
    try {
      await _client
          .from('pedido')
          .update({'fk_estatus_pedido': newStatusId})
          .eq('pk_pedido', orderId);
    } catch (e) {
      debugPrint('Error al actualizar estado del pedido en Supabase: $e');
      rethrow;
    }
  }
}
