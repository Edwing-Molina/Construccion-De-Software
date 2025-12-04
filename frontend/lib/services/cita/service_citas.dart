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

    List<Appointment> citasList = [];

    if (data is Map && data['data'] is Map) {
      final paginatedData = data['data'] as Map<String, dynamic>;
      if (paginatedData.containsKey('data') && paginatedData['data'] is List) {
        final rawList = paginatedData['data'] as List;
        citasList =
            rawList
                .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
                .toList();
      } else if (paginatedData is List) {
        final rawList = paginatedData as List;
        citasList =
            rawList
                .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
                .toList();
      } else {
        throw Exception('Datos de citas inesperados');
      }
    } else if (data is Map && data['data'] is List) {
      final rawList = data['data'] as List;
      citasList =
          rawList
              .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
              .toList();
    } else {
      throw Exception('Respuesta inválida al listar citas');
    }

    // Filtrar citas que no estén pasadas (solo hoy en adelante)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered =
        citasList.where((cita) {
          final scheduleDate = cita.availableSchedule?.date;

          if (scheduleDate == null) {
            return true;
          }

          final scheduleDateOnly = DateTime(
            scheduleDate.year,
            scheduleDate.month,
            scheduleDate.day,
          );

          return scheduleDateOnly.isAfter(today) ||
              scheduleDateOnly.isAtSameMomentAs(today);
        }).toList();

    return filtered;
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
      '${BaseService.baseUrl}/patient-appointments/$appointmentId', // Ajusta la ruta si es diferente
    );

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({}), // O null si el backend acepta sin body
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    return handleResponse(
      response,
      (data) => ApiResponse<void>(
        success: true,
        data: null,
        message: data['message'] ?? 'Cita cancelada exitosamente',
      ),
    );
  }

  /// Obtiene el historial de citas del paciente autenticado.
  ///
  /// Nota: asume que el endpoint para historial es
  /// `/patient-appointments/history`. Si el backend usa otra ruta,
  /// reemplazarla por la correspondiente.
  Future<List<Appointment>> obtenerHistorialMedico() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Sesión no válida');

    final url = Uri.parse('${BaseService.baseUrl}/patient-appointments');

    final response = await http.get(url, headers: headersWithAuth(token));
    final data = jsonDecode(response.body);

    if (data is Map && data['data'] is Map) {
      final paginatedData = data['data'] as Map<String, dynamic>;
      if (paginatedData.containsKey('data') && paginatedData['data'] is List) {
        final citasList = paginatedData['data'] as List;
        return citasList
            .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (paginatedData is List) {
        final citasList = paginatedData as List;
        return citasList
            .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        throw Exception('Datos de historial inesperados');
      }
    } else if (data is Map && data['data'] is List) {
      final citasList = data['data'] as List;
      return citasList
          .map((e) => Appointment.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception('Respuesta inválida al obtener historial');
    }
  }
}
