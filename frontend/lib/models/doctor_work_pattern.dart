import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'clinic.dart';
import 'doctor.dart';
import 'enum_days.dart';

part 'doctor_work_pattern.g.dart';

/// Represents a doctor's work pattern at a specific clinic.
///
/// Defines recurring schedules including day of week, time slots,
/// and effective date ranges.
@JsonSerializable(explicitToJson: true)
class DoctorWorkPattern {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'doctor_id')
  final int doctorId;

  @JsonKey(name: 'clinic_id')
  final int clinicId;

  @JsonKey(name: 'day_of_week', fromJson: _dayFromJson, toJson: _dayToJson)
  final DayOfWeek dayOfWeek;

  @JsonKey(
    name: 'start_time_pattern',
    fromJson: _timeFromJson,
    toJson: _timeToJson,
  )
  final TimeOfDay startTimePattern;

  @JsonKey(
    name: 'end_time_pattern',
    fromJson: _timeFromJson,
    toJson: _timeToJson,
  )
  final TimeOfDay endTimePattern;

  @JsonKey(name: 'slot_duration_minutes')
  final int slotDurationMinutes;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(
    name: 'start_date_effective',
    fromJson: _dateFromJson,
    toJson: _dateToJson,
  )
  final DateTime startDateEffective;

  @JsonKey(
    name: 'end_date_effective',
    fromJson: _nullableDateFromJson,
    toJson: _nullableDateToJson,
  )
  final DateTime? endDateEffective;

  @JsonKey(name: 'doctor')
  final Doctor? doctor;

  @JsonKey(name: 'clinic')
  final Clinic? clinic;

  /// Creates a DoctorWorkPattern instance.
  const DoctorWorkPattern({
    this.id,
    required this.doctorId,
    required this.clinicId,
    required this.dayOfWeek,
    required this.startTimePattern,
    required this.endTimePattern,
    required this.slotDurationMinutes,
    required this.isActive,
    required this.startDateEffective,
    this.endDateEffective,
    this.doctor,
    this.clinic,
  });

  /// Creates a DoctorWorkPattern from a JSON map.
  factory DoctorWorkPattern.fromJson(Map<String, dynamic> json) =>
      _$DoctorWorkPatternFromJson(json);

  /// Converts a string day to a DayOfWeek enum.
  static DayOfWeek _dayFromJson(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return DayOfWeek.monday;
      case 'tuesday':
        return DayOfWeek.tuesday;
      case 'wednesday':
        return DayOfWeek.wednesday;
      case 'thursday':
        return DayOfWeek.thursday;
      case 'friday':
        return DayOfWeek.friday;
      case 'saturday':
        return DayOfWeek.saturday;
      case 'sunday':
        return DayOfWeek.sunday;
      default:
        throw FormatException('Día inválido: $day');
    }
  }

  /// Converts a DayOfWeek enum to a capitalized string.
  static String _dayToJson(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }

  /// Converts an ISO 8601 time string to a TimeOfDay.
  ///
  /// Returns TimeOfDay(hour: 0, minute: 0) if parsing fails.
  static TimeOfDay _timeFromJson(String time) {
    try {
      final timePart = time.contains('T') ? time.split('T')[1] : time;
      final parts = timePart.split(':');

      final hour = parts.isNotEmpty ? int.parse(parts[0]) : 0;
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  /// Converts a TimeOfDay to a HH:mm formatted string.
  static String _timeToJson(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Converts an ISO 8601 date string to a DateTime.
  static DateTime _dateFromJson(String date) => DateTime.parse(date);

  /// Converts a DateTime to an ISO 8601 date string (YYYY-MM-DD).
  static String _dateToJson(DateTime date) =>
      date.toIso8601String().split('T')[0];

  /// Converts a nullable ISO 8601 date string to a nullable DateTime.
  static DateTime? _nullableDateFromJson(String? date) =>
      date != null ? DateTime.parse(date) : null;

  /// Converts a nullable DateTime to a nullable ISO 8601 date string.
  static String? _nullableDateToJson(DateTime? date) =>
      date?.toIso8601String().split('T')[0];

  /// Converts this DoctorWorkPattern instance to a JSON map.
  Map<String, dynamic> toJson() => _$DoctorWorkPatternToJson(this);
}
