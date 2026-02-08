import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'package:path/path.dart' as p;

import '../models/estimated_meal_nutrition.dart';
import '../models/nutrient_info.dart';

class DirectGeminiService {
  static String? _apiKey;

  static String get apiKey {
    if (_apiKey != null) return _apiKey!;

    // Try to get from environment variables first
    _apiKey = dotenv.env['GEMINI_API_KEY'];

    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception(
        'Gemini API key not found. Please set GEMINI_API_KEY in .env file',
      );
    }

    return _apiKey!;
  }

  Future<EstimatedMealNutrition?> analyzeImage(Uint8List imageBytes, {String mimeType = 'image/jpeg'}) async {
    try {
      developer.log(
        'Starting Gemini image analysis',
        name: 'TonTon.DirectGeminiService',
      );

      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
      );

      final prompt = '''
あなたは専門の栄養士です。
提供された食事の画像を分析し、含まれている食品を特定して、各食品の栄養情報を推定してください。

応答は以下のJSON形式で厳密に出力してください：
{
  "items": [
    {
      "name": "食品名",
      "calories": 100,
      "protein_g": 10,
      "fat_g": 5,
      "carbs_g": 5
    }
  ],
  "total_calories": 100
}

注意事項：
- 食品名は日本語で記載
- カロリーと栄養素は整数値
- total_caloriesは全食品のカロリーの合計値
- JSONのみを出力し、他の説明文は含めない
''';

      final content = [
        Content.multi([TextPart(prompt), DataPart(mimeType, imageBytes)]),
      ];

      developer.log('Calling Gemini API', name: 'TonTon.DirectGeminiService');
      final response = await model.generateContent(content);
      final responseText = response.text;

      if (responseText != null) {
        developer.log(
          'Received response from Gemini',
          name: 'TonTon.DirectGeminiService',
        );

        // Extract JSON from response using regex (same as POC)
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(responseText);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          developer.log(
            'Extracted JSON: $jsonString',
            name: 'TonTon.DirectGeminiService',
          );

          final result = json.decode(jsonString);

          // Convert to EstimatedMealNutrition format
          return convertToEstimatedMealNutrition(result);
        } else {
          developer.log(
            'No JSON found in response: $responseText',
            name: 'TonTon.DirectGeminiService.Error',
          );
          throw Exception('JSONレスポンスが見つかりませんでした');
        }
      } else {
        developer.log(
          'Empty response from Gemini',
          name: 'TonTon.DirectGeminiService.Error',
        );
        throw Exception('レスポンスが空でした');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error in DirectGeminiService: $e',
        name: 'TonTon.DirectGeminiService.Exception',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  EstimatedMealNutrition convertToEstimatedMealNutrition(
    Map<String, dynamic> geminiResult,
  ) {
    // Convert Gemini format to TonTon's EstimatedMealNutrition format
    final items = geminiResult['items'] as List<dynamic>? ?? [];

    // Calculate totals
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    List<String> mealNames = [];

    for (var item in items) {
      final calories = (item['calories'] as num?)?.toDouble() ?? 0.0;
      final protein = (item['protein_g'] as num?)?.toDouble() ?? 0.0;
      final fat = (item['fat_g'] as num?)?.toDouble() ?? 0.0;
      final carbs = (item['carbs_g'] as num?)?.toDouble() ?? 0.0;

      totalCalories += calories;
      totalProtein += protein;
      totalFat += fat;
      totalCarbs += carbs;

      mealNames.add(item['name'] ?? '不明な食品');
    }

    return EstimatedMealNutrition(
      mealName: mealNames.join(', '),
      description: '画像から解析された食事: ${mealNames.length}品目',
      calories: totalCalories,
      nutrients: NutrientInfo(
        protein: totalProtein,
        fat: totalFat,
        carbs: totalCarbs,
      ),
    );
  }

  Future<EstimatedMealNutrition?> analyzeImageFile(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final mimeType = _detectMimeType(imageFile.path);
      developer.log(
        'Image file: ${imageFile.path}, size: ${imageBytes.length} bytes, mime: $mimeType',
        name: 'TonTon.DirectGeminiService',
      );
      return await analyzeImage(imageBytes, mimeType: mimeType);
    } catch (e, stackTrace) {
      developer.log(
        'Error reading image file: $e',
        name: 'TonTon.DirectGeminiService.FileError',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  String _detectMimeType(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    switch (ext) {
      case '.png':
        return 'image/png';
      case '.heic':
      case '.heif':
        return 'image/heic';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
