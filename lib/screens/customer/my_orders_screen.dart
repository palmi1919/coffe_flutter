import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/order.dart';
import '../../state/coffee_shop_scope.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        CoffeeShopScope.of(context).loadOrders();
      }
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        CoffeeShopScope.of(context).loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendiente:
        return AppTheme.caramel;
      case OrderStatus.enPreparacion:
        return Colors.blue.shade700;
      case OrderStatus.listo:
        return Colors.teal.shade700;
      case OrderStatus.entregado:
        return AppTheme.statusSuccess;
      case OrderStatus.cancelado:
        return AppTheme.statusDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = CoffeeShopScope.of(context);
    final orders = state.allOrders;
    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'es_MX');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 65,
        elevation: 0,
        backgroundColor: AppTheme.surfaceWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mis Pedidos',
              style: GoogleFonts.sora(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              'Seguimiento en vivo de tus compras',
              style: GoogleFonts.sora(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => state.loadOrders(),
        color: AppTheme.caramel,
        child: _buildBody(context, state, orders, currencyFormat, dateFormat),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    dynamic state,
    List<CoffeeOrder> orders,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    if (state.isLoadingOrders && orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.caramel),
      );
    }

    if (state.ordersError != null && orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 50,
                color: AppTheme.statusDanger,
              ),
              const SizedBox(height: 16),
              Text(
                state.ordersError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(fontSize: 14, color: AppTheme.textDark),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => state.loadOrders(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.caramel,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCream,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: AppTheme.caramel,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Aún no tienes pedidos',
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cuando realices tu primer pedido, aparecerá aquí en tiempo real.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    color: AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.caramel,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Explorar Menú',
                    style: GoogleFonts.sora(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = orders[index];
        final statusColor = _getStatusColor(order.status);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderLight),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera: Código, Fecha y Estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderCode,
                        style: GoogleFonts.sora(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryCoffee,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateFormat.format(order.date),
                        style: GoogleFonts.sora(
                          fontSize: 11,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      order.status.displayName,
                      style: GoogleFonts.sora(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppTheme.borderLight),
              ),

              // Lista de productos del pedido
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.productName} (${item.sizeName})',
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      Text(
                        currencyFormat.format(item.subtotal),
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: AppTheme.borderLight),
              ),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    currencyFormat.format(order.total),
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.caramel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
