part of 'doctor_clinic_pivot.dart';

// JsonSerializableGenerator

DoctorClinicPivot _$DoctorClinicPivotFromJson(Map<String, dynamic> json) =>
    DoctorClinicPivot(
      doctorId: (json['doctor_id'] as num).toInt(),
      clinicId: (json['clinic_id'] as num).toInt(),
      officeNumber: json['office_number'] as String,
      clinic:
          json['clinic'] == null
              ? null
              : Clinic.fromJson(json['clinic'] as Map<String, dynamic>),
      doctor:
          json['doctor'] == null
              ? null
              : Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DoctorClinicPivotToJson(DoctorClinicPivot instance) =>
    <String, dynamic>{
      'doctor_id': instance.doctorId,
      'clinic_id': instance.clinicId,
      'office_number': instance.officeNumber,
      'clinic': instance.clinic,
      'doctor': instance.doctor,
    };
