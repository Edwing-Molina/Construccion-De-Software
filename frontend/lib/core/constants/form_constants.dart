class FormConstants {
  // Opciones de género
  static const List<String> genderOptions = [
    'masculino',
    'femenino',
    'prefiero no decirlo',
  ];

  // Opciones de tipo de sangre
  static const List<String> bloodTypeOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // Mensajes de validación
  static const String requiredFieldMessage = 'Este campo es obligatorio';
  static const String birthDateRequiredMessage =
      'La fecha de nacimiento es obligatoria';
  static const String genderRequiredMessage = 'El género es obligatorio';
  static const String bloodTypeRequiredMessage =
      'El tipo de sangre es obligatorio';
  static const String emergencyContactNameRequiredMessage =
      'El nombre del contacto de emergencia es obligatorio';
  static const String emergencyContactPhoneRequiredMessage =
      'El teléfono del contacto de emergencia es obligatorio';
  static const String nssRequiredMessage = 'El número de NSS es obligatorio';
  static const String invalidPhoneMessage = 'Ingresa un número válido';

  // Placeholders
  static const String birthDatePlaceholder = 'Fecha de nacimiento';
  static const String genderPlaceholder = 'Género';
  static const String bloodTypePlaceholder = 'Tipo de sangre';
  static const String emergencyContactNamePlaceholder =
      'Nombre del contacto de emergencia';
  static const String emergencyContactPhonePlaceholder =
      'Teléfono del contacto de emergencia';
  static const String nssPlaceholder = 'Número de Seguridad Social (NSS)';

  // Botones
  static const String continueButtonText = 'Continuar';
  static const String skipButtonText = 'Completar después';

  // Títulos
  static const String screenTitle = 'Completa tu Perfil';
  static const String screenSubtitle =
      'Para brindarte un mejor servicio, necesitamos algunos datos adicionales';

  // Validación de teléfono
  static const int minPhoneLength = 10;
}
