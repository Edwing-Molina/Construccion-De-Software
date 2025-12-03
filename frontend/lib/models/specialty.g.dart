// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialty.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Specialty _$SpecialtyFromJson(Map<String, dynamic> json) => Specialty(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  doctors:
      (json['doctors'] as List<dynamic>?)
          ?.map((e) => Doctor.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$SpecialtyToJson(Specialty instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'doctors': instance.doctors?.map((e) => e.toJson()).toList(),
};
