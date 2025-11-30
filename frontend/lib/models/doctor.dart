import 'package:json_annotation/json_annotation.dart';

import 'appointment.dart';
import 'available_schedule.dart';
import 'doctor_clinic_pivot.dart';
import 'specialty.dart';
import 'user.dart';

part 'doctor.g.dart';

/// Represents a doctor in the medical system.
///
/// Contains the doctor's basic information and relationships with
/// users, specialties, clinics, appointments, and available schedules.
@JsonSerializable(explicitToJson: true)
class Doctor {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'user_id')
  final int userId;

  /// The timestamp when this doctor was soft deleted, if applicable.
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  @JsonKey(name: 'user')
  final User? user;

  @JsonKey(name: 'specialties')
  final List<Specialty>? specialties;

  @JsonKey(name: 'doctor_clinic')
  final List<DoctorClinicPivot>? clinics;

  @JsonKey(name: 'appointments')
  final List<Appointment>? appointments;

  @JsonKey(name: 'available_schedules')
  final List<AvailableSchedule>? availableSchedules;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'license_number')
  final String? licenseNumber;

  /// Creates a Doctor instance.
  const Doctor({
    this.id,
    required this.userId,
    this.deletedAt,
    this.user,
    this.specialties,
    this.clinics,
    this.appointments,
    this.availableSchedules,
    this.description,
    this.licenseNumber,
  });

  /// Creates a Doctor instance from a JSON map.
  factory Doctor.fromJson(Map<String, dynamic> json) =>
    _$DoctorFromJson(json);

  /// Converts this Doctor instance to a JSON map.
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}
