import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'screens/admin/add_product_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/admin/edit_products_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/my_orders_screen.dart';
import 'services/local_storage_service.dart';
import 'state/coffee_shop_scope.dart';
import 'state/coffee_shop_state.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar los datos de fechas en español (necesario para formatear fechas)
  await initializeDateFormatting('es_MX', null);

  // Configurar estilo de barra de estado translúcida y moderna
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Inicializar Supabase con URL del proyecto y Publishable Key
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.publishableKey,
  );

  // Inicializar y limpiar cualquier sesión previa para requerir login siempre al abrir
  final storageService = await LocalStorageService.init();
  await storageService.clearSession();

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
        navigatorKey: navigatorKey,
        title: 'Café Aroma',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        onGenerateRoute: (settings) => _generateRoute(settings),
      ),
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    final user = state.currentUser;
    final path = settings.name ?? '/login';

    // 1. USUARIO NO AUTENTICADO: Sólo puede acceder a /login y /register
    if (user == null) {
      if (path == '/register') {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      }
      return MaterialPageRoute(
        settings: const RouteSettings(name: '/login'),
        builder: (_) => const LoginScreen(),
      );
    }

    // 2. ADMINISTRADOR: Sólo puede acceder a rutas de administración
    if (user.isAdmin) {
      if (path == '/admin/add') {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AddProductScreen(),
        );
      }
      if (path == '/admin/edit') {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const EditProductsScreen(),
        );
      }
      // Cualquier otra ruta solicitada por admin se redirige al panel de administración
      return MaterialPageRoute(
        settings: const RouteSettings(name: '/admin'),
        builder: (_) => const AdminMainScreen(),
      );
    }

    // 3. CLIENTE: Sólo puede acceder a rutas de cliente
    if (path == '/cart') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const CartScreen(),
      );
    }
    if (path == '/my-orders') {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => const MyOrdersScreen(),
      );
    }

    // Cualquier otra ruta solicitada por cliente se redirige a su menú
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/home'),
      builder: (_) => const HomeScreen(),
    );
  }
}