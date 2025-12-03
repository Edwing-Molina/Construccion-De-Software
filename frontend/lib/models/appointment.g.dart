// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: (json['id'] as num?)?.toInt(),
  patientId: (json['patient_id'] as num).toInt(),
  appointmentDate:
      json['appointment_date'] == null
          ? null
          : DateTime.parse(json['appointment_date'] as String),
  status: json['status'] as String,
  patient:
      json['patient'] == null
          ? null
          : Patient.fromJson(json['patient'] as Map<String, dynamic>),
  doctor:
      json['doctor'] == null
          ? null
          : Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
  availableSchedule:
      json['available_schedule'] == null
          ? null
          : AvailableSchedule.fromJson(
            json['available_schedule'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'appointment_date': instance.appointmentDate?.toIso8601String(),
      'status': instance.status,
      'patient': instance.patient?.toJson(),
      'doctor': instance.doctor?.toJson(),
      'available_schedule': instance.availableSchedule?.toJson(),
    };
