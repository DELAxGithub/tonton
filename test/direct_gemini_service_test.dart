import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tonton/services/direct_gemini_service.dart';
import 'dart:io';

void main() {
  group('DirectGeminiService', () {
    late DirectGeminiService service;

    setUpAll(() async {
      // Load environment variables for testing
      await dotenv.load(fileName: '.env');
      service = DirectGeminiService();
    });

    test('should have API key configured', () {
      expect(() => DirectGeminiService.apiKey, returnsNormally);
      expect(DirectGeminiService.apiKey, isNotEmpty);
    });

    test('should convert Gemini result to EstimatedMealNutrition', () {
      // Test the conversion logic with mock Gemini response
      final mockGeminiResult = {
        'items': [
          {
            'name': 'ご飯',
            'calories': 300,
            'protein_g': 5,
            'fat_g': 1,
            'carbs_g': 65,
          },
          {
            'name': '鮭',
            'calories': 150,
            'protein_g': 25,
            'fat_g': 5,
            'carbs_g': 0,
          },
        ],
        'total_calories': 450,
      };

      final result = service.convertToEstimatedMealNutrition(mockGeminiResult);

      expect(result.mealName, 'ご飯, 鮭');
      expect(result.description, '画像から解析された食事: 2品目');
      expect(result.calories, 450.0);
      expect(result.nutrients.protein, 30.0);
      expect(result.nutrients.fat, 6.0);
      expect(result.nutrients.carbs, 65.0);
    });
  });
}
