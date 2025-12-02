import 'dart:convert';
import 'package:http/http.dart' as http;
import '../base_service.dart';
import '../auth/auth_service.dart';
import '../service_locator.dart';
import '../../models/models.dart';

class ProfileService extends BaseService {
  AuthService get _authService => serviceLocator.get<AuthService>();

  Future<ApiResponse<User>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      final url = Uri.parse('${BaseService.baseUrl}/me');
      final body = json.encode(profileData);

      final response = await http.put(
        url,
        headers: headersWithAuth(token),
        body: body,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['data'] != null) {
        return ApiResponse<User>(
          success: true,
          data: User.fromJson(responseData['data']),
          message: responseData['message'] ?? 'Perfil actualizado exitosamente',
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: responseData['message'] ?? 'Error al actualizar perfil',
          errors:
              responseData['errors'] != null
                  ? List<String>.from(responseData['errors'])
                  : null,
        );
      }
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  Future<ApiResponse<User>> getProfile() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final url = Uri.parse('${BaseService.baseUrl}/me');

      final response = await http.get(url, headers: headersWithAuth(token));

      return handleResponse(
        response,
        (data) => ApiResponse<User>(
          success: true,
          data: User.fromJson(data['data'] ?? data),
          message: data['message'] ?? 'Perfil obtenido exitosamente',
        ),
      );
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  Map<String, dynamic> preparePatientProfileData({
    String? name,
    String? phone,
    String? description,
    required DateTime birthDate,
    required String gender,
    required String bloodType,
    required String emergencyContactName,
    required String emergencyContactPhone,
    required String nssNumber,
  }) {
    final Map<String, dynamic> patientData = {
      'description': description,
      'birth': birthDate.toIso8601String().split('T')[0],
      'gender': gender,
      'blood_type': bloodType,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'nss_number': nssNumber,
    };

    final Map<String, dynamic> profile = {
      'name': name,
      'phone': phone,
      'patient': patientData,
    };

    return profile;
  }

  Map<String, dynamic> prepareDoctorProfileData({
    String? name,
    String? phone,
    String? description,
    required List<int> specialtyIds,
    required List<Map<String, dynamic>>
    clinics,
  }) {
    final Map<String, dynamic> doctorData = {
      'description': description,
      'clinics': clinics,
    };

    final Map<String, dynamic> profile = {
      'name': name,
      'phone': phone,
      'doctor': doctorData,
      'specialty_ids': specialtyIds,
    };

    return profile;
  }
}
