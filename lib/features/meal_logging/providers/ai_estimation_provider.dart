import 'dart:io'; // For File type
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/estimated_meal_nutrition.dart';
import '../../../services/ai_service.dart';
import '../../../services/direct_gemini_service.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

final directGeminiServiceProvider = Provider<DirectGeminiService>((ref) {
  return DirectGeminiService();
});

enum AIEstimationState { initial, loading, success, error }

class AIEstimationNotifier
    extends StateNotifier<AsyncValue<EstimatedMealNutrition?>> {
  final AIService _aiService;
  final DirectGeminiService _directGeminiService;

  AIEstimationNotifier(this._aiService, this._directGeminiService)
    : super(const AsyncValue.data(null));

  Future<void> estimateNutrition(String mealDescription) async {
    if (mealDescription.isEmpty) return;

    state = const AsyncValue.loading();

    try {
      final result = await _aiService.estimateNutritionFromText(
        mealDescription,
      );
      if (result != null) {
        state = AsyncValue.data(result);
      } else {
        state = AsyncValue.error(
          'Failed to estimate nutrition',
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }

  // Updated to use DirectGeminiService instead of Edge Functions
  // This directly calls the Gemini API without going through Supabase Edge Functions
  Future<EstimatedMealNutrition?> estimateNutritionFromImageFile(
    File imageFile,
  ) async {
    state = const AsyncValue.loading();
    try {
      // Use DirectGeminiService for direct API calls (POC success pattern)
      final result = await _directGeminiService.analyzeImageFile(imageFile);
      if (result != null) {
        state = AsyncValue.data(result);
        return result;
      } else {
        state = AsyncValue.error(
          'Failed to get nutrition data from image.',
          StackTrace.current,
        );
        return null;
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }
}

final aiEstimationProvider = StateNotifierProvider<
  AIEstimationNotifier,
  AsyncValue<EstimatedMealNutrition?>
>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final directGeminiService = ref.watch(directGeminiServiceProvider);
  return AIEstimationNotifier(aiService, directGeminiService);
});
