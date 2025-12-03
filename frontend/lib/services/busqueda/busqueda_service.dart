import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/services/base_service.dart';
import 'package:frontend/services/auth/auth_service.dart';
import 'package:frontend/services/service_locator.dart';
import 'package:frontend/models/doctor.dart';
import 'package:frontend/models/specialty.dart';

class BusquedaService extends BaseService {
  final AuthService _authService = serviceLocator.get<AuthService>();

  Future<List<Doctor>> fetchDoctors({int? specialtyId}) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final uri = Uri.parse('${BaseService.baseUrl}/doctors').replace(
      queryParameters: {
        if (specialtyId != null) 'specialty_id': specialtyId.toString(),
      },
    );

    final response = await http.get(uri, headers: headersWithAuth(token));
    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return List<Doctor>.from(
        (data['data'] as List).map((e) => Doctor.fromJson(e)),
      );
    } else {
      throw Exception('Formato inesperado de respuesta');
    }
  }
}

class SpecialtyService extends BaseService {
  final AuthService _authService = serviceLocator.get<AuthService>();

  Future<List<Specialty>> fetchSpecialties() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final uri = Uri.parse('${BaseService.baseUrl}/specialtys');
    final response = await http.get(uri, headers: headersWithAuth(token));
    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return List<Specialty>.from(
        (data['data'] as List).map((e) => Specialty.fromJson(e)),
      );
    } else {
      throw Exception('Formato inesperado de respuesta de especialidades');
    }
  }
}
