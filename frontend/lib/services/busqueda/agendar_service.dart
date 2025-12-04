import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/services/base_service.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/service_locator.dart';
import 'package:frontend/models/appointment.dart';
import 'package:frontend/models/available_schedule.dart';

class AgendarService extends BaseService {
  final AuthService _authService = serviceLocator.get<AuthService>();

  Future<List<AvailableSchedule>> fetchAvailableSchedules({
    required int doctorId,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final uri = Uri.parse(
      '${BaseService.baseUrl}/patient-available-schedules',
    ).replace(queryParameters: {'doctor_id': doctorId.toString()});

    final response = await http.get(uri, headers: headersWithAuth(token));
    final data = jsonDecode(response.body);
    print('Respuesta decodificada: $data');
    print('Tipo de data["data"]: ${data['data'].runtimeType}');
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return List<AvailableSchedule>.from(
        (data['data'] as List).map((e) => AvailableSchedule.fromJson(e)),
      );
    } else {
      throw Exception('Formato inesperado de respuesta de horarios');
    }
  }

  Future<Appointment> createAppointment(int availableScheduleId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final uri = Uri.parse('${BaseService.baseUrl}/patient-appointments');

    print(
      '[AgendarService] Creando cita con schedule ID: $availableScheduleId',
    );
    print('[AgendarService] URL: $uri');

    final body = json.encode({'available_schedule_id': availableScheduleId});
    print('[AgendarService] Body: $body');

    final response = await http.post(
      uri,
      headers: headersWithAuth(token),
      body: body,
    );

    print('[AgendarService] Response status: ${response.statusCode}');
    print('[AgendarService] Response body: ${response.body}');

    if (response.statusCode != 201 && response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(
        'Error al crear cita: ${errorData['message'] ?? response.body}',
      );
    }

    final responseData = jsonDecode(response.body);

    // El backend devuelve { "message": "...", "appointment": {...} }
    if (responseData.containsKey('appointment')) {
      return Appointment.fromJson(responseData['appointment']);
    } else {
      throw Exception(
        'Respuesta inesperada: no se encontró "appointment" en la respuesta',
      );
    }
  }
}
