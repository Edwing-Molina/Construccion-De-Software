import 'package:flutter/material.dart';
import '../../../widgets/widgets.dart';

class RegisterFormFields {
  static Widget nameField(TextEditingController controller) {
    return CustomTextField(
      controller: controller,
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

  static Widget emailField(TextEditingController controller) {
    return CustomTextField(
      controller: controller,
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

  static Widget phoneField(TextEditingController controller) {
    return CustomTextField(
      controller: controller,
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

  static Widget cedulaField(TextEditingController controller) {
    return CustomTextField(
      controller: controller,
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

  static Widget clinicaField(TextEditingController controller) {
    return CustomTextField(
      controller: controller,
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

  static Widget passwordField(
    TextEditingController controller,
    bool obscurePassword,
    Function(bool) onToggle,
  ) {
    return CustomTextField(
      controller: controller,
      hintText: 'Ingresa tu contraseña',
      icon: Icons.lock_outline,
      obscureText: obscurePassword,
      suffixIcon: GestureDetector(
        onTap: () => onToggle(!obscurePassword),
        child: Icon(
          obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Colors.grey,
        ),
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

  static Widget confirmPasswordField(
    TextEditingController controller,
    TextEditingController passwordController,
    bool obscureConfirmPassword,
    Function(bool) onToggle,
  ) {
    return CustomTextField(
      controller: controller,
      hintText: 'Confirma tu contraseña',
      icon: Icons.lock_outline,
      obscureText: obscureConfirmPassword,
      suffixIcon: GestureDetector(
        onTap: () => onToggle(!obscureConfirmPassword),
        child: Icon(
          obscureConfirmPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Colors.grey,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor confirma tu contraseña';
        }
        if (value != passwordController.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
    );
  }
}
