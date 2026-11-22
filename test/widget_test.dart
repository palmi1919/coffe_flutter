import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coffe/main.dart';
import 'package:coffe/models/user.dart';
import 'package:coffe/services/local_storage_service.dart';
import 'package:coffe/state/coffee_shop_state.dart';

void main() {
  testWidgets('Carga inicial en pantalla de Login y acceso a cliente y admin',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await LocalStorageService.init();
    final state = CoffeeShopState(storageService);

    await tester.pumpWidget(CoffeeApp(state: state));
    await tester.pumpAndSettle();

    // 1. Debe mostrar pantalla de Login inicialmente
    expect(find.text('Café Aroma'), findsWidgets);
    expect(find.text('Acceso al Sistema y Menú Digital'), findsOneWidget);
    expect(find.text('Demo Cliente'), findsOneWidget);
    expect(find.text('Demo Admin'), findsOneWidget);

    // 2. Probar acceso como Cliente
    await state.login(const AppUser(
      id: 'c1',
      name: 'Cliente Demo',
      email: 'cliente@cafe.com',
      role: UserRole.customer,
    ));
    await tester.pumpWidget(CoffeeApp(state: state));
    await tester.pumpAndSettle();

    expect(find.text('¡Hola, Cliente Demo!'), findsOneWidget);
    expect(find.text('Categorías'), findsOneWidget);

    // 3. Probar acceso como Administrador
    await state.login(const AppUser(
      id: 'a1',
      name: 'Administrador Demo',
      email: 'admin@cafe.com',
      role: UserRole.admin,
    ));
    await tester.pumpWidget(CoffeeApp(state: state));
    await tester.pumpAndSettle();

    expect(find.text('Panel de Control'), findsOneWidget);
    expect(find.text('Centro de Control Café Aroma'), findsOneWidget);
    expect(find.text('Inventario'), findsOneWidget);
    expect(find.text('Pedidos'), findsOneWidget);
  });
}
