import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/services.dart';
import '../../services/app_environment.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/logo_section.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class ScreenLogin extends StatefulWidget {
  const ScreenLogin({super.key});

  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = serviceLocator.authService;
      await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error al iniciar sesión';

        if (e.toString().contains('Tiempo de espera agotado')) {
          errorMessage =
              'Tiempo de espera agotado. Verifica tu conexión a internet.';
        } else if (e.toString().contains('No autorizado')) {
          errorMessage = 'Email o contraseña incorrectos';
        } else if (e.toString().contains('conexión')) {
          errorMessage = 'Error de conexión. Verifica tu internet.';
        } else {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  // Logo responsivo
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: const LogoSection(),
                  ),
                  // Mock service indicator (solo en debug)
                  if (AppEnvironment.useMockServices) _buildMockIndicator(),
                  // Form container responsive - removido Expanded
                  _buildFormContainer(),
                  // Spacer para empujar el contenido hacia arriba
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 40,
        vertical: 5,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormTitle(),
          SizedBox(
            height: isSmallScreen ? 10 : 15,
          ), // Reducido de 15/25 a 10/15
          _buildLoginForm(),
        ],
      ),
    );
  }

  Widget _buildFormTitle() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Text(
      'Iniciar Sesión',
      style: TextStyle(
        fontSize: isSmallScreen ? 20 : 24,
        fontWeight: FontWeight.w600,
        color: AppColors.uadyBlue,
      ),
    );
  }

  Widget _buildLoginForm() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final fieldSpacing = isSmallScreen ? 16.0 : 20.0;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(),
          SizedBox(height: fieldSpacing),
          _buildPasswordField(),
          SizedBox(height: fieldSpacing * 0.7),
          _buildForgotPasswordLink(),
          SizedBox(height: isSmallScreen ? 10 : 15),
          _buildLoginButton(),
          SizedBox(height: isSmallScreen ? 10 : 15),
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      hintText: 'Correo Electrónico',
      icon: Icons.email_outlined,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu correo electrónico';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Por favor ingresa un correo válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      hintText: 'Contraseña',
      icon: Icons.lock_outline,
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.iconGray,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Solo con fines demostrativos, no implementa la funcionalidad
        },
        child: const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: AppColors.uadyBlue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return CustomButton(
      text: 'Ingresar',
      onPressed: _login,
      isLoading: _isLoading,
    );
  }

  Widget _buildRegisterLink() {
    return RichText(
      text: TextSpan(
        text: '¿No tienes cuenta? ',
        style: const TextStyle(color: AppColors.darkGray, fontSize: 15),
        children: [
          WidgetSpan(
            child: GestureDetector(
              onTap: () => context.go('/register'),
              child: const Text(
                'Regístrate aquí',
                style: TextStyle(
                  color: AppColors.uadyBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'MODO TESTING: Usa ${AppEnvironment.mockEmail} / ${AppEnvironment.mockPassword}',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
