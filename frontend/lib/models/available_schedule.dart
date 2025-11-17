import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'doctor.dart';
import 'clinic.dart';
import 'appointment.dart';

part 'available_schedule.g.dart';

@JsonSerializable(explicitToJson: true)
class AvailableSchedule {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'doctor_id')
  final int doctorId;

  @JsonKey(name: 'clinic_id')
  final int clinicId;

  @JsonKey(name: 'date')
  final DateTime date;

  @JsonKey(name: 'start_time', fromJson: _timeFromJson, toJson: _timeToJson)
  final TimeOfDay startTime;

  @JsonKey(name: 'end_time', fromJson: _timeFromJson, toJson: _timeToJson)
  final TimeOfDay endTime;

  @JsonKey(name: 'available', fromJson: _boolFromJson)
  final bool available;

  // Relaciones
  @JsonKey(name: 'doctor')
  final Doctor? doctor;

  @JsonKey(name: 'clinic')
  final Clinic? clinic;

  @JsonKey(name: 'cite')
  final Appointment? appointment;

  AvailableSchedule({
    this.id,
    required this.doctorId,
    required this.clinicId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.available,
    this.doctor,
    this.clinic,
    this.appointment,
  });

  static TimeOfDay _timeFromJson(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static bool _boolFromJson(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return false;
  }

  static String _timeToJson(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  factory AvailableSchedule.fromJson(Map<String, dynamic> json) =>
      _$AvailableScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableScheduleToJson(this);
}
