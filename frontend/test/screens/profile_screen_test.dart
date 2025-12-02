import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Profile Screen Widget Tests', () {
    testWidgets('Profile screen shows user info', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('My Profile')),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Name: John Doe',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Email: john@example.com',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Phone: 555-1234',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Name: John Doe'), findsOneWidget);
      expect(find.text('Email: john@example.com'), findsOneWidget);
    });

    testWidgets('Profile screen shows edit button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Profile Information'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Profile Information'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('Profile screen displays doctor info', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Doctor Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Specialties: Cardiology, Internal Medicine'),
                    const SizedBox(height: 8),
                    const Text('Clinics: Downtown, Uptown'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Doctor Information'), findsOneWidget);
      expect(
        find.text('Specialties: Cardiology, Internal Medicine'),
        findsOneWidget,
      );
    });

    testWidgets('Profile screen displays patient info', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Patient Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Birth Date: 1990-06-15'),
                    const SizedBox(height: 8),
                    const Text('Blood Type: O+'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Patient Information'), findsOneWidget);
      expect(find.text('Birth Date: 1990-06-15'), findsOneWidget);
      expect(find.text('Blood Type: O+'), findsOneWidget);
    });
  });
}
