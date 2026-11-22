import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/product_size.dart';
import '../../state/coffee_shop_scope.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/size_selector.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductSize? _selectedSize;
  int _quantity = 1;
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = CoffeeShopScope.of(context);
    final product = state.findProductById(widget.productId);

    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Producto no disponible')),
        body: const Center(
          child: Text('El producto seleccionado ya no se encuentra en el menú.'),
        ),
      );
    }

    _selectedSize ??= product.tamanos.isNotEmpty
        ? product.tamanos.first
        : const ProductSize(id: 1, nombre: 'Estándar', descripcionCorta: '', precioAdicional: 0);

    final currentUnitPrice = product.precioConTamano(_selectedSize!);
    final calculatedTotal = currentUnitPrice * _quantity;
    final remainingStock = state.getAvailableStockForProduct(product.id);
    final isOutOfStock = remainingStock <= 0 || !product.estaActivo;
    final inCartCount = state.getQuantityInCart(product.id);

    // Lista de imágenes para mostrar
    final allImages = product.imagenes.map((img) => img.url).toList();
    if (allImages.isEmpty && product.imagenUrl != null && product.imagenUrl!.isNotEmpty) {
      allImages.add(product.imagenUrl!);
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Imagen(es) con Carousel o Placeholder y AppBar colapsable
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            backgroundColor: AppTheme.backgroundLight,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppTheme.surfaceWhite,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppTheme.textDark,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.surfaceWhite,
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 20,
                          color: AppTheme.textDark,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    if (state.totalCartItemCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppTheme.caramel,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '${state.totalCartItemCount}',
                              style: GoogleFonts.sora(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: allImages.isEmpty
                  ? _buildEmptyPlaceholder()
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          itemCount: allImages.length,
                          onPageChanged: (idx) {
                            setState(() => _currentImageIndex = idx);
                          },
                          itemBuilder: (context, idx) {
                            return CachedNetworkImage(
                              imageUrl: allImages[idx],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.surfaceCream,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.caramel,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _buildEmptyPlaceholder(),
                            );
                          },
                        ),
                        // Indicador de puntos si hay más de 1 imagen
                        if (allImages.length > 1)
                          Positioned(
                            bottom: 24,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                allImages.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentImageIndex == i ? 18 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == i
                                        ? AppTheme.caramel
                                        : Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Degradado inferior
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppTheme.backgroundLight.withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Contenido y detalles del producto
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría y existencias
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.caramel.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              product.categoria?.icono ?? Icons.coffee_rounded,
                              size: 14,
                              color: AppTheme.caramel,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product.categoria?.nombre ?? 'Café de Especialidad',
                              style: GoogleFonts.sora(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.caramel,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? AppTheme.statusDanger.withOpacity(0.12)
                              : (remainingStock <= 5
                                  ? AppTheme.statusWarning.withOpacity(0.12)
                                  : AppTheme.statusSuccess.withOpacity(0.12)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOutOfStock
                                  ? Icons.cancel_outlined
                                  : Icons.inventory_2_outlined,
                              size: 14,
                              color: isOutOfStock
                                  ? AppTheme.statusDanger
                                  : (remainingStock <= 5
                                      ? AppTheme.statusWarning
                                      : AppTheme.statusSuccess),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOutOfStock
                                  ? 'Sin existencias'
                                  : '$remainingStock disponibles',
                              style: GoogleFonts.sora(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isOutOfStock
                                    ? AppTheme.statusDanger
                                    : (remainingStock <= 5
                                        ? AppTheme.statusWarning
                                        : AppTheme.statusSuccess),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nombre del producto
                  Text(
                    product.nombre,
                    style: GoogleFonts.sora(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    product.descripcion,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textMedium,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Divider(color: AppTheme.borderLight, height: 1),
                  const SizedBox(height: 24),

                  // Selector de tamaños
                  if (product.tamanos.isNotEmpty) ...[
                    SizeSelector(
                      sizes: product.tamanos,
                      selectedSize: _selectedSize!,
                      onSizeSelected: (newSize) {
                        setState(() {
                          _selectedSize = newSize;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Selector de cantidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cantidad',
                            style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          if (inCartCount > 0)
                            Text(
                              'Ya tienes $inCartCount en el carrito',
                              style: GoogleFonts.sora(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textLight,
                              ),
                            ),
                        ],
                      ),
                      QuantityStepper(
                        quantity: _quantity,
                        maxStock: remainingStock > 0 ? remainingStock : 1,
                        onIncrement: () {
                          if (_quantity < remainingStock) {
                            setState(() => _quantity++);
                          }
                        },
                        onDecrement: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Barra inferior con total y botón
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Precio total
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Precio total',
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormat.format(calculatedTotal),
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.caramel,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Botón Agregar al carrito
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isOutOfStock
                      ? null
                      : () {
                          final added = state.addToCart(
                            product,
                            _selectedSize!,
                            _quantity,
                          );

                          if (added) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '¡$_quantity x ${product.nombre} (${_selectedSize!.nombre}) agregado al carrito!',
                                  style: GoogleFonts.sora(fontSize: 13),
                                ),
                                action: SnackBarAction(
                                  label: 'Ir al carrito',
                                  textColor: AppTheme.caramelLight,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CartScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No hay suficientes existencias disponibles.',
                                ),
                                backgroundColor: AppTheme.statusDanger,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isOutOfStock ? AppTheme.borderLight : AppTheme.caramel,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.borderLight,
                    disabledForegroundColor: AppTheme.textLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    isOutOfStock
                        ? Icons.block_rounded
                        : Icons.shopping_bag_outlined,
                    size: 20,
                  ),
                  label: Text(
                    isOutOfStock ? 'Agotado' : 'Agregar al carrito',
                    style: GoogleFonts.sora(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      color: AppTheme.surfaceCream,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.coffee_rounded, size: 70, color: AppTheme.cinnamon),
            SizedBox(height: 8),
            Text(
              'Café Aroma',
              style: TextStyle(
                color: AppTheme.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
