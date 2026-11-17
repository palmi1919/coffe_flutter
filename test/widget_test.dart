import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coffe/main.dart';
import 'package:coffe/services/local_storage_service.dart';
import 'package:coffe/state/coffee_shop_state.dart';

void main() {
  testWidgets('Carga inicial y renderizado de la pantalla principal de Café Aroma',
      (WidgetTester tester) async {
    // Inicializar mock de SharedPreferences para tests
    SharedPreferences.setMockInitialValues({});
    final storageService = await LocalStorageService.init();
    final state = CoffeeShopState(storageService);

    await tester.pumpWidget(CoffeeApp(state: state));
    await tester.pumpAndSettle();

    // Comprobar que el título de la cafetería se muestra en la AppBar
    expect(find.text('Café Aroma'), findsOneWidget);
    expect(find.text('Menú digital & especialidad'), findsOneWidget);

    // Comprobar categorías visibles
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('Categorías'), findsOneWidget);
  });
}
