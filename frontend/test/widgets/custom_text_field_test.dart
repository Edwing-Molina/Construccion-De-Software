import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Custom TextField Widget Tests', () {
    testWidgets('CustomTextField renders with placeholder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFieldMock(hintText: 'Enter text'),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter text'), findsOneWidget);
    });

    testWidgets('CustomTextField accepts text input', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(controller: controller),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test Input');
      expect(controller.text, 'Test Input');
      controller.dispose();
    });

    testWidgets('CustomTextField shows error text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(
                errorText: 'This field is required',
              ),
            ),
          ),
        ),
      );

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('CustomTextField with obscured password', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(hintText: 'Password'),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'SecurePass123');
      expect(controller.text, 'SecurePass123');
      controller.dispose();
    });
  });
}

// Mock widget for testing
class CustomTextFieldMock extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;

  const CustomTextFieldMock({
    Key? key,
    required this.hintText,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
    );
  }
}
