// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_clinic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoctorClinic _$DoctorClinicFromJson(Map<String, dynamic> json) => DoctorClinic(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  address: json['address'] as String,
  officeNumber: json['office_number'] as String?,
);

Map<String, dynamic> _$DoctorClinicToJson(DoctorClinic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'office_number': instance.officeNumber,
    };
