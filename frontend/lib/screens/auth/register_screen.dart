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

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 40,
        vertical: 5,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
          _buildRoleSelector(),
          SizedBox(height: fieldSpacing),
          _buildNameField(),
          SizedBox(height: fieldSpacing),
          _buildEmailField(),
          SizedBox(height: fieldSpacing),
          _buildPhoneField(),
          SizedBox(height: fieldSpacing),
          if (_selectedRole == 'doctor') ...[
            _buildCedulaField(),
            SizedBox(height: fieldSpacing),
            _buildClinicaField(),
            SizedBox(height: fieldSpacing),
          ],
          _buildPasswordField(),
          SizedBox(height: fieldSpacing),
          _buildConfirmPasswordField(),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildRegisterButton(),
          SizedBox(height: isSmallScreen ? 10 : 12),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registrarse como:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleButton(
                label: 'Paciente',
                value: 'patient',
                isSelected: _selectedRole == 'patient',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleButton(
                label: 'Doctor',
                value: 'doctor',
                isSelected: _selectedRole == 'doctor',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleButton({
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.uadyBlue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.uadyBlue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.darkGray,
            ),
          ),
        ),
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

  Widget _buildCedulaField() {
    return CustomTextField(
      controller: _cedulaController,
      hintText: 'Cédula profesional (ej: a123456)',
      icon: Icons.card_giftcard_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu cédula profesional';
        }
        if (!value.toLowerCase().startsWith('a')) {
          return 'La cédula debe comenzar con la letra "a"';
        }
        return null;
      },
    );
  }

  Widget _buildClinicaField() {
    return CustomTextField(
      controller: _clinicaController,
      hintText: 'Nombre de la clínica',
      icon: Icons.local_hospital_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa el nombre de la clínica';
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
