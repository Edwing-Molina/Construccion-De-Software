import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/services.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/widgets.dart';

class ScreenRegistro extends StatefulWidget {
  const ScreenRegistro({super.key});

  @override
  State<ScreenRegistro> createState() => _ScreenRegistroState();
}

class _ScreenRegistroState extends State<ScreenRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cedulaController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = serviceLocator.authService;
      await authService.register(
        nombre: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        telefono:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        cedula:
            _cedulaController.text.trim().isEmpty
                ? null
                : _cedulaController.text.trim(),
      );

      if (mounted) {
        context.go('/complete-profile');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al registrarse: $message'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: const LogoSection(),
                  ),
                  // Form container responsive
                  Expanded(child: _buildFormContainer()),
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
      padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
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
          SizedBox(height: isSmallScreen ? 20 : 30),
          _buildRegisterForm(),
        ],
      ),
    );
  }

  Widget _buildFormTitle() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Text(
      'Crear Cuenta',
      style: TextStyle(
        fontSize: isSmallScreen ? 20 : 24,
        fontWeight: FontWeight.w600,
        color: AppColors.uadyBlue,
      ),
    );
  }

  Widget _buildRegisterForm() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final fieldSpacing = isSmallScreen ? 16.0 : 20.0;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildNameField(),
          SizedBox(height: fieldSpacing),
          _buildEmailField(),
          SizedBox(height: fieldSpacing),
          _buildPhoneField(),
          SizedBox(height: fieldSpacing),
          _buildPasswordField(),
          SizedBox(height: fieldSpacing),
          _buildConfirmPasswordField(),
          SizedBox(height: isSmallScreen ? 20 : 30),
          _buildRegisterButton(),
          SizedBox(height: isSmallScreen ? 15 : 20),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return CustomTextField(
      controller: _nameController,
      hintText: 'Ingresa tu nombre completo',
      icon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu nombre completo';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      hintText: 'ejemplo@correo.com',
      icon: Icons.email_outlined,
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

  Widget _buildPhoneField() {
    return CustomTextField(
      controller: _phoneController,
      hintText: 'Ingresa tu número de teléfono',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu número de teléfono';
        }
        if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
          return 'Por favor ingresa un número válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      controller: _passwordController,
      hintText: 'Ingresa tu contraseña',
      icon: Icons.lock_outline,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.darkGray,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return CustomTextField(
      controller: _confirmPasswordController,
      hintText: 'Confirma tu contraseña',
      icon: Icons.lock_outline,
      obscureText: _obscureConfirmPassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.darkGray,
        ),
        onPressed: () {
          setState(() {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor confirma tu contraseña';
        }
        if (value != _passwordController.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return CustomButton(
      text: 'Crear Cuenta',
      onPressed: _isLoading ? null : _register,
      isLoading: _isLoading,
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¿Ya tienes cuenta? ',
          style: TextStyle(color: AppColors.darkGray),
        ),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text(
            'Iniciar sesión',
            style: TextStyle(
              color: AppColors.uadyBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
