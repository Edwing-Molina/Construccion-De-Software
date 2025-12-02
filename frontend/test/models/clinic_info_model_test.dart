import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/clinic_info.dart';

void main() {
  group('ClinicInfo Model Tests', () {
    test('ClinicInfo creation with all fields', () {
      final clinic = ClinicInfo(
        id: 1,
        name: 'Central Clinic',
        address: '123 Main St',
        officeNumber: '101',
      );
      expect(clinic.id, 1);
      expect(clinic.name, 'Central Clinic');
      expect(clinic.address, '123 Main St');
      expect(clinic.officeNumber, '101');
    });

    test('ClinicInfo creation with required fields only', () {
      final clinic = ClinicInfo(
        id: 2,
        name: 'Branch Clinic',
        address: '456 Oak Ave',
      );
      expect(clinic.id, 2);
      expect(clinic.name, 'Branch Clinic');
      expect(clinic.address, '456 Oak Ave');
      expect(clinic.officeNumber, isNull);
    });

    test('ClinicInfo.fromJson creates instance correctly', () {
      final json = {
        'id': 3,
        'name': 'Downtown Clinic',
        'address': '456 Oak Ave',
        'office_number': '205',
      };
      final clinic = ClinicInfo.fromJson(json);
      expect(clinic.id, 3);
      expect(clinic.name, 'Downtown Clinic');
      expect(clinic.address, '456 Oak Ave');
      expect(clinic.officeNumber, '205');
    });

    test('ClinicInfo.toJson converts to Map correctly', () {
      final clinic = ClinicInfo(
        id: 4,
        name: 'North Clinic',
        address: '789 Pine Rd',
        officeNumber: '310',
      );
      final json = clinic.toJson();
      expect(json['id'], 4);
      expect(json['name'], 'North Clinic');
      expect(json['address'], '789 Pine Rd');
      expect(json['office_number'], '310');
    });

    test('ClinicInfo roundtrip JSON serialization', () {
      final original = ClinicInfo(
        id: 5,
        name: 'East Clinic',
        address: '999 Elm St',
        officeNumber: '415',
      );
      final json = original.toJson();
      final restored = ClinicInfo.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.address, original.address);
      expect(restored.officeNumber, original.officeNumber);
    });

    test('ClinicInfo with null office number', () {
      final json = {
        'id': 6,
        'name': 'Test Clinic',
        'address': 'Test Address',
        'office_number': null,
      };
      final clinic = ClinicInfo.fromJson(json);
      expect(clinic.officeNumber, isNull);
    });
  });
}
