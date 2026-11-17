import 'package:flutter/material.dart';
import 'coffee_shop_state.dart';

class CoffeeShopScope extends InheritedNotifier<CoffeeShopState> {
  const CoffeeShopScope({
    super.key,
    required CoffeeShopState state,
    required super.child,
  }) : super(notifier: state);

  static CoffeeShopState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<CoffeeShopScope>();
    assert(scope != null, 'No se encontró CoffeeShopScope en el árbol de widgets.');
    return scope!.notifier!;
  }
}
