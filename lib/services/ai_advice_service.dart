import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import '../models/ai_advice_request.dart';
import '../models/ai_advice_response.dart';
import '../models/user_profile.dart';

class AiAdviceService {
  final SupabaseClient _supabaseClient;

  AiAdviceService(this._supabaseClient);

  /// JSONレスポンスをサニタイズしてパースする
  Map<String, dynamic> _sanitizeAndParseJson(dynamic data) {
    if (data is String) {
      try {
        // 余分な文字を除去
        String jsonString = data.trim();
        // 末尾の不正な文字を削除（position 777エラー対策）
        if (jsonString.contains('}')) {
          // 最後の有効な}までを取得
          int braceCount = 0;
          int lastValidIndex = -1;
          for (int i = 0; i < jsonString.length; i++) {
            if (jsonString[i] == '{')
              braceCount++;
            else if (jsonString[i] == '}') {
              braceCount--;
              if (braceCount == 0) {
                lastValidIndex = i;
                break;
              }
            }
          }
          if (lastValidIndex > -1) {
            jsonString = jsonString.substring(0, lastValidIndex + 1);
          }
        }
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        developer.log('JSON parse error: $e', name: 'TonTon.AiAdviceService');
        developer.log('Raw response: $data', name: 'TonTon.AiAdviceService');
        throw Exception("Failed to parse JSON response: $e");
      }
    } else if (data is Map<String, dynamic>) {
      return data;
    } else {
      throw Exception("Unexpected response type: ${data.runtimeType}");
    }
  }

  Future<AiAdviceResponse> getMealAdvice(AiAdviceRequest request) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'generate-meal-advice-v2',
        body: request.toJson(),
      );

      if (response.status != 200) {
        // Attempt to parse error message from function
        String errorMessage =
            "Failed to get meal advice. Status code: ${response.status}";
        if (response.data != null && response.data['error'] != null) {
          errorMessage = response.data['error'].toString();
        } else if (response.data != null) {
          errorMessage = response.data.toString();
        }
        throw Exception(errorMessage);
      }

      if (response.data == null) {
        throw Exception("Received null data from meal advice function.");
      }

      final jsonData = _sanitizeAndParseJson(response.data);

      // デバッグ: レスポンスの内容を確認
      developer.log(
        'AI Advice Response: ${json.encode(jsonData)}',
        name: 'TonTon.AiAdviceService',
      );
      if (jsonData['menuSuggestion'] != null) {
        developer.log(
          'menuSuggestion found: ${json.encode(jsonData['menuSuggestion'])}',
          name: 'TonTon.AiAdviceService',
        );
      } else {
        developer.log('menuSuggestion is null', name: 'TonTon.AiAdviceService');
      }

      return AiAdviceResponse.fromJson(jsonData);
    } on FunctionException catch (e) {
      // This can catch more specific Supabase function errors
      final errorMessage = e.details?.toString() ?? e.toString();
      developer.log(
        'Supabase FunctionException: $errorMessage',
        name: 'TonTon.AiAdviceService',
      );
      developer.log(
        'Details: ${e.details}',
        name: 'TonTon.AiAdviceService',
      ); // Log details which might contain response info

      String detailedMessage = "Error calling meal advice function";
      if (e.details != null) {
        detailedMessage += " Details: ${e.details}";
      } else {
        detailedMessage +=
            " Details: ${e.toString()}"; // Fallback to e.toString() if details is null
      }
      throw Exception("Supabase function error: $detailedMessage");
    } catch (e) {
      developer.log(
        'Error in AiAdviceService.getMealAdvice: $e',
        name: 'TonTon.AiAdviceService',
        error: e,
      );
      throw Exception(
        "An unexpected error occurred while fetching meal advice: ${e.toString()}",
      );
    }
  }

  /// 拡張版：ユーザーコンテキストを含めたアドバイス生成
  Future<AiAdviceResponse> generateMealAdvice({
    required AiAdviceRequest request,
    UserProfile? userProfile,
    Map<String, dynamic>? weeklyTrend,
    DateTime? currentTime,
  }) async {
    try {
      // 時間帯を判定
      final hour = (currentTime ?? DateTime.now()).hour;
      String timeOfDay;
      if (hour < 11) {
        timeOfDay = 'morning';
      } else if (hour < 15) {
        timeOfDay = 'lunch';
      } else if (hour < 20) {
        timeOfDay = 'dinner';
      } else {
        timeOfDay = 'evening';
      }

      // リクエストデータにコンテキストを追加
      final enhancedRequest = {
        ...request.toJson(),
        'userContext': {
          'timeOfDay': timeOfDay,
          'gender': userProfile?.gender,
          'ageGroup': userProfile?.ageGroup,
          'weight': userProfile?.weight,
          'weeklyTrend': weeklyTrend,
        },
      };

      final response = await _supabaseClient.functions.invoke(
        'generate-meal-advice-v2',
        body: enhancedRequest,
      );

      if (response.status != 200) {
        String errorMessage =
            "Failed to generate meal advice. Status code: ${response.status}";
        if (response.data != null && response.data['error'] != null) {
          errorMessage = response.data['error'].toString();
        }
        throw Exception(errorMessage);
      }

      if (response.data == null) {
        throw Exception("Received null data from meal advice function.");
      }

      final jsonData = _sanitizeAndParseJson(response.data);

      // デバッグ: レスポンスの内容を確認
      developer.log(
        'AI Advice Response: ${json.encode(jsonData)}',
        name: 'TonTon.AiAdviceService',
      );
      if (jsonData['menuSuggestion'] != null) {
        developer.log(
          'menuSuggestion found: ${json.encode(jsonData['menuSuggestion'])}',
          name: 'TonTon.AiAdviceService',
        );
      } else {
        developer.log('menuSuggestion is null', name: 'TonTon.AiAdviceService');
      }

      return AiAdviceResponse.fromJson(jsonData);
    } on FunctionException catch (e) {
      developer.log(
        'Supabase FunctionException: ${e.details}',
        name: 'TonTon.AiAdviceService',
      );
      throw Exception("Supabase function error: ${e.details ?? e.toString()}");
    } catch (e) {
      developer.log(
        'Error in generateMealAdvice: $e',
        name: 'TonTon.AiAdviceService',
        error: e,
      );
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }
}
