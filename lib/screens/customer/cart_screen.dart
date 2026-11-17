import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../config/app_theme.dart';
import '../../models/cart_item.dart';
import '../../state/coffee_shop_scope.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/quantity_stepper.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _showOrderSuccessDialog(BuildContext context, int orderNumber, double totalPaid) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: AppTheme.surfaceWhite,
          surfaceTintColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.statusSuccess.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.statusSuccess,
                    size: 48,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 20),
                Text(
                  '¡Pedido confirmado!',
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu orden fue procesada con éxito y el inventario local ha sido actualizado.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textMedium,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),

                // Ticket resumen simulado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Número de orden',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                          Text(
                            '#CA-$orderNumber',
                            style: GoogleFonts.sora(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryCoffee,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total pagado (simulación)',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                          Text(
                            currencyFormat.format(totalPaid),
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.caramel,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiempo estimado',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                          Text(
                            '10 a 15 minutos',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Cierra diálogo
                      Navigator.pop(context); // Regresa a pantalla principal
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.caramel,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Volver al menú',
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = CoffeeShopScope.of(context);
    final items = state.cartItems;

    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Carrito de compras',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Vaciar carrito',
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: AppTheme.statusDanger,
              ),
              onPressed: () async {
                final confirm = await ConfirmDialog.show(
                  context: context,
                  title: '¿Vaciar carrito?',
                  message:
                      '¿Deseas eliminar todos los productos seleccionados de tu compra?',
                  confirmText: 'Vaciar',
                  confirmColor: AppTheme.statusDanger,
                  icon: Icons.delete_outline_rounded,
                );
                if (confirm) {
                  state.clearCart();
                }
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyStateView(
              icon: Icons.shopping_bag_outlined,
              title: 'Tu carrito está vacío',
              message:
                  'Aún no has agregado productos. Explora nuestro menú y añade tu café o postre favorito.',
              buttonText: 'Explorar menú',
              onButtonPressed: () => Navigator.pop(context),
            )
          : Column(
              children: [
                // Lista de productos del carrito
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildCartItemCard(
                        context,
                        item,
                        state,
                        currencyFormat,
                      ).animate().fadeIn(duration: 250.ms, delay: (index * 30).ms);
                    },
                  ),
                ),

                // Resumen del pedido y botón para realizar pedido
                _buildCheckoutBar(context, state, currencyFormat),
              ],
            ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    CartItem item,
    dynamic state,
    NumberFormat currencyFormat,
  ) {
    final liveProduct =
        state.findProductById(item.product.id) ?? item.product;
    final maxStock = liveProduct.existencias;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fotografía pequeña
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: CachedNetworkImage(
                imageUrl: item.product.imagenUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.surfaceCream,
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.caramel,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.surfaceCream,
                  child: const Icon(
                    Icons.coffee_rounded,
                    color: AppTheme.cinnamon,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Título, tamaño y precio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.selectedSize.nombre,
                        style: GoogleFonts.sora(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryCoffee,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencyFormat.format(item.unitPrice),
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Subtotal: ${currencyFormat.format(item.subtotal)}',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.caramel,
                  ),
                ),
              ],
            ),
          ),

          // Control de cantidad o eliminación
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.statusDanger,
                  size: 20,
                ),
                onPressed: () {
                  state.removeFromCart(item.id);
                },
              ),
              const SizedBox(height: 4),
              QuantityStepper(
                compact: true,
                quantity: item.quantity,
                maxStock: maxStock,
                onIncrement: () {
                  final success = state.incrementCartItem(item.id);
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No hay más existencias disponibles de este producto.',
                        ),
                        backgroundColor: AppTheme.statusWarning,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                onDecrement: () {
                  state.decrementCartItem(item.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(
    BuildContext context,
    dynamic state,
    NumberFormat currencyFormat,
  ) {
    final subtotal = state.cartSubtotal;
    final total = state.cartTotal;
    final itemCount = state.totalCartItemCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Resumen de precios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal ($itemCount productos)',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    color: AppTheme.textMedium,
                  ),
                ),
                Text(
                  currencyFormat.format(subtotal),
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'IVA e impuestos',
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        color: AppTheme.textMedium,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCream,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Incluido',
                        style: GoogleFonts.sora(
                          fontSize: 10,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '16% incluido',
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: AppTheme.borderLight, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total a pagar',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  currencyFormat.format(total),
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.caramel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botón Realizar Pedido (Simulación académica)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await ConfirmDialog.show(
                    context: context,
                    title: '¿Confirmar pedido?',
                    message:
                        'Estás a punto de confirmar tu orden por ${currencyFormat.format(total)}.\n\nEsta es una simulación funcional: se descontarán las existencias del inventario local.',
                    confirmText: 'Realizar pedido',
                    confirmColor: AppTheme.caramel,
                    icon: Icons.receipt_long_rounded,
                  );

                  if (confirm && context.mounted) {
                    final randomOrder = 1000 + Random().nextInt(9000);
                    final totalPaid = total;
                    final success = await state.placeOrder();
                    if (success && context.mounted) {
                      _showOrderSuccessDialog(
                        context,
                        randomOrder,
                        totalPaid,
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Error al procesar el pedido. Comprueba las existencias.',
                          ),
                          backgroundColor: AppTheme.statusDanger,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.caramel,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                  Icons.coffee_maker_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                label: Text(
                  'Realizar pedido',
                  style: GoogleFonts.sora(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
