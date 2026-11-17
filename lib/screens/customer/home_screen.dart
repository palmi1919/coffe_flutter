import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/product.dart';
import '../../models/product_size.dart';
import '../../state/coffee_shop_scope.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/product_card.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import '../admin/add_product_screen.dart';
import '../admin/edit_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAdminBottomSheet(BuildContext context) {
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.caramel.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: AppTheme.caramel,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Módulo de administración',
                          style: GoogleFonts.sora(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Gestión del catálogo y existencias',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Opción 1: Pantalla 4 - Agregar productos
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppTheme.primaryCoffee,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Agregar nuevo producto',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Registrar artículos, precios, existencias y fotos',
                    style: GoogleFonts.sora(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: AppTheme.textLight,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddProductScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Opción 2: Pantalla 5 - Edición de productos
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: AppTheme.primaryCoffee,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Modificar catálogo y estatus',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Editar datos, actualizar inventario y dar de baja',
                    style: GoogleFonts.sora(
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: AppTheme.textLight,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProductsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                // Opción rápida para reiniciar demostración académica
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final state = CoffeeShopScope.of(context);
                      await state.restoreSeedData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Catálogo de prueba restablecido con éxito.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.restart_alt_rounded,
                      size: 18,
                      color: AppTheme.textLight,
                    ),
                    label: Text(
                      'Restablecer catálogo inicial',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        color: AppTheme.textLight,
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

  void _onQuickAdd(BuildContext context, Product product) {
    final state = CoffeeShopScope.of(context);
    final size = product.tamanos.isNotEmpty
        ? product.tamanos.first
        : ProductSize.standardBeverageSizes().first;

    final added = state.addToCart(product, size, 1);
    if (added) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${product.nombre} (${size.nombre}) agregado al carrito',
                  style: GoogleFonts.sora(fontSize: 13),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Ver carrito',
            textColor: AppTheme.caramelLight,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay suficientes existencias para agregar más unidades.',
          ),
          backgroundColor: AppTheme.statusDanger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = CoffeeShopScope.of(context);
    final products = state.customerMenuProducts;

    return Scaffold(
      appBar: CoffeeAppBar(
        title: 'Café Aroma',
        subtitle: 'Menú digital & especialidad',
        onCartPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        },
        onAdminPressed: () => _showAdminBottomSheet(context),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Banner de bienvenida y buscador
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.espresso,
                          AppTheme.primaryCoffee,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.caramel.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Grano 100% mexicano',
                                style: GoogleFonts.sora(
                                  color: AppTheme.caramelLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: AppTheme.caramelLight,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'El arte del buen café en tus manos',
                          style: GoogleFonts.sora(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Selecciona tu bebida favorita, personaliza su tamaño y recíbela recién hecha.',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.borderLight,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),

                  // Barra de búsqueda de productos
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => state.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Buscar café, postre o alimento...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.caramel,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppTheme.textLight,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                state.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selector horizontal de categorías
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categorías',
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        '${products.length} disponibles',
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CategorySelectorBar(
                  selectedCategory: state.selectedCategory,
                  onSelected: (cat) => state.setSelectedCategory(cat),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),

          // Grid de productos o vista de estado vacío
          if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.coffee_rounded,
                title: 'No se encontraron productos',
                message:
                    'Intenta buscar con otro término o selecciona una categoría diferente en el menú.',
                buttonText: 'Ver todas las categorías',
                onButtonPressed: () {
                  _searchController.clear();
                  state.setSearchQuery('');
                  state.setSelectedCategory(null);
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.67,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              productId: product.id,
                            ),
                          ),
                        );
                      },
                      onQuickAdd: () => _onQuickAdd(context, product),
                    ).animate().fadeIn(duration: 300.ms, delay: (index * 40).ms);
                  },
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
