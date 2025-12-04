import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String environment = 'development';

  // URLs para diferentes plataformas
  static const Map<String, Map<String, String>> platformUrls = {
    'development': {
      // Para desarrollo web (Flutter web)
      'web': 'http://10.1.134.251:8000/api',
      // Para desarrollo móvil (Android/iOS) - mismo dominio local
      'mobile': 'http://10.1.134.251:8000/api',
    },
    'production': {
      'web': 'https://servidor-produccion.com/api',
      'mobile': 'https://servidor-produccion.com/public/api',
    },
  };

  static String get baseUrl {
    final envUrls = platformUrls[environment]!;

    if (kIsWeb) {
      return envUrls['web']!;
    } else {
      return envUrls['mobile']!;
    }
  }

  static const bool debugMode = true;
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}

//192.168.1.254/sistema-citas-medicas/Backend/public o public.test 192.168.1.233
//http://192.168.1.177/sistema-citas-mesdicas/Backend/public/api
