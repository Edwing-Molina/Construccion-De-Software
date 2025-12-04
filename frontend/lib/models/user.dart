import 'package:frontend/models/patient.dart';
import 'package:json_annotation/json_annotation.dart';
import 'doctor.dart';
import 'specialty.dart';
import 'doctor_clinic.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phone')
  final String? phone; // Nullable

  @JsonKey(
    name: 'password',
    includeToJson: false,
  ) // No se incluye al serializar
  final String? password;

  @JsonKey(
    name: 'remember_token',
    includeToJson: false,
  ) // No se incluye al serializar
  final String? rememberToken;

  // Relaciones
  @JsonKey(name: 'doctor')
  final Doctor? doctor;

  @JsonKey(name: 'patient')
  final Patient? patient; // Patient model not yet defined in project

  // Datos adicionales para doctores (vienen directamente en la respuesta)
  @JsonKey(name: 'specialties')
  final List<Specialty>? specialties;

  @JsonKey(name: 'clinics')
  final List<DoctorClinic>? clinics;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.password,
    this.rememberToken,
    this.doctor,
    this.patient,
    this.specialties,
    this.clinics,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
