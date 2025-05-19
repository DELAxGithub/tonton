import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

/// Repository for managing user settings and goals
class UserSettingsRepository {
  static const String _monthlyTargetKey = 'monthly_target_calories';
  static const double _defaultMonthlyTarget = 14400; // Default: ~0.5kg weight loss per month (500 cal/day)
  
  /// Get the monthly target net calorie burn
  /// Returns the saved target or a default value if not set
  Future<double> getMonthlyTargetNetBurn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final target = prefs.getDouble(_monthlyTargetKey);
      
      if (target != null) {
        developer.log('Retrieved monthly target: $target kcal', name: 'TonTon.UserSettingsRepository');
        return target;
      } else {
        developer.log('No monthly target set, using default: $_defaultMonthlyTarget kcal', name: 'TonTon.UserSettingsRepository');
        return _defaultMonthlyTarget;
      }
    } catch (e, stack) {
      developer.log(
        'Error getting monthly target: $e', 
        name: 'TonTon.UserSettingsRepository.error',
        error: e,
        stackTrace: stack
      );
      return _defaultMonthlyTarget;
    }
  }
  
  /// Set the monthly target net calorie burn
  Future<bool> setMonthlyTargetNetBurn(double target) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setDouble(_monthlyTargetKey, target);
      
      if (success) {
        developer.log('Set monthly target to: $target kcal', name: 'TonTon.UserSettingsRepository');
      } else {
        developer.log('Failed to set monthly target', name: 'TonTon.UserSettingsRepository');
      }
      
      return success;
    } catch (e, stack) {
      developer.log(
        'Error setting monthly target: $e', 
        name: 'TonTon.UserSettingsRepository.error',
        error: e,
        stackTrace: stack
      );
      return false;
    }
  }
  
  /// Reset the monthly target to the default value
  Future<bool> resetMonthlyTargetNetBurn() async {
    return await setMonthlyTargetNetBurn(_defaultMonthlyTarget);
  }
}