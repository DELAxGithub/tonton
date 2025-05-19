// lib/services/ai_service.dart

import 'dart:convert';
import 'dart:io'; // For File
import 'package:image/image.dart' as img; // For image processing
import 'package:mime/mime.dart'; // For MIME type detection
import '../models/estimated_meal_nutrition.dart';

import 'package:supabase_flutter/supabase_flutter.dart'; // Added for Supabase
// import 'package:supabase/supabase.dart' show FunctionsError; 
import 'dart:developer' as developer;
import 'dart:typed_data'; // For Uint8List

class AIService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // estimateNutritionFromText メソッドは変更なし (省略)
  Future<EstimatedMealNutrition?> estimateNutritionFromText(String mealDescription) async {
    // ... (既存のコード) ...
    try {
      developer.log('Calling Supabase function: estimate-nutrition', name: 'TonTon.AIService');
      developer.log('With payload: $mealDescription', name: 'TonTon.AIService');
      
      final response = await _supabaseClient.functions.invoke(
        'estimate-nutrition', // This is the function name in Supabase
        body: {'mealDescription': mealDescription},
      );

      developer.log('Response status: ${response.status}', name: 'TonTon.AIService');
      
      if (response.status != 200) {
        developer.log('Error from Supabase function: ${response.status} - ${response.data}', name: 'TonTon.AIService.Error');
        if (response.status == 404) {
            developer.log('Supabase function "estimate-nutrition" not found. Check deployment.', name: 'TonTon.AIService.Error');
        }
        return null; 
      }

      developer.log('Response data: ${response.data}', name: 'TonTon.AIService');
      if (response.data != null) {
        Map<String, dynamic> jsonData;
        if (response.data is String) {
          jsonData = jsonDecode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          jsonData = response.data;
        } else {
          developer.log('Unexpected response data type: ${response.data.runtimeType}', name: 'TonTon.AIService.Error');
          return null;
        }
        return EstimatedMealNutrition.fromJson(jsonData);
      } else {
        developer.log('Supabase function returned null data.', name: 'TonTon.AIService.Error');
        return null;
      }
    } catch (e, stackTrace) {
      developer.log('Exception in AIService (estimateNutritionFromText): $e', name: 'TonTon.AIService.Exception', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<EstimatedMealNutrition?> estimateNutritionFromImageFile(File imageFile) async {
    try {
      developer.log('Processing image for nutrition analysis (file)', name: 'TonTon.AIService.ImageFile');

      final bytes = await imageFile.readAsBytes();
      developer.log('Image size: ${bytes.length} bytes', name: 'TonTon.AIService.ImageFile');

      // Optional: Check if image is too large (e.g., >10MB)
      if (bytes.length > 10 * 1024 * 1024) {
        developer.log('Image too large: ${(bytes.length / (1024 * 1024)).toStringAsFixed(2)} MB',
            name: 'TonTon.AIService.ImageFile.Warning');
        // Consider throwing a specific exception or returning null with an error message
      }

      final base64Image = base64Encode(bytes);
      developer.log('Base64 image length: ${base64Image.length} characters', name: 'TonTon.AIService.ImageFile');

      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg'; // Default to jpeg if lookup fails
      developer.log('Calling Edge Function "process-image-gemini" with image type: $mimeType', name: 'TonTon.AIService.ImageFile');

      final response = await _supabaseClient.functions.invoke(
        'process-image-gemini', // Edge function from PoC
        body: {
          'imageData': base64Image,
          'mimeType': mimeType,
        },
      );

      developer.log('Edge Function "process-image-gemini" response status: ${response.status}', name: 'TonTon.AIService.ImageFile');

      if (response.status != 200) {
        developer.log('Error status from "process-image-gemini": ${response.status}', name: 'TonTon.AIService.ImageFile.Error');
        if (response.data != null) {
          developer.log('Error data: ${response.data}', name: 'TonTon.AIService.ImageFile.Error');
        }
        // Consider throwing a more specific error or returning a result object with error info
        throw Exception('Edge Function "process-image-gemini" error: Status ${response.status}');
      }

      if (response.data != null) {
        developer.log('Successfully received data from "process-image-gemini"', name: 'TonTon.AIService.ImageFile');
         // Log the raw data for debugging
        developer.log('Raw data: ${jsonEncode(response.data)}', name: 'TonTon.AIService.ImageFile.RawData');

        if (response.data is Map<String, dynamic>) {
          return EstimatedMealNutrition.fromJson(response.data as Map<String, dynamic>);
        } else {
          developer.log('Unexpected data type from "process-image-gemini": ${response.data.runtimeType}', name: 'TonTon.AIService.ImageFile.Error');
          throw Exception('Unexpected data format from AI service.');
        }
      } else {
        developer.log('No data returned from "process-image-gemini"', name: 'TonTon.AIService.ImageFile.Warning');
        return null; // Or throw an exception
      }
    } catch (e, stackTrace) {
      developer.log('Error in estimateNutritionFromImageFile: $e', name: 'TonTon.AIService.ImageFile.Exception', error: e, stackTrace: stackTrace);
      // Rethrow or handle as appropriate for the app's error handling strategy
      // For example, could return a special error object or rethrow a domain-specific exception
      throw Exception('Failed to estimate nutrition from image file: ${e.toString()}');
    }
  }

  // uploadImageToSupabase メソッドは変更なし (省略)
  Future<String?> uploadImageToSupabase(
    File imageFile, 
    String userId, {
    int maxWidth = 1024, 
    int quality = 85,
  }) async {
    // ... (既存のコード) ...
    try {
      developer.log('Starting image upload process for user: $userId', name: 'TonTon.AIService.Upload');
      
      Uint8List imageBytes = await imageFile.readAsBytes();
      
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        developer.log('Failed to decode image.', name: 'TonTon.AIService.Upload.Error');
        return null;
      }

      img.Image resizedImage = originalImage;
      if (originalImage.width > maxWidth) {
        resizedImage = img.copyResize(originalImage, width: maxWidth);
        developer.log('Image resized to width: $maxWidth', name: 'TonTon.AIService.Upload');
      }

      List<int> processedImageBytes = img.encodeJpg(resizedImage, quality: quality);
      
      final String fileExtension = 'jpg';
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final String filePath = '$userId/$fileName';
      const String bucketName = 'meal-images'; // Changed from meal_images

      developer.log('Uploading $filePath to Supabase bucket: $bucketName', name: 'TonTon.AIService.Upload');

      await _supabaseClient.storage
          .from(bucketName)
          .uploadBinary( 
            filePath,
            Uint8List.fromList(processedImageBytes), 
            fileOptions: FileOptions(
              cacheControl: '3600', 
              upsert: false,
              contentType: 'image/jpeg', 
            ),
          );

      final String imageUrl = _supabaseClient.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      
      developer.log('Image uploaded successfully: $imageUrl', name: 'TonTon.AIService.Upload');
      return imageUrl;

    } on StorageException catch (e, stackTrace) {
      developer.log('Supabase Storage Error during upload: ${e.message}', name: 'TonTon.AIService.Upload.Error', error: e, stackTrace: stackTrace);
      return null;
    } catch (e, stackTrace) {
      developer.log('Unexpected error during image upload: $e', name: 'TonTon.AIService.Upload.Exception', error: e, stackTrace: stackTrace);
      return null;
    }
  }


  Future<EstimatedMealNutrition?> estimateNutritionFromImageUrl(String imageUrl) async {
    developer.log('Attempting to call Edge Function "process-meal-image" with imageUrl: $imageUrl', name: 'TonTon.AIService.Invoke');
    try {
      final response = await _supabaseClient.functions.invoke(
        'process-meal-image',
        body: {'imageUrl': imageUrl},
      );

      // response.status や response.data を使ったログはそのまま活用できます
      developer.log('Edge Function "process-meal-image" response status (from Edge Function itself): ${response.status}', name: 'TonTon.AIService.Response');
      developer.log('Edge Function "process-meal-image" response data: ${response.data}', name: 'TonTon.AIService.ResponseData');

      if (response.data != null) {
        Map<String, dynamic> jsonData;
        if (response.data is String) {
          try {
            jsonData = jsonDecode(response.data);
          } catch (e) {
            developer.log('Failed to decode JSON string from Edge Function: ${response.data}', name: 'TonTon.AIService.JsonError', error: e);
            throw Exception('Failed to parse response from AI service.');
          }
        } else if (response.data is Map<String, dynamic>) {
          jsonData = response.data;
        } else {
          developer.log('Unexpected response data type from process-meal-image: ${response.data.runtimeType}', name: 'TonTon.AIService.TypeError');
          throw Exception('Unexpected data format from AI service.');
        }
        
        if (jsonData.containsKey('error')) {
            developer.log('AI service (Edge Function payload) reported an error: ${jsonData['error']}', name: 'TonTon.AIService.AIError');
            throw Exception('AI analysis error: ${jsonData['error']}');
        }
        
        return EstimatedMealNutrition.fromJson(jsonData);
      } else {
        // response.error が null で、かつ response.data も null の場合を考慮
        // (Supabaseのinvokeが成功したが、Edge Functionが何も返さなかった、またはエラーを示唆するレスポンスだった場合)
        // response.status で判断するのも有効です。
        // 通常、SupabaseのFunction Clientは、Edge Functionが非2xxステータスを返した場合、
        // FunctionsErrorをスローするか、response.errorに情報を格納します。
        // ここでは、dataがnullだった場合の一般的なエラーとして扱います。
        developer.log('Supabase function (process-meal-image) returned null data, status: ${response.status}', name: 'TonTon.AIService.NullData');
        throw Exception('AI service returned no data or an unspecified error (status: ${response.status}).');
      }
    } catch (e, stackTrace) { 
      developer.log('>>> Exception during Edge Function call or response processing:', name: 'TonTon.AIService.CatchAllException');
      developer.log('>>> Error type: ${e.runtimeType}', name: 'TonTon.AIService.CatchAllException');
      developer.log('>>> Error message: $e', name: 'TonTon.AIService.CatchAllException');
      developer.log('>>> Stack trace: $stackTrace', name: 'TonTon.AIService.CatchAllException');
      
      String errorMessage = e.toString().replaceFirst("Exception: ", "");
      // Check if the error message string contains 'FunctionsError' for more specific Supabase function errors
      // This is a workaround if direct type checking `e is FunctionsError` is problematic.
      if (e.toString().contains('FunctionsError')) {
        // Attempt to parse out a more specific message if possible, or just use the toString()
        // Example: FunctionsError: HttpException: HTTP 500: Internal Server Error
        // We might want to extract "HTTP 500: Internal Server Error" or similar.
        // For now, just indicating it's a FunctionsError.
        developer.log('Error appears to be a Supabase FunctionsError.', name: 'TonTon.AIService.FunctionsErrorWorkaround');
        // The actual FunctionsError object (if it were caught by type) has e.message, e.details, e.context
      }
      throw Exception('Failed to estimate nutrition from image: $errorMessage');
    }
  }
}
