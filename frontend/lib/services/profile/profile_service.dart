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

      // Debug: Log del body enviado
      print('Profile update body: $body');

      final response = await http.put(
        url,
        headers: headersWithAuth(token),
        body: body,
      );

      final responseData = json.decode(response.body);

      // Debug: Log de la respuesta
      print('Profile update response: ${response.statusCode}');
      print('Profile update response body: ${response.body}');

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

      print('[ProfileService] Fetching profile from: $url');
      print('[ProfileService] Headers: ${headersWithAuth(token)}');

      final response = await http.get(url, headers: headersWithAuth(token));

      print('[ProfileService] Response status: ${response.statusCode}');
      print('[ProfileService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('[ProfileService] Parsed response: $responseData');

        // Extract user data from the response
        final userData = responseData['data'] ?? responseData;
        print('[ProfileService] User data to parse: $userData');

        final user = User.fromJson(userData);
        print('[ProfileService] Successfully parsed user: ${user.name}');

        return ApiResponse<User>(
          success: true,
          data: user,
          message: responseData['message'] ?? 'Perfil obtenido exitosamente',
        );
      } else {
        print('[ProfileService] Error status: ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('[ProfileService] Exception in getProfile: $e');
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

    final Map<String, dynamic> profile = {'patient': patientData};

    // Only add name and phone if they are provided
    if (name != null && name.isNotEmpty) {
      profile['name'] = name;
    }
    if (phone != null && phone.isNotEmpty) {
      profile['phone'] = phone;
    }

    return profile;
  }

  Map<String, dynamic> prepareDoctorProfileData({
    String? name,
    String? phone,
    String? description,
    required List<int> specialtyIds,
    required List<Map<String, dynamic>>
    clinics, // Cambio: ahora incluye consultorio
  }) {
    final Map<String, dynamic> doctorData = {
      'description': description,
      'clinics': clinics, // Formato: [{'clinic_id': 1, 'office_number': '15'}]
    };

    final Map<String, dynamic> profile = {
      'doctor': doctorData,
      'specialty_ids': specialtyIds, // Mover specialty_ids al nivel raíz
    };

    // Only add name and phone if they are provided
    if (name != null && name.isNotEmpty) {
      profile['name'] = name;
    }
    if (phone != null && phone.isNotEmpty) {
      profile['phone'] = phone;
    }

    return profile;
  }
}
