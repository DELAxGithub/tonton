import 'dart:io'; // For File type
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/estimated_meal_nutrition.dart';
import '../services/ai_service.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

enum AIEstimationState { initial, loading, success, error }

class AIEstimationNotifier extends StateNotifier<AsyncValue<EstimatedMealNutrition?>> {
  final AIService _aiService;
  
  AIEstimationNotifier(this._aiService) : super(const AsyncValue.data(null));
  
  Future<void> estimateNutrition(String mealDescription) async {
    if (mealDescription.isEmpty) return;

    state = const AsyncValue.loading();
    
    try {
      final result = await _aiService.estimateNutritionFromText(mealDescription);
      if (result != null) {
        state = AsyncValue.data(result);
      } else {
        state = AsyncValue.error('Failed to estimate nutrition', StackTrace.current);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  void reset() {
    state = const AsyncValue.data(null);
  }

  // Updated to use the new AIService.estimateNutritionFromImageFile method
  // which directly processes the image file with Gemini via an Edge Function.
  // The userId parameter is removed as it's not directly needed for this analysis step.
  // Image upload for record persistence will be handled separately.
  Future<EstimatedMealNutrition?> estimateNutritionFromImageFile(File imageFile) async {
    state = const AsyncValue.loading();
    try {
      // Call the new AIService method that sends the image file directly
      final result = await _aiService.estimateNutritionFromImageFile(imageFile);
      if (result != null) {
        state = AsyncValue.data(result);
        return result;
      } else {
        // This case might occur if the service method itself returns null without throwing
        // or if the Gemini function returns a valid response that results in null (e.g. no food detected)
        state = AsyncValue.error('Failed to get nutrition data from image.', StackTrace.current);
        return null;
      }
    } catch (e, stackTrace) {
      // This will catch errors thrown by _aiService.estimateNutritionFromImageFile
      // (e.g., network issues, Edge Function errors, parsing errors)
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }
}

final aiEstimationProvider = StateNotifierProvider<AIEstimationNotifier, AsyncValue<EstimatedMealNutrition?>>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return AIEstimationNotifier(aiService);
});
