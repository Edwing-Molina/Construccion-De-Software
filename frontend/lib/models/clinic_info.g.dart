// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClinicInfo _$ClinicInfoFromJson(Map<String, dynamic> json) => ClinicInfo(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  address: json['address'] as String,
  officeNumber: json['office_number'] as String?,
);

Map<String, dynamic> _$ClinicInfoToJson(ClinicInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'office_number': instance.officeNumber,
    };
