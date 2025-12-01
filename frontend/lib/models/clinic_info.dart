import 'package:json_annotation/json_annotation.dart';

part 'clinic_info.g.dart';

@JsonSerializable()
class ClinicInfo {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'address')
  final String address;

  @JsonKey(name: 'office_number')
  final String? officeNumber;

  ClinicInfo({
    required this.id,
    required this.name,
    required this.address,
    this.officeNumber,
  });

  factory ClinicInfo.fromJson(Map<String, dynamic> json) =>
      _$ClinicInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ClinicInfoToJson(this);
}
