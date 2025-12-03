import 'package:http/http.dart' as http;
import '../base_service.dart';
import '../auth/auth_service.dart';
import '../../models/models.dart';

class SpecialtyService extends BaseService {
  final AuthService _authService;

  SpecialtyService(this._authService);

  Future<ApiResponse<List<Specialty>>> getAllSpecialties() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      final url = Uri.parse('${BaseService.baseUrl}/specialtys');

      final response = await http.get(url, headers: headersWithAuth(token));

      return handleResponse(
        response,
        (data) => ApiResponse<List<Specialty>>(
          success: true,
          data:
              (data['data'] as List)
                  .map((specialty) => Specialty.fromJson(specialty))
                  .toList(),
          message: data['message'] ?? 'Especialidades obtenidas exitosamente',
        ),
      );
    } catch (e) {
      throw Exception('Error al obtener especialidades: $e');
    }
  }
}
