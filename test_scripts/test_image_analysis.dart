import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tonton/services/ai_service.dart';
import 'package:tonton/models/estimated_meal_nutrition.dart';

/// Test script for manually testing the image analysis functionality
/// This can be run independently to verify the Supabase Edge Function
/// and the AI service integration.
///
/// To use:
/// 1. Create a simple Flutter app that calls this test function
/// 2. Run it on a device with images to test
/// 3. Select an image and observe the console output for results

Future<void> testImageAnalysis() async {
  print('=======================================');
  print('STARTING IMAGE ANALYSIS TEST');
  print('=======================================');
  
  // Create an instance of the AI service
  final aiService = AIService();
  
  try {
    // Pick an image
    print('Selecting test image...');
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    
    if (pickedImage == null) {
      print('No image selected. Test cancelled.');
      return;
    }
    
    // Get file info
    final imageFile = File(pickedImage.path);
    final fileSize = await imageFile.length();
    final fileSizeKB = fileSize / 1024;
    print('Selected image: ${pickedImage.path}');
    print('Image size: ${fileSizeKB.toStringAsFixed(2)} KB');
    
    // Start timer
    final startTime = DateTime.now();
    print('Starting AI analysis...');
    
    // Call the service
    final result = await aiService.estimateNutritionFromImageFile(imageFile);
    
    // Calculate duration
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    print('Analysis completed in ${duration.inSeconds}.${duration.inMilliseconds % 1000} seconds');
    
    // Check result
    if (result != null) {
      print('✅ ANALYSIS SUCCESSFUL');
      print('Food name: ${result.mealName}');
      print('Description: ${result.description}');
      print('Calories: ${result.calories} kcal');
      print('Protein: ${result.nutrients.protein}g');
      print('Fat: ${result.nutrients.fat}g');
      print('Carbs: ${result.nutrients.carbs}g');
      if (result.notes != null && result.notes!.isNotEmpty) {
        print('Notes:');
        for (final note in result.notes!) {
          print('- $note');
        }
      }
    } else {
      print('❌ ANALYSIS FAILED: No result returned');
    }
  } catch (e, stackTrace) {
    print('❌ ERROR DURING ANALYSIS: $e');
    print('Stack trace: $stackTrace');
  }
  
  print('=======================================');
  print('IMAGE ANALYSIS TEST COMPLETE');
  print('=======================================');
}

/// Simple widget to run the test
class ImageAnalysisTestScreen extends ConsumerWidget {
  const ImageAnalysisTestScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Analysis Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await testImageAnalysis();
              },
              child: const Text('Test Image Analysis'),
            ),
            const SizedBox(height: 20),
            const Text('Check console for test results'),
          ],
        ),
      ),
    );
  }
}

/// To use this test screen, add it to your main.dart:
/// ```
/// void main() {
///   runApp(ProviderScope(
///     child: MaterialApp(
///       home: ImageAnalysisTestScreen(),
///     ),
///   ));
/// }
/// ```