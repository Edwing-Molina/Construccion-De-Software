import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/services.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/widgets.dart';
import 'widgets/index.dart';

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
  final _clinicaController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'patient'; // 'patient' o 'doctor'

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _cedulaController.dispose();
    _clinicaController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Validaciones específicas para doctores
    if (_selectedRole == 'doctor') {
      if (!_cedulaController.text.trim().startsWith('a')) {
        _showErrorSnackBar('La cédula debe comenzar con la letra "a"');
        return;
      }
      if (_clinicaController.text.trim().isEmpty) {
        _showErrorSnackBar('Por favor ingresa el nombre de la clínica');
        return;
      }
    }

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
        role: _selectedRole,
        clinica:
            _selectedRole == 'doctor' ? _clinicaController.text.trim() : null,
      );

      if (mounted) {
        if (_selectedRole == 'doctor') {
          context.go('/complete-doctor-profile');
        } else {
          context.go('/complete-profile');
        }
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
          child: Stack(
            children: [
              // Logo fijo en la parte superior
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.20,
                child: const LogoSection(),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.20,
                left: 0,
                right: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      _buildFormContainer(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return RegisterFormContainerWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormTitle(),
          SizedBox(height: isSmallScreen ? 12 : 16),
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
    final fieldSpacing = isSmallScreen ? 10.0 : 12.0;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          RoleSelectorWidget(
            selectedRole: _selectedRole,
            onRoleChanged: (role) => setState(() => _selectedRole = role),
          ),
          SizedBox(height: fieldSpacing),
          RegisterFormFields.nameField(_nameController),
          SizedBox(height: fieldSpacing),
          RegisterFormFields.emailField(_emailController),
          SizedBox(height: fieldSpacing),
          RegisterFormFields.phoneField(_phoneController),
          SizedBox(height: fieldSpacing),
          if (_selectedRole == 'doctor') ...[
            RegisterFormFields.cedulaField(_cedulaController),
            SizedBox(height: fieldSpacing),
            RegisterFormFields.clinicaField(_clinicaController),
            SizedBox(height: fieldSpacing),
          ],
          RegisterFormFields.passwordField(
            _passwordController,
            _obscurePassword,
            (value) => setState(() => _obscurePassword = value),
          ),
          SizedBox(height: fieldSpacing),
          RegisterFormFields.confirmPasswordField(
            _confirmPasswordController,
            _passwordController,
            _obscureConfirmPassword,
            (value) => setState(() => _obscureConfirmPassword = value),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildRegisterButton(),
          SizedBox(height: isSmallScreen ? 10 : 12),
          _buildLoginLink(),
        ],
      ),
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
