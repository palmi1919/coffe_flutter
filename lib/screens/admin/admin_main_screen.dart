import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../state/coffee_shop_scope.dart';
import '../../widgets/confirm_dialog.dart';
import '../auth/login_screen.dart';
import '../customer/home_screen.dart';
import 'add_product_screen.dart';
import 'admin_dashboard_tab.dart';
import 'admin_inventory_tab.dart';
import 'admin_orders_tab.dart';
import 'edit_products_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Panel de Control',
    'Catálogo de Productos',
    'Control de Inventario',
    'Pedidos en Vivo',
  ];

  final List<String> _subtitles = [
    'Métricas, alertas y accesos rápidos',
    'Alta, edición y baja de productos',
    'Existencias y control de stock',
    'Gestión de órdenes de clientes',
  ];

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      title: '¿Cerrar sesión?',
      message: 'Regresarás a la pantalla de inicio de sesión.',
      confirmText: 'Cerrar sesión',
      confirmColor: AppTheme.primaryCoffee,
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

  Future<void> _handleResetDemo(BuildContext context) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Restablecer catálogo inicial',
      message: 'Se reiniciarán los productos y pedidos a los valores predeterminados de prueba.',
      confirmText: 'Restablecer',
      confirmColor: AppTheme.statusWarning,
      icon: Icons.restart_alt_rounded,
    );

    if (confirm && context.mounted) {
      final state = CoffeeShopScope.of(context);
      await state.restoreSeedData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catálogo y pedidos de prueba restablecidos con éxito.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = CoffeeShopScope.of(context);
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0,
        backgroundColor: AppTheme.surfaceWhite,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.caramel.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppTheme.caramel,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _titles[_currentIndex],
                  style: GoogleFonts.sora(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _subtitles[_currentIndex],
              style: GoogleFonts.sora(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
        actions: [
          // Botón para que el admin pueda acceder al modo cliente / hacer pedidos de café
          IconButton(
            tooltip: 'Vista Menú / Pedir Café',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCream,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: const Icon(
                Icons.local_cafe_outlined,
                color: AppTheme.primaryCoffee,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),

          // Menú de opciones adicionales (Restablecer demo, Cerrar sesión)
          PopupMenuButton<String>(
            tooltip: 'Opciones de Administrador',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCream,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: AppTheme.textDark,
                size: 20,
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'reset') {
                _handleResetDemo(context);
              } else if (value == 'logout') {
                _handleLogout(context);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Administrador',
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      user?.email ?? 'admin@cafe.com',
                      style: GoogleFonts.sora(
                        fontSize: 11,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const Divider(height: 16),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    const Icon(Icons.restart_alt_rounded, size: 18, color: AppTheme.textMedium),
                    const SizedBox(width: 10),
                    Text(
                      'Restablecer catálogo demo',
                      style: GoogleFonts.sora(fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 18, color: AppTheme.statusDanger),
                    const SizedBox(width: 10),
                    Text(
                      'Cerrar sesión',
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        color: AppTheme.statusDanger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: [
          AdminDashboardTab(onNavigateToTab: _navigateToTab),
          const EditProductsScreen(isEmbedded: true),
          const AdminInventoryTab(),
          const AdminOrdersTab(),
        ],
      ),

      // Botón flotante para agregar producto rápidamente
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
              },
              backgroundColor: AppTheme.caramel,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Nuevo Café',
                style: GoogleFonts.sora(fontWeight: FontWeight.w600),
              ),
            )
          : null,

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceWhite,
          border: Border(top: BorderSide(color: AppTheme.borderLight)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _navigateToTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.surfaceWhite,
            selectedItemColor: AppTheme.caramel,
            unselectedItemColor: AppTheme.textLight,
            selectedLabelStyle: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w700),
            unselectedLabelStyle: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w500),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book_rounded),
                label: 'Catálogo',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2_rounded),
                label: 'Inventario',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Pedidos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
