// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  password: json['password'] as String?,
  rememberToken: json['remember_token'] as String?,
  doctor:
      json['doctor'] == null
          ? null
          : Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
  patient:
      json['patient'] == null
          ? null
          : Patient.fromJson(json['patient'] as Map<String, dynamic>),
  specialties:
      (json['specialtys'] as List<dynamic>?)
          ?.map((e) => Specialty.fromJson(e as Map<String, dynamic>))
          .toList(),
  clinics:
      (json['clinics'] as List<dynamic>?)
          ?.map((e) => DoctorClinic.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'doctor': instance.doctor?.toJson(),
  'patient': instance.patient?.toJson(),
  'specialtys': instance.specialties?.map((e) => e.toJson()).toList(),
  'clinics': instance.clinics?.map((e) => e.toJson()).toList(),
};
