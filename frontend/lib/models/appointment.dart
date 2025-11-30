import 'package:json_annotation/json_annotation.dart';

import 'available_schedule.dart';
import 'patient.dart';
import 'doctor.dart';

part 'appointment.g.dart';

/// Represents a medical appointment.
///
/// Includes patient, doctor, schedule, date and current status.
@JsonSerializable(explicitToJson: true)
class Appointment {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'patient_id')
  final int patientId;

  @JsonKey(name: 'appointment_date')
  final DateTime? appointmentDate;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'patient')
  final Patient? patient;

  @JsonKey(name: 'doctor')
  final Doctor? doctor;

  @JsonKey(name: 'available_schedule')
  final AvailableSchedule? availableSchedule;

  /// Creates an Appointment instance.
  const Appointment({
    this.id,
    required this.patientId,
    required this.appointmentDate,
    required this.status,
    this.patient,
    this.doctor,
    this.availableSchedule,
  });

  /// Creates an Appointment from a JSON map.
  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);


  /// Converts this Appointment to a JSON map.
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
