import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../state/coffee_shop_scope.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apaternoController = TextEditingController();
  final _amaternoController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nombreController.dispose();
    _apaternoController.dispose();
    _amaternoController.dispose();
    _usuarioController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usuarioController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await AuthService.registerClient(
        nombre: _nombreController.text.trim(),
        apaterno: _apaternoController.text.trim(),
        amaterno: _amaternoController.text.trim(),
        username: username,
        password: password,
      );

      // Auto-iniciar sesión con las credenciales registradas
      final user = await AuthService.authenticate(
        identifier: username,
        password: password,
      );

      if (!mounted) return;

      if (user != null) {
        final state = CoffeeShopScope.of(context);
        await state.login(user);

        if (!mounted) return;

        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        // Redirigir al login si no se pudo auto-autenticar
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint('Error en registro: $e');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (e.toString().contains('USUARIO_EXISTE')) {
          _errorMessage = 'Ese nombre de usuario ya está en uso.';
        } else {
          _errorMessage = 'No se pudo completar el registro. Intenta de nuevo.';
        }
      });
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
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo e Icono
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.espresso, AppTheme.primaryCoffee],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryCoffee.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: AppTheme.caramelLight,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Crear Cuenta',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Regístrate para pedir tu café favorito',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Tarjeta Formulario de Registro
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
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.statusDanger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.statusDanger.withValues(alpha: 0.3),
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
                            const SizedBox(height: 16),
                          ],

                          // Nombre
                          _buildFieldLabel('Nombre *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nombreController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              hint: 'Ej. Juan',
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Ingresa tu nombre';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Apellido Paterno y Materno en fila
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Apellido Paterno *'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _apaternoController,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: _inputDecoration(
                                        hint: 'Ej. Pérez',
                                        icon: Icons.badge_outlined,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Obligatorio';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFieldLabel('Apellido Materno'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _amaternoController,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: _inputDecoration(
                                        hint: 'Opcional',
                                        icon: Icons.badge_outlined,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Nombre de Usuario
                          _buildFieldLabel('Nombre de Usuario *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _usuarioController,
                            decoration: _inputDecoration(
                              hint: 'Ej. juanperez',
                              icon: Icons.alternate_email_rounded,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Ingresa un nombre de usuario';
                              }
                              if (val.trim().length < 3) {
                                return 'Mínimo 3 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Contraseña
                          _buildFieldLabel('Contraseña (mínimo 6 caracteres) *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration(
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
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
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Ingresa una contraseña';
                              }
                              if (val.trim().length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Confirmar Contraseña
                          _buildFieldLabel('Confirmar Contraseña *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: _inputDecoration(
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textLight,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Confirma tu contraseña';
                              }
                              if (val.trim() != _passwordController.text.trim()) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),

                          // Botón Registrarse
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
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
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'Crear Cuenta',
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

                  const SizedBox(height: 18),

                  // Enlace a Iniciar Sesión
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta?',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          color: AppTheme.textMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: Text(
                          'Iniciar sesión',
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.caramel,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.sora(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.textDark,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.caramel, size: 20),
      suffixIcon: suffixIcon,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.statusDanger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.statusDanger, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
    );
  }
}
