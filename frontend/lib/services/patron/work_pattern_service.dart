import 'dart:convert';
import 'package:frontend/models/api_response.dart';
import 'package:frontend/models/doctor_work_pattern.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/base_service.dart';
import 'package:http/http.dart' as http;

class WorkPatternService {
  final AuthService _authService;

  WorkPatternService(this._authService);

  Map<String, String> headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<ApiResponse<List<DoctorWorkPattern>>> listarPatrones() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${BaseService.baseUrl}/work-patterns');
    final response = await http.get(url, headers: headersWithAuth(token));
    final jsonData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return ApiResponse(
        success: false,
        message: jsonData['message'] ?? 'Error al obtener patrones',
      );
    }

    final data =
        (jsonData['data'] as List)
            .map((e) => DoctorWorkPattern.fromJson(e))
            .toList();

    return ApiResponse(
      success: true,
      data: data,
      message: jsonData['message'] ?? 'Patrones obtenidos',
    );
  }

  Future<ApiResponse<DoctorWorkPattern>> crearPatron(
    DoctorWorkPattern patron,
  ) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${BaseService.baseUrl}/work-patterns');
    final response = await http.post(
      url,
      headers: headersWithAuth(token),
      body: json.encode(patron.toJson()),
    );

    final jsonData = jsonDecode(response.body);

    if (response.statusCode != 201) {
      return ApiResponse(
        success: false,
        message: jsonData['message'] ?? 'Error al crear patrón',
      );
    }

    final data = DoctorWorkPattern.fromJson(jsonData['data']);

    return ApiResponse(
      success: true,
      data: data,
      message: jsonData['message'] ?? 'Patrón creado exitosamente',
    );
  }

  Future<ApiResponse<DoctorWorkPattern>> obtenerDetalle(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('${BaseService.baseUrl}/work-patterns/$id');
    final response = await http.get(url, headers: headersWithAuth(token));
    final jsonData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return ApiResponse(
        success: false,
        message: jsonData['message'] ?? 'Error al obtener detalle',
      );
    }

    final data = DoctorWorkPattern.fromJson(jsonData['data']);

    return ApiResponse(
      success: true,
      data: data,
      message: jsonData['message'] ?? 'Detalle obtenido',
    );
  }

  Future<ApiResponse<DoctorWorkPattern>> desactivarPatron(int id) async {
    try {
      final token = await _authService.getToken();

      if (token == null) throw Exception('Token no disponible');

      final url = Uri.parse('${BaseService.baseUrl}/work-patterns/$id');

      final headers = headersWithAuth(token);

      final response = await http.put(url, headers: headers);

      final jsonData = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return ApiResponse(
          success: false,
          message: jsonData['message'] ?? 'Error al desactivar patrón',
        );
      }

      final data = DoctorWorkPattern.fromJson(jsonData['data']);

      return ApiResponse(
        success: true,
        data: data,
        message: jsonData['message'] ?? 'Patrón desactivado correctamente',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error inesperado al desactivar patrón: $e',
      );
    }
  }

  Future<ApiResponse<void>> generarHorarios(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token no disponible');

      final url = Uri.parse(
        '${BaseService.baseUrl}/doctor-available-schedules/generate',
      );

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      });

      final response = await http.post(url, headers: headers, body: body);

      final jsonData = jsonDecode(response.body);

      // Accept both 200 and 201 status codes
      if (response.statusCode != 200 && response.statusCode != 201) {
        return ApiResponse(
          success: false,
          message: jsonData['message'] ?? 'Error al generar horarios',
        );
      }

      return ApiResponse(
        success: true,
        message: jsonData['message'] ?? 'Horarios generados exitosamente',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error inesperado al generar horarios: $e',
      );
    }
  }
}
