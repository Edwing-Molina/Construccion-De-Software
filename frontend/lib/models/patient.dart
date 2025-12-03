import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'patient.g.dart';

@JsonSerializable(explicitToJson: true)
class Patient {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'birth', fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime birth;

  @JsonKey(name: 'gender')
  final String? gender;

  @JsonKey(name: 'blood_type')
  final String? bloodType;

  @JsonKey(name: 'emergency_contact_name')
  final String? emergencyContactName;

  @JsonKey(name: 'emergency_contact_phone')
  final String? emergencyContactPhone;

  @JsonKey(name: 'nss_number')
  final String? nssNumber;

  @JsonKey(
    name: 'deleted_at',
    fromJson: _nullableDateFromJson,
    toJson: _nullableDateToJson,
  )
  final DateTime? deletedAt;

  // Relación con User
  @JsonKey(name: 'user')
  final User? user;

  @JsonKey(name: 'description')
  final String? description;

  Patient({
    this.id,
    required this.userId,
    required this.birth,
    this.gender,
    this.bloodType,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.nssNumber,
    this.deletedAt,
    this.user,
    this.description,
  });

  // Métodos para conversión de fechas
  static DateTime _dateFromJson(String date) => DateTime.parse(date);
  static String _dateToJson(DateTime date) => date.toIso8601String();

  static DateTime? _nullableDateFromJson(String? date) =>
      date != null ? DateTime.parse(date) : null;
  static String? _nullableDateToJson(DateTime? date) => date?.toIso8601String();

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
  Map<String, dynamic> toJson() => _$PatientToJson(this);
}
