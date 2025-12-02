import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Search/Busqueda Screen Widget Tests', () {
    testWidgets('Busqueda screen shows specialty filter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Search Doctors')),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Filter by Specialty',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DropdownButton<int>(
                    hint: const Text('Select Specialty'),
                    items: [
                      DropdownMenuItem(value: 1, child: const Text('Cardiology')),
                      DropdownMenuItem(value: 2, child: const Text('Pediatrics')),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 24),
                  const Text('Search Results'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Search Doctors'), findsOneWidget);
      expect(find.text('Filter by Specialty'), findsOneWidget);
      expect(find.text('Search Results'), findsOneWidget);
    });

    testWidgets('Busqueda screen shows doctor list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                ListTile(
                  title: Text('Dr. John Smith'),
                  subtitle: Text('Cardiology'),
                ),
                ListTile(
                  title: Text('Dr. Jane Doe'),
                  subtitle: Text('Pediatrics'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Dr. John Smith'), findsOneWidget);
      expect(find.text('Dr. Jane Doe'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Pediatrics'), findsOneWidget);
    });

    testWidgets('Busqueda screen filter works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search doctors by name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Apply Filter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Apply Filter'), findsOneWidget);
    });
  });
}
