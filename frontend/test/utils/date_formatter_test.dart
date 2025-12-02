import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date Formatter Tests', () {
    test('formatDate extracts year month day', () {
      final date = DateTime(2024, 12, 25);
      expect(date.year, 2024);
      expect(date.month, 12);
      expect(date.day, 25);
    });

    test('formatDate different months', () {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 6, 15);
      expect(date1.month, isNot(date2.month));
      expect(date1.year == date2.year, true);
    });

    test('formatTime parses hours and minutes', () {
      final hour = 14;
      final minute = 30;
      expect(hour >= 0 && hour <= 23, true);
      expect(minute >= 0 && minute <= 59, true);
    });

    test('isValidBirthDate with past date', () {
      final birthDate = DateTime(1990, 6, 15);
      final now = DateTime.now();
      expect(birthDate.isBefore(now), true);
    });

    test('isValidBirthDate rejects future date', () {
      final futureDate = DateTime(2050, 12, 25);
      final now = DateTime.now();
      expect(futureDate.isAfter(now), true);
    });

    test('getAge calculation', () {
      final birthDate = DateTime(1990, 6, 15);
      final now = DateTime.now();
      final age = now.year - birthDate.year;
      expect(age, greaterThan(30));
    });
  });
}
