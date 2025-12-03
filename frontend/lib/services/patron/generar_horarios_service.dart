import 'dart:convert';
import 'package:frontend/models/api_response.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/base_service.dart';
import 'package:http/http.dart' as http;

class GenerateHorariosService extends BaseService {
  final AuthService _authService = AuthService();

  Future<ApiResponse<void>> generarHorarios(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse(
      '${BaseService.baseUrl}/available-schedules/generate',
    );

    final body = {
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
    };

    final response = await http.post(
      url,
      headers: headersWithAuth(token),
      body: json.encode(body),
    );

    final jsonData = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return ApiResponse(
        success: false,
        message: jsonData['message'] ?? 'Error al generar horarios',
      );
    }

    return ApiResponse(
      success: true,
      message: jsonData['message'] ?? 'Horarios generados exitosamente',
    );
  }
}
