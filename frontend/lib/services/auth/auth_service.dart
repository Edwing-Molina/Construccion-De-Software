import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../base_service.dart';
import '../app_environment.dart';
import '../service_locator.dart';
import '../profile/profile_service.dart';
import '../../models/models.dart';

class AuthService extends BaseService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';

  Future<User> login(String email, String password) async {
    try {
      final url = '${BaseService.baseUrl}/mobile/login';
      AppEnvironment.printDebug('=== LOGIN ATTEMPT ===');
      AppEnvironment.printDebug('Full URL: $url');
      AppEnvironment.printDebug('Base URL: ${BaseService.baseUrl}');
      AppEnvironment.printDebug('Email: $email');
      AppEnvironment.printDebug(
        'Platform: ${AppEnvironment.isWeb ? "Web" : "Mobile"}',
      );

      final body = json.encode({
        'email': email,
        'password': password,
        'device_name': 'mobile_app',
      });

      AppEnvironment.printDebug('Request body: $body');

      final response = await http
          .post(Uri.parse(url), headers: headers, body: body)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Tiempo de espera agotado. Verifica tu conexión a internet.',
              );
            },
          );

      AppEnvironment.printDebug('Response status: ${response.statusCode}');
      AppEnvironment.printDebug('Response body: ${response.body}');

      final apiResponse = handleResponse<Map<String, dynamic>>(
        response,
        (data) => data,
      );

      // Verificar si la respuesta contiene los datos del usuario
      User? user;
      if (apiResponse.containsKey('user')) {
        user = User.fromJson(apiResponse['user']);
      } else {
        user = User(id: 0, name: 'Usuario', email: email);
      }

      final token = apiResponse['token'];
      final role = apiResponse['role'];

      await _saveAuthData(token, user, role);

      return user;
    } catch (e) {
      AppEnvironment.printDebug('Error detallado en login: $e');

      // Manejo específico de errores
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(
          'No se puede conectar al servidor. Verifica que Laragon esté ejecutándose y el dominio "sistema-citas-medicas.test" esté configurado.',
        );
      } else if (e.toString().contains('Tiempo de espera')) {
        throw Exception(
          'Tiempo de espera agotado. El servidor está tardando demasiado en responder.',
        );
      } else if (e.toString().contains('No autorizado') ||
          e.toString().contains('401')) {
        throw Exception('Email o contraseña incorrectos');
      } else if (e.toString().contains('400')) {
        throw Exception('Datos de login inválidos');
      } else if (e.toString().contains('500')) {
        throw Exception(
          'Error en el servidor. Verifica la configuración del backend.',
        );
      } else {
        throw Exception('Error al iniciar sesión: ${e.toString()}');
      }
    }
  }

  Future<User> register({
    required String nombre,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? telefono,
    String? cedula,
    String? role,
    String? clinica,
  }) async {
    try {
      final url = '${BaseService.baseUrl}/register';

      AppEnvironment.printDebug('=== REGISTER ATTEMPT ===');
      AppEnvironment.printDebug('Full URL: $url');
      AppEnvironment.printDebug('Base URL: ${BaseService.baseUrl}');
      AppEnvironment.printDebug('Email: $email');
      AppEnvironment.printDebug('Name: $nombre');
      AppEnvironment.printDebug('Role: $role');

      final body = {
        'name': nombre,
        'phone': telefono,
        'email': email,
        'password': password,
        "password_confirmation": passwordConfirmation,
        if (role != null) 'role': role,
        if (cedula != null) 'cedula': cedula,
        if (clinica != null) 'clinica': clinica,
      };

      final jsonBody = json.encode(body);
      AppEnvironment.printDebug('Request body: $jsonBody');
      AppEnvironment.printDebug('Headers: $headers');

      final response = await http
          .post(Uri.parse(url), headers: headers, body: jsonBody)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Tiempo de espera agotado. Verifica tu conexión a internet.',
              );
            },
          );

      AppEnvironment.printDebug('Response status: ${response.statusCode}');
      AppEnvironment.printDebug('Response body: ${response.body}');

      final apiResponse = handleResponse<Map<String, dynamic>>(
        response,
        (data) => data,
      );

      final user = User.fromJson(apiResponse['user']);
      final token = apiResponse['token'];
      final userRole = apiResponse['role'];

      await _saveAuthData(token, user, userRole);

      return user;
    } catch (e) {
      AppEnvironment.printDebug('Error detallado en registro: $e');

      // Manejo específico de errores
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(
          'No se puede conectar al servidor. Verifica que Laragon esté ejecutándose.',
        );
      } else if (e.toString().contains('Tiempo de espera')) {
        throw Exception(
          'Tiempo de espera agotado. El servidor está tardando demasiado en responder.',
        );
      } else if (e.toString().contains('400') ||
          e.toString().contains('validation')) {
        throw Exception(
          'Datos de registro inválidos o incompletos. ${e.toString()}',
        );
      } else if (e.toString().contains('409') ||
          e.toString().contains('already')) {
        throw Exception('El email ya está registrado');
      } else if (e.toString().contains('500')) {
        throw Exception(
          'Error en el servidor. Verifica la configuración del backend.',
        );
      } else {
        throw Exception('Error al registrar usuario: ${e.toString()}');
      }
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${BaseService.baseUrl}/logout'),
          headers: headersWithAuth(token),
        );
      }
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    } finally {
      await _clearAuthData();
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  /// Obtiene la información del usuario desde el endpoint /me usando ProfileService
  Future<User?> fetchUserFromApi() async {
    try {
      final profileService = serviceLocator.get<ProfileService>();

      AppEnvironment.printDebug(
        'Fetching user info from /me endpoint via ProfileService',
      );

      final profileResponse = await profileService.getProfile();

      if (profileResponse.success && profileResponse.data != null) {
        final user = profileResponse.data!;

        // Actualizar la información del usuario en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(user.toJson()));

        AppEnvironment.printDebug('User info updated: ${user.name}');
        return user;
      } else {
        throw Exception(
          'Error al obtener información del usuario desde ProfileService',
        );
      }
    } catch (e) {
      AppEnvironment.printDebug('Error fetching user from API: $e');

      // Si es error de autenticación, limpiar datos
      if (e.toString().contains('No hay token de autenticación') ||
          e.toString().contains('401')) {
        await _clearAuthData();
        throw Exception(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      }

      rethrow;
    }
  }

  Future<User?> getCurrentUser({bool forceRefresh = false}) async {
    if (forceRefresh) {
      return await fetchUserFromApi();
    }

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        return User.fromJson(json.decode(userJson));
      } catch (e) {
        AppEnvironment.printDebug('Error parsing cached user data: $e');
      }
    }
    return await fetchUserFromApi();
  }

  Future<void> saveAuthData(String token, User user, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setString(_roleKey, role);
  }

  Future<void> _saveAuthData(String token, User user, String role) async {
    await saveAuthData(token, user, role);
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_roleKey);
  }
}
