// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Clinic _$ClinicFromJson(Map<String, dynamic> json) => Clinic(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  address: json['address'] as String,
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
  doctors:
      (json['doctor_clinic'] as List<dynamic>?)
          ?.map((e) => DoctorClinicPivot.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ClinicToJson(Clinic instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'doctor_clinic': instance.doctors?.map((e) => e.toJson()).toList(),
};
