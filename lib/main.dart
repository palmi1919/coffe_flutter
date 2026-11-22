import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_theme.dart';
import 'screens/admin/add_product_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/admin/edit_products_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/home_screen.dart';
import 'services/local_storage_service.dart';
import 'state/coffee_shop_scope.dart';
import 'state/coffee_shop_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar estilo de barra de estado translúcida y moderna
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Inicializar almacenamiento local con persistencia y catálogo base
  final storageService = await LocalStorageService.init();
  final coffeeState = CoffeeShopState(storageService);

  runApp(CoffeeApp(state: coffeeState));
}

class CoffeeApp extends StatelessWidget {
  final CoffeeShopState state;

  const CoffeeApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return CoffeeShopScope(
      state: state,
      child: MaterialApp(
        title: 'Café Aroma',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Pantalla inicial según el estado de autenticación y rol
        home: _getInitialScreen(state),
        // Rutas nombradas para navegación en el sistema
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin': (context) => const AdminMainScreen(),
          '/cart': (context) => const CartScreen(),
          '/admin/add': (context) => const AddProductScreen(),
          '/admin/edit': (context) => const EditProductsScreen(),
        },
      ),
    );
  }

  Widget _getInitialScreen(CoffeeShopState state) {
    if (!state.isAuthenticated) {
      return const LoginScreen();
    }
    if (state.isAdmin) {
      return const AdminMainScreen();
    }
    return const HomeScreen();
  }
}
