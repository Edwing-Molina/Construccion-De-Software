import 'package:json_annotation/json_annotation.dart';
import 'clinic.dart';
import 'doctor.dart';

part 'doctor_clinic_pivot.g.dart';

@JsonSerializable()
class DoctorClinicPivot {
  @JsonKey(name: 'doctor_id')
  final int doctorId;

  @JsonKey(name: 'clinic_id')
  final int clinicId;

  @JsonKey(name: 'office_number')
  final String officeNumber;

  @JsonKey(name: 'clinic')
  final Clinic? clinic;

  @JsonKey(name: 'doctor')
  final Doctor? doctor; // Añadir esta línea si necesitas la relación inversa

  DoctorClinicPivot({
    required this.doctorId,
    required this.clinicId,
    required this.officeNumber,
    this.clinic,
    this.doctor,
  });

  factory DoctorClinicPivot.fromJson(Map<String, dynamic> json) =>
      _$DoctorClinicPivotFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorClinicPivotToJson(this);
}
