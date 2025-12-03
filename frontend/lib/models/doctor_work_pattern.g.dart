// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_work_pattern.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoctorWorkPattern _$DoctorWorkPatternFromJson(Map<String, dynamic> json) =>
    DoctorWorkPattern(
      id: (json['id'] as num?)?.toInt(),
      doctorId: (json['doctor_id'] as num).toInt(),
      clinicId: (json['clinic_id'] as num).toInt(),
      dayOfWeek: DoctorWorkPattern._dayFromJson(json['day_of_week'] as String),
      startTimePattern: DoctorWorkPattern._timeFromJson(
        json['start_time_pattern'] as String,
      ),
      endTimePattern: DoctorWorkPattern._timeFromJson(
        json['end_time_pattern'] as String,
      ),
      slotDurationMinutes: (json['slot_duration_minutes'] as num).toInt(),
      isActive: json['is_active'] as bool,
      startDateEffective: DoctorWorkPattern._dateFromJson(
        json['start_date_effective'] as String,
      ),
      endDateEffective: DoctorWorkPattern._nullableDateFromJson(
        json['end_date_effective'] as String?,
      ),
      doctor:
          json['doctor'] == null
              ? null
              : Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
      clinic:
          json['clinic'] == null
              ? null
              : Clinic.fromJson(json['clinic'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DoctorWorkPatternToJson(
  DoctorWorkPattern instance,
) => <String, dynamic>{
  'id': instance.id,
  'doctor_id': instance.doctorId,
  'clinic_id': instance.clinicId,
  'day_of_week': DoctorWorkPattern._dayToJson(instance.dayOfWeek),
  'start_time_pattern': DoctorWorkPattern._timeToJson(
    instance.startTimePattern,
  ),
  'end_time_pattern': DoctorWorkPattern._timeToJson(instance.endTimePattern),
  'slot_duration_minutes': instance.slotDurationMinutes,
  'is_active': instance.isActive,
  'start_date_effective': DoctorWorkPattern._dateToJson(
    instance.startDateEffective,
  ),
  'end_date_effective': DoctorWorkPattern._nullableDateToJson(
    instance.endDateEffective,
  ),
  'doctor': instance.doctor?.toJson(),
  'clinic': instance.clinic?.toJson(),
};
