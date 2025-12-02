import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/api_response.dart';

void main() {
  group('ApiResponse Tests', () {
    test('ApiResponse creation with success data', () {
      final response = ApiResponse<String>(
        success: true,
        message: 'Success',
        data: 'Test Data',
      );
      expect(response.success, true);
      expect(response.message, 'Success');
      expect(response.data, 'Test Data');
      expect(response.errors, isNull);
    });

    test('ApiResponse creation with errors', () {
      final response = ApiResponse<String>(
        success: false,
        message: 'Error occurred',
        errors: ['Error 1', 'Error 2'],
      );
      expect(response.success, false);
      expect(response.message, 'Error occurred');
      expect(response.errors?.length, 2);
      expect(response.data, isNull);
    });

    test('ApiResponse with null data', () {
      final response = ApiResponse<String>(
        success: true,
        message: 'Processing',
      );
      expect(response.success, true);
      expect(response.data, isNull);
    });

    test('ApiResponse generic type works correctly', () {
      final response = ApiResponse<int>(
        success: true,
        message: 'Success',
        data: 42,
      );
      expect(response.data, 42);
      expect(response.data is int, true);
    });

    test('ApiResponse with list data', () {
      final response = ApiResponse<List<String>>(
        success: true,
        message: 'List retrieved',
        data: ['item1', 'item2', 'item3'],
      );
      expect(response.success, true);
      expect(response.data?.length, 3);
      expect(response.data?[0], 'item1');
    });

    test('ApiResponse with map data', () {
      final response = ApiResponse<Map<String, dynamic>>(
        success: true,
        message: 'Map retrieved',
        data: {'key': 'value', 'number': 123},
      );
      expect(response.success, true);
      expect(response.data?['key'], 'value');
      expect(response.data?['number'], 123);
    });

    test('ApiResponse defaults', () {
      final response = ApiResponse<String>(
        success: false,
        message: '',
      );
      expect(response.success, false);
      expect(response.message, '');
      expect(response.data, isNull);
      expect(response.errors, isNull);
    });
  });
}
