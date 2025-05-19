import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tonton/services/ai_service.dart';
import 'package:tonton/models/estimated_meal_nutrition.dart';

/// A standalone app for testing the image analysis functionality
/// 
/// To run this app:
/// ```
/// flutter run -t tools/standalone_image_analysis_app.dart
/// ```

void main() {
  runApp(
    const ProviderScope(
      child: StandaloneApp(),
    ),
  );
}

class StandaloneApp extends StatelessWidget {
  const StandaloneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Analysis Tester',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ImageAnalysisTestScreen(),
    );
  }
}

class ImageAnalysisTestScreen extends ConsumerStatefulWidget {
  const ImageAnalysisTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ImageAnalysisTestScreen> createState() => _ImageAnalysisTestScreenState();
}

class _ImageAnalysisTestScreenState extends ConsumerState<ImageAnalysisTestScreen> {
  final AIService _aiService = AIService();
  File? _selectedImageFile;
  EstimatedMealNutrition? _analysisResult;
  bool _isLoading = false;
  String? _errorMessage;
  final List<String> _logMessages = [];
  final ScrollController _logScrollController = ScrollController();

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _analysisResult = null;
      _addLog('Selecting image from ${source == ImageSource.camera ? 'camera' : 'gallery'}...');
    });

    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        final fileSize = await file.length();
        final fileSizeKB = fileSize / 1024;
        
        setState(() {
          _selectedImageFile = file;
          _addLog('Selected image: ${pickedImage.path}');
          _addLog('Image size: ${fileSizeKB.toStringAsFixed(2)} KB');
        });
      } else {
        setState(() {
          _addLog('No image selected.');
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
        _addLog('Error: $_errorMessage');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImageFile == null) {
      setState(() {
        _errorMessage = 'No image selected.';
        _addLog('Error: $_errorMessage');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _analysisResult = null;
      _addLog('Starting AI analysis...');
    });

    try {
      final startTime = DateTime.now();
      _addLog('Request started at: $startTime');
      
      final result = await _aiService.estimateNutritionFromImageFile(_selectedImageFile!);
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      _addLog('Analysis completed in ${duration.inSeconds}.${duration.inMilliseconds % 1000} seconds');
      
      setState(() {
        _analysisResult = result;
        if (result != null) {
          _addLog('✅ ANALYSIS SUCCESSFUL');
          _addLog('Food name: ${result.mealName}');
          _addLog('Description: ${result.description}');
          _addLog('Calories: ${result.calories} kcal');
          _addLog('Protein: ${result.nutrients.protein}g');
          _addLog('Fat: ${result.nutrients.fat}g');
          _addLog('Carbs: ${result.nutrients.carbs}g');
        } else {
          _errorMessage = 'Analysis failed: No data returned';
          _addLog('❌ $_errorMessage');
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Analysis failed: $e';
        _addLog('❌ $_errorMessage');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollLogsToBottom();
    }
  }

  void _addLog(String message) {
    _logMessages.add('[${DateTime.now().toString().split('.').first}] $message');
    _scrollLogsToBottom();
  }

  void _scrollLogsToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearLogs() {
    setState(() {
      _logMessages.clear();
      _addLog('Logs cleared.');
    });
  }

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Analysis Tester'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Image and Analysis Section
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Image Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Image Selection Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('From Gallery'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('From Camera'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Selected Image
                  if (_selectedImageFile != null)
                    Center(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImageFile!,
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _analyzeImage,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Analyze Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Loading Indicator
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Processing...'),
                          ],
                        ),
                      ),
                    ),
                  
                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Error',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_errorMessage!),
                        ],
                      ),
                    ),
                  
                  // Analysis Results
                  if (_analysisResult != null)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Analysis Results',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          _buildResultRow('Food Name', _analysisResult!.mealName),
                          _buildResultRow('Description', _analysisResult!.description),
                          _buildResultRow('Calories', '${_analysisResult!.calories} kcal'),
                          _buildResultRow('Protein', '${_analysisResult!.nutrients.protein} g'),
                          _buildResultRow('Fat', '${_analysisResult!.nutrients.fat} g'),
                          _buildResultRow('Carbs', '${_analysisResult!.nutrients.carbs} g'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Log Section
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Logs',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _clearLogs,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.builder(
                        controller: _logScrollController,
                        itemCount: _logMessages.length,
                        itemBuilder: (context, index) {
                          final message = _logMessages[index];
                          Color textColor = Colors.white;
                          
                          if (message.contains('❌') || message.contains('Error')) {
                            textColor = Colors.red.shade300;
                          } else if (message.contains('✅') || message.contains('SUCCESSFUL')) {
                            textColor = Colors.green.shade300;
                          } else if (message.contains('Starting')) {
                            textColor = Colors.yellow.shade300;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              message,
                              style: TextStyle(
                                color: textColor,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
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