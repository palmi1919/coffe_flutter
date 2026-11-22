import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/product.dart';
import '../../models/product_size.dart';
import '../../state/coffee_shop_scope.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/product_card.dart';
import '../admin/admin_main_screen.dart';
import '../auth/login_screen.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

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

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      title: '¿Cerrar sesión?',
      message: 'Regresarás a la pantalla de inicio de sesión.',
      confirmText: 'Cerrar sesión',
      confirmColor: AppTheme.statusDanger,
      icon: Icons.logout_rounded,
    );

    if (confirm && context.mounted) {
      final state = CoffeeShopScope.of(context);
      await state.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _onQuickAdd(BuildContext context, Product product) {
    final state = CoffeeShopScope.of(context);
    final size = product.tamanos.isNotEmpty
        ? product.tamanos.first
        : const ProductSize(id: 1, nombre: 'Estándar', descripcionCorta: '', precioAdicional: 0);

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
    final user = state.currentUser;
    final products = state.customerMenuProducts;

    return Scaffold(
      appBar: CoffeeAppBar(
        title: 'Café Aroma',
        subtitle: user != null ? '¡Hola, ${user.name}!' : 'Pide tu café favorito',
        showAdmin: false,
        showLogout: true,
        onLogoutPressed: () => _handleLogout(context),
        onCartPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => state.loadData(),
        color: AppTheme.caramel,
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.caramel),
                ),
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Alerta de error si falló conexión
                  if (state.errorMessage != null)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.statusDanger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.statusDanger.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              color: AppTheme.statusDanger,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: GoogleFonts.sora(
                                  fontSize: 12,
                                  color: AppTheme.statusDanger,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => state.loadData(),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Banner de aviso si un administrador está en la vista de cliente
                  if (state.isAdmin)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.caramel.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.caramel.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: AppTheme.caramel,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Modo Administrador (Vista de Menú)',
                                style: GoogleFonts.sora(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryCoffee,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminMainScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.caramel,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Ir al Panel Admin',
                                  style: GoogleFonts.sora(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

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
                                    color: AppTheme.surfaceCream.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

                  // Selector horizontal de categorías desde Supabase
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
                          categories: state.categories,
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
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
