import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';
import '../auth/auth_service.dart';
import '../service_locator.dart';
import '../../models/appointment.dart';
import '../../models/api_response.dart';

class ServiceCitas extends BaseService {
  AuthService get _authService => serviceLocator.get<AuthService>();

  Future<List<Appointment>> listarCitas(String rol) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Sesión no válida');

    String endpoint;
    if (rol == 'doctor') {
      endpoint = '/doctor-appointments';
    } else if (rol == 'patient') {
      endpoint = '/patient-appointments';
    } else {
      throw Exception('Rol no soportado');
    }

    final url = Uri.parse('${BaseService.baseUrl}$endpoint');

    final response = await http.get(url, headers: headersWithAuth(token));
    final data = jsonDecode(response.body);

    if (data is Map && data['data'] is Map) {
      final paginatedData = data['data'] as Map<String, dynamic>;
      if (paginatedData.containsKey('data') && paginatedData['data'] is List) {
        // Caso paginación
        final citasList = paginatedData['data'] as List;
        return citasList
            .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (paginatedData is List) {
        // Caso lista simple en data
        final citasList = paginatedData as List;
        return citasList
            .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        throw Exception('Datos de citas inesperados');
      }
    } else if (data is Map && data['data'] is List) {
      // Caso donde 'data' es lista directa (no paginada)
      final citasList = data['data'] as List;
      return citasList
          .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception('Respuesta inválida al listar citas');
    }
  }

  Future<ApiResponse<void>> completarCita(int appointmentId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse(
      '${BaseService.baseUrl}/doctor-appointments/$appointmentId/complete',
    );

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({}), // o null si el backend acepta sin body
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    return handleResponse(
      response,
      (data) => ApiResponse<void>(
        success: true,
        data: null,
        message: data['message'] ?? 'Cita completada exitosamente',
      ),
    );
  }

  Future<ApiResponse<void>> cancelarCita(int appointmentId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse(
      '${BaseService.baseUrl}/patient-appointments/$appointmentId',
    );

    print('[ServiceCitas] Cancelando cita $appointmentId desde: $url');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({}),
      );

      print('[ServiceCitas] Status cancelación: ${response.statusCode}');
      print('[ServiceCitas] Response: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Error ${response.statusCode}: ${errorBody['message'] ?? response.body}',
        );
      }

      final data = jsonDecode(response.body);
      return ApiResponse<void>(
        success: true,
        data: null,
        message: data['message'] ?? 'Cita cancelada exitosamente',
      );
    } catch (e) {
      print('[ServiceCitas] ERROR en cancelación: $e');
      rethrow;
    }
  }

  /// Obtiene el historial de citas del paciente autenticado.
  Future<List<Appointment>> obtenerHistorialMedico() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Sesión no válida');

    final url = Uri.parse('${BaseService.baseUrl}/patient-appointments');

    print('[ServiceCitas] Solicitando historial desde: $url');

    try {
      final response = await http
          .get(url, headers: headersWithAuth(token))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Timeout obteniendo historial'),
          );

      print('[ServiceCitas] Status: ${response.statusCode}');
      print('[ServiceCitas] Content-Type: ${response.headers['content-type']}');
      final bodyPreview =
          response.body.length > 500
              ? response.body.substring(0, 500)
              : response.body;
      print('[ServiceCitas] Body preview: $bodyPreview');

      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }

      final decodedData = jsonDecode(response.body) as Map<String, dynamic>;
      print('[ServiceCitas] Decodificado exitosamente');
      print('[ServiceCitas] Top-level keys: ${decodedData.keys.toList()}');

      // El backend envía: { "message": "...", "data": { "data": [...], ...paginate info } }
      final dataWrapper = decodedData['data'];
      if (dataWrapper == null) {
        throw Exception('No existe clave "data" en respuesta');
      }

      print('[ServiceCitas] Tipo de dataWrapper: ${dataWrapper.runtimeType}');

      List<dynamic> citasRaw = [];

      if (dataWrapper is Map<String, dynamic>) {
        // Es paginación Laravel: { "data": [...], "total": 10, ...}
        citasRaw = (dataWrapper['data'] ?? []) as List<dynamic>;
        print(
          '[ServiceCitas] Estructura paginada. Citas raw: ${citasRaw.length}',
        );
      } else if (dataWrapper is List<dynamic>) {
        // Es un array directo
        citasRaw = dataWrapper;
        print(
          '[ServiceCitas] Estructura de array. Citas raw: ${citasRaw.length}',
        );
      } else {
        throw Exception(
          'dataWrapper tiene tipo inesperado: ${dataWrapper.runtimeType}',
        );
      }

      // Convertir cada item a Appointment
      final appointments = <Appointment>[];
      for (int i = 0; i < citasRaw.length; i++) {
        try {
          final citaJson = citasRaw[i] as Map<String, dynamic>;
          final appointment = Appointment.fromJson(citaJson);
          appointments.add(appointment);
          print('[ServiceCitas] Cita $i parseada: id=${appointment.id}');
        } catch (e) {
          print('[ServiceCitas] Error parseando cita $i: $e');
          print('[ServiceCitas] JSON raw: ${citasRaw[i]}');
          // No relanzar, continuar con las demás
        }
      }

      // Filtrar solo las completadas
      final completadas =
          appointments.where((apt) {
            final isCompleted = apt.status?.toLowerCase() == 'completado';
            print(
              '[ServiceCitas] Cita id=${apt.id} status=${apt.status} - completada=$isCompleted',
            );
            return isCompleted;
          }).toList();

      print(
        '[ServiceCitas] Total citas parseadas: ${appointments.length}, completadas: ${completadas.length}',
      );
      return completadas;
    } catch (e, stacktrace) {
      print('[ServiceCitas] EXCEPCION: $e');
      print('[ServiceCitas] Stack: $stacktrace');
      rethrow;
    }
  }
}
