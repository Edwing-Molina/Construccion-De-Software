import 'package:json_annotation/json_annotation.dart';

part 'doctor_clinic.g.dart';

@JsonSerializable()
class DoctorClinic {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'address')
  final String address;

  @JsonKey(name: 'office_number')
  final String officeNumber;

  DoctorClinic({
    required this.id,
    required this.name,
    required this.address,
    required this.officeNumber,
  });

  factory DoctorClinic.fromJson(Map<String, dynamic> json) =>
      _$DoctorClinicFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorClinicToJson(this);
}
