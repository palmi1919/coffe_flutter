import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../state/coffee_shop_scope.dart';
import '../admin/admin_main_screen.dart';
import '../customer/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController(text: 'admin@cafe.com');
  final _passwordController = TextEditingController(text: 'admin123');

  UserRole _selectedRoleTab = UserRole.admin;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchRoleTab(UserRole role) {
    setState(() {
      _selectedRoleTab = role;
      _errorMessage = null;
      if (role == UserRole.admin) {
        _userController.text = AuthService.adminEmail;
        _passwordController.text = AuthService.adminPass;
      } else {
        _userController.text = AuthService.customerEmail;
        _passwordController.text = AuthService.customerPass;
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final user = AuthService.authenticate(
      identifier: _userController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (user != null) {
      final state = CoffeeShopScope.of(context);
      await state.login(user);

      if (!mounted) return;

      if (user.isAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminMainScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Credenciales incorrectas. Revisa tu usuario y contraseña.';
        _isLoading = false;
      });
    }
  }

  Future<void> _quickLogin(AppUser user) async {
    setState(() => _isLoading = true);
    final state = CoffeeShopScope.of(context);
    await state.login(user);

    if (!mounted) return;

    if (user.isAdmin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminMainScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo e Icono
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.espresso, AppTheme.primaryCoffee],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryCoffee.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.coffee_rounded,
                        color: AppTheme.caramelLight,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Café Aroma',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Acceso al Sistema y Menú Digital',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Selector de Rol (Administrador / Cliente)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _switchRoleTab(UserRole.admin),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRoleTab == UserRole.admin
                                    ? AppTheme.primaryCoffee
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _selectedRoleTab == UserRole.admin
                                    ? AppTheme.softShadow
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_rounded,
                                    size: 18,
                                    color: _selectedRoleTab == UserRole.admin
                                        ? Colors.white
                                        : AppTheme.textMedium,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Administrador',
                                    style: GoogleFonts.sora(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedRoleTab == UserRole.admin
                                          ? Colors.white
                                          : AppTheme.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _switchRoleTab(UserRole.customer),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRoleTab == UserRole.customer
                                    ? AppTheme.primaryCoffee
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _selectedRoleTab == UserRole.customer
                                    ? AppTheme.softShadow
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    size: 18,
                                    color: _selectedRoleTab == UserRole.customer
                                        ? Colors.white
                                        : AppTheme.textMedium,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Cliente',
                                    style: GoogleFonts.sora(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedRoleTab == UserRole.customer
                                          ? Colors.white
                                          : AppTheme.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tarjeta Formulario de Login
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderLight),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedRoleTab == UserRole.admin
                                ? 'Portal de Gestión y Administración'
                                : 'Pide tu Café Favorito',
                            style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedRoleTab == UserRole.admin
                                ? 'Control de catálogo, inventario y pedidos.'
                                : 'Elige tu bebida y la cantidad que desees.',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 18),

                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
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
                                    Icons.error_outline_rounded,
                                    color: AppTheme.statusDanger,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: GoogleFonts.sora(
                                        fontSize: 12,
                                        color: AppTheme.statusDanger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Campo Usuario / Email
                          Text(
                            'Usuario o Correo',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _userController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: _selectedRoleTab == UserRole.admin
                                  ? 'admin@cafe.com'
                                  : 'cliente@cafe.com',
                              prefixIcon: const Icon(
                                Icons.alternate_email_rounded,
                                color: AppTheme.caramel,
                                size: 20,
                              ),
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
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.caramel, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Ingresa tu usuario o correo';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          // Campo Contraseña
                          Text(
                            'Contraseña',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppTheme.caramel,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textLight,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
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
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.caramel, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Ingresa tu contraseña';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Botón Iniciar Sesión
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.caramel,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _selectedRoleTab == UserRole.admin
                                          ? 'Entrar como Administrador'
                                          : 'Entrar como Cliente',
                                      style: GoogleFonts.sora(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Accesos Rápidos para Evaluación y Pruebas
                  Text(
                    'ACCESOS RÁPIDOS DE PRUEBA (1-CLICK)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _quickLogin(AuthService.quickAdminUser),
                          icon: const Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 16,
                            color: AppTheme.primaryCoffee,
                          ),
                          label: Text(
                            'Demo Admin',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryCoffee,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryCoffee, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _quickLogin(AuthService.quickCustomerUser),
                          icon: const Icon(
                            Icons.local_cafe_rounded,
                            size: 16,
                            color: AppTheme.caramel,
                          ),
                          label: Text(
                            'Demo Cliente',
                            style: GoogleFonts.sora(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.caramel,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.caramel, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCream,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Admin: admin / admin123  •  Cliente: cliente / cliente123',
                        style: GoogleFonts.sora(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
