import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/doctor.dart';
import 'package:frontend/models/specialty.dart';
import 'package:frontend/models/doctor_clinic_pivot.dart';

void main() {
  group('Doctor Model Tests', () {
    test('Doctor creation with all fields', () {
      final specialty = Specialty(id: 1, name: 'Cardiology');
      final doctor = Doctor(
        id: 1,
        userId: 10,
        description: 'Experienced cardiologist',
        licenseNumber: 'LIC123456',
        specialties: [specialty],
      );
      expect(doctor.id, 1);
      expect(doctor.userId, 10);
      expect(doctor.description, 'Experienced cardiologist');
      expect(doctor.licenseNumber, 'LIC123456');
      expect(doctor.specialties, isNotEmpty);
    });

    test('Doctor creation with minimal fields', () {
      final doctor = Doctor(userId: 20);
      expect(doctor.userId, 20);
      expect(doctor.id, isNull);
      expect(doctor.description, isNull);
      expect(doctor.licenseNumber, isNull);
      expect(doctor.specialties, isNull);
    });

    test('Doctor.fromJson creates instance correctly', () {
      final json = {
        'id': 3,
        'user_id': 30,
        'description': 'Pediatrician',
        'license_number': 'LIC789012',
        'specialties': [
          {'id': 2, 'name': 'Pediatrics'},
        ],
        'doctor_clinic': [
          {'clinic_id': 2, 'doctor_id': 3, 'office_number': '101'},
        ],
      };
      final doctor = Doctor.fromJson(json);
      expect(doctor.id, 3);
      expect(doctor.userId, 30);
      expect(doctor.description, 'Pediatrician');
      expect(doctor.licenseNumber, 'LIC789012');
      expect(doctor.specialties?.length, 1);
      expect(doctor.clinics?.length, 1);
    });

    test('Doctor.toJson converts to Map correctly', () {
      final specialty = Specialty(id: 1, name: 'Cardiology');
      final doctor = Doctor(
        id: 4,
        userId: 40,
        description: 'Senior cardiologist',
        specialties: [specialty],
      );
      final json = doctor.toJson();
      expect(json['id'], 4);
      expect(json['user_id'], 40);
      expect(json['description'], 'Senior cardiologist');
      expect(json['specialties'], isNotEmpty);
    });

    test('Doctor with multiple specialties', () {
      final specs = [
        Specialty(id: 1, name: 'Cardiology'),
        Specialty(id: 2, name: 'Internal Medicine'),
      ];
      final doctor = Doctor(id: 5, userId: 50, specialties: specs);
      expect(doctor.specialties?.length, 2);
      expect(doctor.specialties?[0].name, 'Cardiology');
      expect(doctor.specialties?[1].name, 'Internal Medicine');
    });

    test('Doctor with multiple clinics via pivot', () {
      final pivots = [
        DoctorClinicPivot(doctorId: 6, clinicId: 1, officeNumber: '101'),
        DoctorClinicPivot(doctorId: 6, clinicId: 2, officeNumber: '205'),
      ];
      final doctor = Doctor(id: 6, userId: 60, clinics: pivots);
      expect(doctor.clinics?.length, 2);
      expect(doctor.clinics?[0].officeNumber, '101');
      expect(doctor.clinics?[1].officeNumber, '205');
    });

    test('Doctor roundtrip JSON serialization', () {
      final specialty = Specialty(id: 1, name: 'Cardiology');
      final original = Doctor(
        id: 7,
        userId: 70,
        description: 'Expert doctor',
        licenseNumber: 'LIC555666',
        specialties: [specialty],
      );
      final json = original.toJson();
      final restored = Doctor.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.description, original.description);
    });
  });
}
