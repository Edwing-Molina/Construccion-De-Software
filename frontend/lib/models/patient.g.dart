// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['user_id'] as num).toInt(),
  birth: Patient._dateFromJson(json['birth'] as String),
  gender: json['gender'] as String?,
  bloodType: json['blood_type'] as String?,
  emergencyContactName: json['emergency_contact_name'] as String?,
  emergencyContactPhone: json['emergency_contact_phone'] as String?,
  nssNumber: json['nss_number'] as String?,
  deletedAt: Patient._nullableDateFromJson(json['deleted_at'] as String?),
  user:
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
  description: json['description'] as String?,
);

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'birth': Patient._dateToJson(instance.birth),
  'gender': instance.gender,
  'blood_type': instance.bloodType,
  'emergency_contact_name': instance.emergencyContactName,
  'emergency_contact_phone': instance.emergencyContactPhone,
  'nss_number': instance.nssNumber,
  'deleted_at': Patient._nullableDateToJson(instance.deletedAt),
  'user': instance.user?.toJson(),
  'description': instance.description,
};
