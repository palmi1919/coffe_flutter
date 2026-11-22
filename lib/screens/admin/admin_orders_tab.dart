import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/order.dart';
import '../../state/coffee_shop_scope.dart';

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  OrderStatus? _statusFilter;
  String _searchQuery = '';

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendiente:
        return AppTheme.caramel;
      case OrderStatus.enPreparacion:
        return Colors.blue;
      case OrderStatus.listo:
        return Colors.teal;
      case OrderStatus.entregado:
        return AppTheme.statusSuccess;
      case OrderStatus.cancelado:
        return AppTheme.statusDanger;
    }
  }

  void _showChangeStatusDialog(BuildContext context, CoffeeOrder order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actualizar estado del pedido ${order.orderCode}',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cliente: ${order.customerName}',
                  style: GoogleFonts.sora(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 18),
                ...OrderStatus.values.map((status) {
                  final isCurrent = order.status == status;
                  final color = _getStatusColor(status);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isCurrent ? color.withOpacity(0.08) : Colors.transparent,
                    leading: Icon(
                      isCurrent ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isCurrent ? color : AppTheme.textLight,
                      size: 20,
                    ),
                    title: Text(
                      status.displayName,
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent ? color : AppTheme.textDark,
                      ),
                    ),
                    onTap: () async {
                      final state = CoffeeShopScope.of(context);
                      Navigator.pop(ctx);
                      await state.updateOrderStatus(order.id, status);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Pedido ${order.orderCode} actualizado a "${status.displayName}"',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  );
                }),
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
    final allOrders = state.allOrders;

    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy • hh:mm a');

    final filtered = allOrders.where((o) {
      if (_statusFilter != null && o.status != _statusFilter) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchId = o.orderCode.toLowerCase().contains(q) || o.id.toString().contains(q);
        final matchClient = o.customerName.toLowerCase().contains(q);
        if (!matchId && !matchClient) return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Filtros y Búsqueda
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceWhite,
            border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
          ),
          child: Column(
            children: [
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar por # de orden o cliente...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.caramel, size: 20),
                  filled: true,
                  fillColor: AppTheme.surfaceCream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todos (${allOrders.length})',
                      isSelected: _statusFilter == null,
                      onTap: () => setState(() => _statusFilter = null),
                    ),
                    const SizedBox(width: 8),
                    ...OrderStatus.values.map((status) {
                      final count = allOrders.where((o) => o.status == status).length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: '${status.displayName} ($count)',
                          isSelected: _statusFilter == status,
                          color: _getStatusColor(status),
                          onTap: () => setState(() => _statusFilter = status),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista de Órdenes con Pull-to-refresh
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => state.loadOrders(),
            color: AppTheme.caramel,
            child: filtered.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppTheme.textLight.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay pedidos con el filtro actual.',
                            style: GoogleFonts.sora(fontSize: 14, color: AppTheme.textMedium),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      final statusColor = _getStatusColor(order.status);

                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.borderLight),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Encabezado de la orden: ID, Estatus y Fecha
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryCoffee.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          order.orderCode,
                                          style: GoogleFonts.sora(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryCoffee,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        dateFormat.format(order.date),
                                        style: GoogleFonts.sora(
                                          fontSize: 11,
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () => _showChangeStatusDialog(context, order),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: statusColor.withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            order.status.displayName,
                                            style: GoogleFonts.sora(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: statusColor,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_drop_down_rounded,
                                            size: 16,
                                            color: statusColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Cliente (nombre desde usuario -> persona)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline_rounded,
                                    size: 16,
                                    color: AppTheme.caramel,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    order.customerName,
                                    style: GoogleFonts.sora(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              const Divider(height: 1, color: AppTheme.borderLight),
                              const SizedBox(height: 10),

                              // Detalle de productos pedidos
                              ...order.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceCream,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${item.quantity}x',
                                          style: GoogleFonts.sora(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryCoffee,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${item.productName} (${item.sizeName})',
                                          style: GoogleFonts.sora(
                                            fontSize: 12.5,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        currencyFormat.format(item.subtotal),
                                        style: GoogleFonts.sora(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              const SizedBox(height: 10),
                              const Divider(height: 1, color: AppTheme.borderLight),
                              const SizedBox(height: 8),

                              // Total de la orden
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total del pedido:',
                                    style: GoogleFonts.sora(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textLight,
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
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryCoffee;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? effectiveColor : AppTheme.surfaceCream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? effectiveColor : AppTheme.borderLight,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.sora(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textMedium,
          ),
        ),
      ),
    );
  }
}
