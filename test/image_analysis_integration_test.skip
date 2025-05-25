import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tonton/models/estimated_meal_nutrition.dart';
import 'package:tonton/models/nutrient_info.dart';
import 'package:tonton/services/ai_service.dart';
import 'package:tonton/providers/ai_estimation_provider.dart';
import 'package:tonton/screens/meal_input_screen.dart';

// Generate mocks
@GenerateMocks([AIService, ImagePicker])
import 'image_analysis_integration_test.mocks.dart';

void main() {
  group('Image Analysis Integration Tests', () {
    late MockAIService mockAiService;
    late MockImagePicker mockImagePicker;
    late File mockImageFile;
    
    setUpAll(() {
      // Create a mock image file
      mockImageFile = File('test/assets/test_food_image.jpg');
      // If running on CI where file might not exist, create a dummy file
      if (!mockImageFile.existsSync()) {
        debugPrint('Warning: Test image file does not exist. Using a dummy file instead.');
        mockImageFile = File('test/assets/dummy.jpg');
        if (!mockImageFile.existsSync()) {
          mockImageFile.createSync(recursive: true);
        }
      }
    });
    
    setUp(() {
      mockAiService = MockAIService();
      mockImagePicker = MockImagePicker();
    });
    
    testWidgets('MealInputScreen shows image analysis UI', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiServiceProvider.overrideWithValue(mockAiService),
          ],
          child: MaterialApp(
            home: const MealInputScreen(),
          ),
        ),
      );
      
      // Verify that the image analysis section is displayed
      expect(find.text('AI Estimation from Image'), findsOneWidget);
      expect(find.text('From Gallery'), findsOneWidget);
      expect(find.text('From Camera'), findsOneWidget);
      
      // Verify that the AI help section is displayed
      expect(find.text('AI Nutrition Estimation'), findsOneWidget);
    });
    
    testWidgets('Select image and analyze nutritional content', (WidgetTester tester) async {
      // Mock the image picker to return our test image
      final mockPickedFile = XFile(mockImageFile.path);
      when(mockImagePicker.pickImage(
        source: anyNamed('source'),
        maxWidth: anyNamed('maxWidth'),
        maxHeight: anyNamed('maxHeight'),
        imageQuality: anyNamed('imageQuality')))
          .thenAnswer((_) async => mockPickedFile);
      
      // Mock the AI service to return a sample result
      final mockNutrition = EstimatedMealNutrition(
        mealName: 'Test Food',
        description: 'A test food item',
        calories: 250,
        nutrients: NutrientInfo(
          protein: 10,
          fat: 15,
          carbs: 30,
        ),
      );
      when(mockAiService.estimateNutritionFromImageFile(any))
          .thenAnswer((_) async => mockNutrition);
      
      // Build the app with our mocks
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiServiceProvider.overrideWithValue(mockAiService),
          ],
          child: MaterialApp(
            home: MealInputScreen(),
          ),
        ),
      );
      
      // Inject the mock image picker
      // Note: This requires a custom implementation to work properly in a real test
      
      // Tap the gallery button
      await tester.tap(find.text('From Gallery'));
      await tester.pump();
      
      // Wait for the analysis to complete
      await tester.pumpAndSettle();
      
      // Verify that the nutrition values are filled in
      // This would require accessing the text controllers which is not directly possible in widget tests
      // You would need to find the TextFields and verify their current values
    });
    
    test('AIService properly handles various image types', () async {
      // Skip if not running in an environment with Supabase access
      if (Platform.environment.containsKey('SKIP_SUPABASE_TESTS')) {
        return;
      }
      
      // Create a real AI service for this test
      final aiService = AIService();
      
      // Test with a JPEG image
      final jpegFile = File('test/assets/test_food_jpeg.jpg');
      if (jpegFile.existsSync()) {
        final result = await aiService.estimateNutritionFromImageFile(jpegFile);
        expect(result, isNotNull);
        expect(result!.mealName, isNotEmpty);
      }
      
      // Test with a PNG image
      final pngFile = File('test/assets/test_food_png.png');
      if (pngFile.existsSync()) {
        final result = await aiService.estimateNutritionFromImageFile(pngFile);
        expect(result, isNotNull);
        expect(result!.mealName, isNotEmpty);
      }
    });
    
    test('Error handling for network failures', () async {
      // Mock the AI service to throw a network exception
      when(mockAiService.estimateNutritionFromImageFile(any))
          .thenThrow(Exception('Network error'));
      
      // Create a provider using the mock
      final provider = AIEstimationNotifier(mockAiService);
      
      // Call the method and expect an error state
      await provider.estimateNutritionFromImageFile(mockImageFile);
      
      // Verify the provider is in an error state
      expect(provider.state, isA<AsyncError>());
    });
  });
}