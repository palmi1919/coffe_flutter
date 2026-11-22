import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../state/coffee_shop_scope.dart';

class CoffeeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showCart;
  final bool showAdmin;
  final bool showLogout;
  final VoidCallback? onCartPressed;
  final VoidCallback? onAdminPressed;
  final VoidCallback? onLogoutPressed;
  final Widget? leading;

  const CoffeeAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showCart = true,
    this.showAdmin = false,
    this.showLogout = true,
    this.onCartPressed,
    this.onAdminPressed,
    this.onLogoutPressed,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final state = CoffeeShopScope.of(context);
    final cartCount = state.totalCartItemCount;

    return AppBar(
      toolbarHeight: 70,
      elevation: 0,
      backgroundColor: AppTheme.backgroundLight,
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.coffee_rounded,
                color: AppTheme.caramel,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: GoogleFonts.sora(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (showAdmin && state.isAdmin)
          IconButton(
            tooltip: 'Panel de Administración',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                color: AppTheme.primaryCoffee,
                size: 20,
              ),
            ),
            onPressed: onAdminPressed,
          ),
        if (showCart)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Mi Carrito / Pedido',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppTheme.primaryCoffee,
                      size: 20,
                    ),
                  ),
                  onPressed: onCartPressed,
                ),
                if (cartCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppTheme.caramel,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          cartCount > 99 ? '99+' : '$cartCount',
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (showLogout)
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: IconButton(
              tooltip: 'Cerrar sesión',
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.statusDanger,
                  size: 19,
                ),
              ),
              onPressed: onLogoutPressed,
            ),
          ),
      ],
    );
  }
}
