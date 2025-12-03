import 'package:flutter/foundation.dart' show kIsWeb;

class AppEnvironment {
  static const bool useMockServices =
      false; // Cambiar a false para usar servicios reales
  // Si se quiere usar servicios mock para pruebas, cambiar a true
  static const bool debugNetworking = true;

  static const String mockEmail = 'test@example.com';
  static const String mockPassword = 'password';

  // Helper para detectar plataforma
  static bool get isWeb => kIsWeb;

  static void printDebug(String message) {
    if (debugNetworking) {
      print('[DEBUG] $message');
    }
  }
}
