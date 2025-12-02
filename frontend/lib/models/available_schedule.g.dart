part of 'available_schedule.dart';

// JsonSerializableGenerator

AvailableSchedule _$AvailableScheduleFromJson(Map<String, dynamic> json) =>
    AvailableSchedule(
      id: (json['id'] as num?)?.toInt(),
      doctorId: (json['doctor_id'] as num).toInt(),
      clinicId: (json['clinic_id'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      startTime: AvailableSchedule._timeFromJson(json['start_time'] as String),
      endTime: AvailableSchedule._timeFromJson(json['end_time'] as String),
      available: AvailableSchedule._boolFromJson(json['available']),
      doctor:
          json['doctor'] == null
              ? null
              : Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
      clinic:
          json['clinic'] == null
              ? null
              : Clinic.fromJson(json['clinic'] as Map<String, dynamic>),
      appointment:
          json['cite'] == null
              ? null
              : Appointment.fromJson(json['cite'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AvailableScheduleToJson(AvailableSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctor_id': instance.doctorId,
      'clinic_id': instance.clinicId,
      'date': instance.date.toIso8601String(),
      'start_time': AvailableSchedule._timeToJson(instance.startTime),
      'end_time': AvailableSchedule._timeToJson(instance.endTime),
      'available': instance.available,
      'doctor': instance.doctor?.toJson(),
      'clinic': instance.clinic?.toJson(),
      'cite': instance.appointment?.toJson(),
    };
