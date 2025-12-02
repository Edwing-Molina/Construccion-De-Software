import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Appointment Card Widget Tests', () {
    testWidgets('AppointmentCard displays appointment info', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dr. John Smith',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Cardiology'),
                    const SizedBox(height: 8),
                    const Text('2024-12-20 at 2:00 PM'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Dr. John Smith'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('2024-12-20 at 2:00 PM'), findsOneWidget);
    });

    testWidgets('AppointmentCard with status', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Appointment Details'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Confirmed',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Appointment Details'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
    });
  });
}
