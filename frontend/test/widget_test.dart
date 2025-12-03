// Widget tests for the Medical Appointment System
//
// This test verifies that the main app initializes correctly with the router configuration.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('App initializes and displays MaterialApp.router', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(MaterialApp), findsOneWidget);

      final materialApp =
          find.byType(MaterialApp).evaluate().first.widget as MaterialApp;
      expect(materialApp.title, 'Sistema de Citas Médicas');
    });

    testWidgets('MyApp theme is configured correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      final materialApp =
          find.byType(MaterialApp).evaluate().first.widget as MaterialApp;
      expect(materialApp.theme, isNotNull);
      expect(materialApp.debugShowCheckedModeBanner, false);
    });
  });
}
