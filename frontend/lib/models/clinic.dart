import 'package:json_annotation/json_annotation.dart';
import 'doctor_clinic_pivot.dart';

part 'clinic.g.dart';

@JsonSerializable(explicitToJson: true)
class Clinic {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'address')
  final String address;

  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt; // Para SoftDeletes

  // Relación muchos-a-muchos con doctors
  @JsonKey(name: 'doctor_clinic')
  final List<DoctorClinicPivot>? doctors;

  Clinic({
    this.id,
    required this.name,
    required this.address,
    this.deletedAt,
    this.doctors,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) => _$ClinicFromJson(json);
  Map<String, dynamic> toJson() => _$ClinicToJson(this);
}
