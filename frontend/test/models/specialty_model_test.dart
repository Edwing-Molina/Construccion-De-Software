import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/specialty.dart';

void main() {
  group('Specialty Model Tests', () {
    test('Specialty creation with valid data', () {
      final specialty = Specialty(id: 1, name: 'Cardiology');
      expect(specialty.id, 1);
      expect(specialty.name, 'Cardiology');
    });

    test('Specialty.fromJson creates instance correctly', () {
      final json = {'id': 2, 'name': 'Neurology'};
      final specialty = Specialty.fromJson(json);
      expect(specialty.id, 2);
      expect(specialty.name, 'Neurology');
    });

    test('Specialty.toJson converts to Map correctly', () {
      final specialty = Specialty(id: 3, name: 'Pediatrics');
      final json = specialty.toJson();
      expect(json['id'], 3);
      expect(json['name'], 'Pediatrics');
    });

    test('Specialty equality works correctly', () {
      final specialty1 = Specialty(id: 1, name: 'Cardiology');
      final specialty2 = Specialty(id: 1, name: 'Cardiology');
      expect(specialty1.id == specialty2.id, true);
      expect(specialty1.name == specialty2.name, true);
    });

    test('Specialty with empty name', () {
      final specialty = Specialty(id: 4, name: '');
      expect(specialty.id, 4);
      expect(specialty.name, isEmpty);
    });

    test('Specialty roundtrip JSON serialization', () {
      final original = Specialty(id: 5, name: 'Orthopedics');
      final json = original.toJson();
      final restored = Specialty.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
    });
  });
}
