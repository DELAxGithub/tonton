import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/pfc_breakdown.dart';
import '../../../utils/pfc_calculator.dart';
import '../../profile/providers/user_profile_provider.dart';

/// Provider that automatically calculates PFC targets based on user profile
final autoPfcTargetProvider = Provider<PfcBreakdown?>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  
  // If weight is not set, cannot calculate
  if (userProfile.weight == null) {
    return null;
  }
  
  return PFCCalculator.calculateAutomatic(
    weight: userProfile.weight!,
    gender: userProfile.gender,
    ageGroup: userProfile.ageGroup,
  );
});

/// Provider for daily calorie target based on user profile
final dailyCalorieTargetProvider = Provider<int>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  
  // Get recommended calories based on profile
  int recommendedCalories = PFCCalculator.defaultRecommendedCalories;
  
  if (userProfile.gender != null && userProfile.ageGroup != null) {
    recommendedCalories = PFCCalculator.calorieMatrix[userProfile.ageGroup]?[userProfile.gender] 
        ?? PFCCalculator.defaultRecommendedCalories;
  }
  
  // Return target calories (recommended - savings)
  return recommendedCalories - PFCCalculator.dailySavingsTarget;
});