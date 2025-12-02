part of 'doctor.dart';

// JsonSerializableGenerator

Doctor _$DoctorFromJson(Map<String, dynamic> json) => Doctor(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['user_id'] as num).toInt(),
  deletedAt:
      json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
  user:
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
  specialties:
      (json['specialties'] as List<dynamic>?)
          ?.map((e) => Specialty.fromJson(e as Map<String, dynamic>))
          .toList(),
  clinics:
      (json['doctor_clinic'] as List<dynamic>?)
          ?.map((e) => DoctorClinicPivot.fromJson(e as Map<String, dynamic>))
          .toList(),
  appointments:
      (json['appointments'] as List<dynamic>?)
          ?.map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList(),
  availableSchedules:
      (json['available_schedules'] as List<dynamic>?)
          ?.map((e) => AvailableSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
  description: json['description'] as String?,
  licenseNumber: json['license_number'] as String?,
);

Map<String, dynamic> _$DoctorToJson(Doctor instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'user': instance.user?.toJson(),
  'specialties': instance.specialties?.map((e) => e.toJson()).toList(),
  'doctor_clinic': instance.clinics?.map((e) => e.toJson()).toList(),
  'appointments': instance.appointments?.map((e) => e.toJson()).toList(),
  'available_schedules':
      instance.availableSchedules?.map((e) => e.toJson()).toList(),
  'description': instance.description,
  'license_number': instance.licenseNumber,
};
