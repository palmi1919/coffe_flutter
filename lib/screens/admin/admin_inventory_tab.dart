import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../state/coffee_shop_scope.dart';

class AdminInventoryTab extends StatefulWidget {
  const AdminInventoryTab({super.key});

  @override
  State<AdminInventoryTab> createState() => _AdminInventoryTabState();
}

class _AdminInventoryTabState extends State<AdminInventoryTab> {
  String _searchQuery = '';
  String _filterStockStatus = 'all'; // 'all', 'low', 'out'
  ProductCategory? _selectedCategory;

  void _showSetStockDialog(BuildContext context, Product product) {
    final controller = TextEditingController(text: product.existencias.toString());
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Ajustar existencias',
            style: GoogleFonts.sora(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.nombre,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryCoffee,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ingresa la nueva cantidad en inventario:',
                style: GoogleFonts.sora(
                  fontSize: 12,
                  color: AppTheme.textMedium,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Ej. 25',
                  filled: true,
                  fillColor: AppTheme.surfaceCream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderLight),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancelar',
                style: GoogleFonts.sora(color: AppTheme.textLight),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newStock = int.tryParse(controller.text.trim());
                if (newStock != null && newStock >= 0) {
                  final state = CoffeeShopScope.of(context);
                  Navigator.pop(ctx);
                  await state.updateProductStock(product.id, newStock);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Existencias de ${product.nombre} fijadas en $newStock'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.caramel,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Guardar', style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = CoffeeShopScope.of(context);
    final allProducts = state.allProducts;

    final totalUnits = allProducts.fold<int>(0, (sum, p) => sum + p.existencias);
    final lowStockCount = allProducts.where((p) => p.existencias > 0 && p.existencias <= 5).length;
    final outOfStockCount = allProducts.where((p) => p.existencias == 0).length;

    final filtered = allProducts.where((p) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!p.nombre.toLowerCase().contains(q)) return false;
      }
      if (_selectedCategory != null && p.fkCategoria != _selectedCategory!.id) {
        return false;
      }
      if (_filterStockStatus == 'low' && (p.existencias <= 0 || p.existencias > 5)) {
        return false;
      }
      if (_filterStockStatus == 'out' && p.existencias > 0) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Resumen superior de inventario
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceWhite,
            border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InventoryStatChip(
                      label: 'Total Unidades',
                      count: '$totalUnits',
                      color: AppTheme.primaryCoffee,
                      icon: Icons.inventory_rounded,
                      isSelected: _filterStockStatus == 'all',
                      onTap: () => setState(() => _filterStockStatus = 'all'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InventoryStatChip(
                      label: 'Bajo Stock (≤5)',
                      count: '$lowStockCount',
                      color: AppTheme.statusWarning,
                      icon: Icons.warning_amber_rounded,
                      isSelected: _filterStockStatus == 'low',
                      onTap: () => setState(() => _filterStockStatus = 'low'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InventoryStatChip(
                      label: 'Agotados (0)',
                      count: '$outOfStockCount',
                      color: AppTheme.statusDanger,
                      icon: Icons.error_outline_rounded,
                      isSelected: _filterStockStatus == 'out',
                      onTap: () => setState(() => _filterStockStatus = 'out'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre de producto...',
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
            ],
          ),
        ),

        // Lista de existencias
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No se encontraron productos con el filtro aplicado.',
                    style: GoogleFonts.sora(fontSize: 13, color: AppTheme.textLight),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    final isOutOfStock = product.existencias == 0;
                    final isLowStock = product.existencias > 0 && product.existencias <= 5;
                    final mainImg = product.primaryImageUrl;

                    Color badgeColor = AppTheme.statusSuccess;
                    String badgeText = '${product.existencias} disp.';
                    if (isOutOfStock) {
                      badgeColor = AppTheme.statusDanger;
                      badgeText = 'Agotado';
                    } else if (isLowStock) {
                      badgeColor = AppTheme.statusWarning;
                      badgeText = '${product.existencias} bajo';
                    }

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isOutOfStock
                              ? AppTheme.statusDanger.withOpacity(0.3)
                              : AppTheme.borderLight,
                        ),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: mainImg.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: mainImg,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => Container(
                                            color: AppTheme.surfaceCream,
                                            child: const Icon(
                                              Icons.coffee_rounded,
                                              color: AppTheme.cinnamon,
                                              size: 24,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: AppTheme.surfaceCream,
                                          child: const Icon(
                                            Icons.coffee_rounded,
                                            color: AppTheme.cinnamon,
                                            size: 24,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.nombre,
                                      style: GoogleFonts.sora(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${product.categoria?.nombre ?? "Café"} • ${product.estaActivo ? "Activo" : "Dado de baja"}',
                                      style: GoogleFonts.sora(
                                        fontSize: 11,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isOutOfStock
                                          ? Icons.cancel_outlined
                                          : (isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline),
                                      size: 14,
                                      color: badgeColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      badgeText,
                                      style: GoogleFonts.sora(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: badgeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppTheme.borderLight),
                          const SizedBox(height: 8),

                          // Barra de ajuste de existencias
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ajuste rápido:',
                                style: GoogleFonts.sora(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                              Row(
                                children: [
                                  // Botón -1
                                  _StockButton(
                                    label: '-1',
                                    color: Colors.red.shade400,
                                    onTap: product.existencias > 0
                                        ? () => state.adjustProductStock(product.id, -1)
                                        : null,
                                  ),
                                  const SizedBox(width: 6),
                                  // Botón +1
                                  _StockButton(
                                    label: '+1',
                                    color: AppTheme.primaryCoffee,
                                    onTap: () => state.adjustProductStock(product.id, 1),
                                  ),
                                  const SizedBox(width: 6),
                                  // Botón +5
                                  _StockButton(
                                    label: '+5',
                                    color: AppTheme.caramel,
                                    onTap: () => state.adjustProductStock(product.id, 5),
                                  ),
                                  const SizedBox(width: 6),
                                  // Botón +10
                                  _StockButton(
                                    label: '+10',
                                    color: AppTheme.caramel,
                                    onTap: () => state.adjustProductStock(product.id, 10),
                                  ),
                                  const SizedBox(width: 8),
                                  // Botón escribir cantidad
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_note_rounded,
                                      color: AppTheme.primaryCoffee,
                                      size: 22,
                                    ),
                                    tooltip: 'Definir cantidad exacta',
                                    onPressed: () => _showSetStockDialog(context, product),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InventoryStatChip extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _InventoryStatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : AppTheme.surfaceCream,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  count,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.sora(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMedium,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StockButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _StockButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: (onTap == null) ? AppTheme.borderLight : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (onTap == null) ? AppTheme.borderLight : color.withOpacity(0.3),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.sora(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: (onTap == null) ? AppTheme.textLight : color,
            ),
          ),
        ),
      ),
    );
  }
}
