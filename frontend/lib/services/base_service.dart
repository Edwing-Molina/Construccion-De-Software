import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

abstract class BaseService {
  static String get baseUrl => AppConfig.baseUrl;

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> headersWithAuth(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };

  T handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    switch (response.statusCode) {
      case 200:
      case 201:
        final data = json.decode(response.body);
        return parser(data);
      case 400:
        throw BadRequestException('Solicitud incorrecta: ${response.body}');
      case 401:
        throw UnauthorizedException('No autorizado');
      case 403:
        throw ForbiddenException('Acceso denegado');
      case 404:
        throw NotFoundException('Recurso no encontrado');
      case 500:
        throw ServerException('Error interno del servidor');
      default:
        throw UnknownException('Error desconocido: ${response.statusCode}');
    }
  }

  List<T> handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) parser,
  ) {
    switch (response.statusCode) {
      case 200:
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => parser(item as Map<String, dynamic>))
            .toList();
      case 400:
        throw BadRequestException('Solicitud incorrecta: ${response.body}');
      case 401:
        throw UnauthorizedException('No autorizado');
      case 403:
        throw ForbiddenException('Acceso denegado');
      case 404:
        throw NotFoundException('Recurso no encontrado');
      case 500:
        throw ServerException('Error interno del servidor');
      default:
        throw UnknownException('Error desconocido: ${response.statusCode}');
    }
  }
}

// Excepciones personalizadas
class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);

  @override
  String toString() => 'BadRequestException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);

  @override
  String toString() => 'ForbiddenException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);

  @override
  String toString() => 'UnknownException: $message';
}
