import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tonton/services/ai_service.dart';

// A simple test file to verify image analysis functionality
// To run:
// flutter run -t test_image_analysis.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://lagkyztrqvquxnijmcpo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhZ2t5enRycXZxdXhuaWptY3BvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDczMjQwNjEsImV4cCI6MjA2MjkwMDA2MX0.wemvw0dQSsGP9KDOG4LnoYzawZoxOOAgep2gvzmnc_g',
  );
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Service provider
final aiServiceProvider = Provider<AIService>((ref) => AIService());

// Image file provider
final imageFileProvider = StateProvider<File?>((ref) => null);

// Analysis result provider
final analysisResultProvider = StateProvider<dynamic>((ref) => null);

// Loading state provider
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Error message provider
final errorMessageProvider = StateProvider<String?>((ref) => null);

// Auto-analyze provider
final _autoAnalyzeProvider = StateProvider<bool>((ref) => true);

// Test images provider
final testImagesProvider = Provider<List<Map<String, dynamic>>>((ref) => [
  {
    'name': 'Apple',
    'path': '/Users/hiroshikodera/repos/_active/apps/Tonton/test_images/apple.jpg',
    'description': 'Simple single food item'
  },
  {
    'name': 'Meal',
    'path': '/Users/hiroshikodera/repos/_active/apps/Tonton/test_images/meal.jpg',
    'description': 'Colorful meal with vegetables'
  },
  {
    'name': 'Dark Meal',
    'path': '/Users/hiroshikodera/repos/_active/apps/Tonton/test_images/dark_meal.jpg',
    'description': 'Meal in low-light conditions'
  },
]);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Analysis Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends ConsumerWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFile = ref.watch(imageFileProvider);
    final analysisResult = ref.watch(analysisResultProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Analysis Test'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This is a test screen to verify image analysis functionality',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            
            // Image Selection Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery, ref),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('From Gallery'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera, ref),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('From Camera'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Test Images Selection
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Images:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ref.watch(testImagesProvider).map((testImage) {
                      return Tooltip(
                        message: testImage['description'],
                        child: ElevatedButton(
                          onPressed: () => _loadTestImage(testImage['path'], ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue.shade700,
                          ),
                          child: Text(testImage['name']),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  CheckboxListTile(
                    title: const Text('Auto-analyze after selection'),
                    value: ref.watch(_autoAnalyzeProvider),
                    onChanged: (value) {
                      ref.read(_autoAnalyzeProvider.notifier).state = value ?? false;
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Selected Image Preview
            if (imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFile,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Analyze Button
            if (imageFile != null)
              ElevatedButton(
                onPressed: isLoading ? null : () => _analyzeImage(ref),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Analyze Image', style: TextStyle(fontSize: 16)),
              ),
            
            const SizedBox(height: 16),
            
            // Loading Indicator
            if (isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Analyzing image...'),
                  ],
                ),
              ),
            
            // Error Message
            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    Text(errorMessage),
                  ],
                ),
              ),
            
            // Results Section
            if (analysisResult != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analysis Results:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Divider(),
                    _buildResultRow('Food Name', analysisResult['mealName'] ?? ''),
                    _buildResultRow('Description', analysisResult['description'] ?? ''),
                    _buildResultRow('Calories', '${analysisResult['calories']} kcal'),
                    _buildResultRow('Protein', '${analysisResult['nutrients']['protein']} g'),
                    _buildResultRow('Fat', '${analysisResult['nutrients']['fat']} g'),
                    _buildResultRow('Carbs', '${analysisResult['nutrients']['carbs']} g'),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Console Output Section
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Console Output:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analysisResult != null
                        ? 'Successfully analyzed image:\n${analysisResult.toString()}'
                        : errorMessage != null
                            ? 'Error: $errorMessage'
                            : 'Select an image and tap "Analyze Image"',
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      
      if (pickedImage != null) {
        final file = File(pickedImage.path);
        
        // Reset state
        ref.read(imageFileProvider.notifier).state = file;
        ref.read(analysisResultProvider.notifier).state = null;
        ref.read(errorMessageProvider.notifier).state = null;
      }
    } catch (e) {
      print('Error picking image: $e');
      ref.read(errorMessageProvider.notifier).state = 'Error picking image: $e';
    }
  }
  
  void _loadTestImage(String path, WidgetRef ref) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        // Reset state
        ref.read(imageFileProvider.notifier).state = file;
        ref.read(analysisResultProvider.notifier).state = null;
        ref.read(errorMessageProvider.notifier).state = null;
        
        print('Loaded test image: $path');
        
        // Auto-analyze if enabled
        if (ref.read(_autoAnalyzeProvider)) {
          _analyzeImage(ref);
        }
      } else {
        ref.read(errorMessageProvider.notifier).state = 'Test image not found at: $path';
      }
    } catch (e) {
      print('Error loading test image: $e');
      ref.read(errorMessageProvider.notifier).state = 'Error loading test image: $e';
    }
  }
  
  Future<void> _analyzeImage(WidgetRef ref) async {
    final imageFile = ref.read(imageFileProvider);
    if (imageFile == null) return;
    
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorMessageProvider.notifier).state = null;
    
    try {
      print('Starting image analysis...');
      
      final startTime = DateTime.now();
      
      // Get AIService from provider
      final aiService = ref.read(aiServiceProvider);
      
      // Call estimateNutritionFromImageFile
      final result = await aiService.estimateNutritionFromImageFile(imageFile);
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('Analysis completed in ${duration.inSeconds}.${duration.inMilliseconds % 1000} seconds');
      
      if (result != null) {
        print('Analysis successful: $result');
        ref.read(analysisResultProvider.notifier).state = result.toJson();
      } else {
        print('Analysis returned null result');
        ref.read(errorMessageProvider.notifier).state = 'Analysis failed: No data returned';
      }
    } catch (e, stackTrace) {
      print('Error during analysis: $e');
      print('Stack trace: $stackTrace');
      
      String errorMsg = 'Analysis failed: ${e.toString()}';
      
      // Make error message more user-friendly
      if (e.toString().contains('timeout')) {
        errorMsg = 'Analysis timed out. Try using a smaller or clearer image.';
      } else if (e.toString().contains('status 413')) {
        errorMsg = 'Image is too large. Please select a smaller image.';
      } else if (e.toString().contains('status 429')) {
        errorMsg = 'Too many requests. Please try again in a few minutes.';
      }
      
      ref.read(errorMessageProvider.notifier).state = errorMsg;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
  
  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}