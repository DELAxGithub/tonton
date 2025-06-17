import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

import '../../models/monthly_progress_summary.dart';
import '../../models/daily_calorie_summary.dart';
import '../../services/calorie_calculation_service.dart';
import '../../repositories/user_settings_repository.dart';
import '../../services/health_service.dart';
import '../../features/meal_logging/providers/meal_records_provider.dart';
import 'calorie_savings_provider.dart';
import 'onboarding_start_date_provider.dart';

part 'monthly_progress_provider.g.dart';

// Provider for health service
@riverpod
HealthService healthService(Ref ref) {
  return HealthService();
}

// Provider for user settings repository
@riverpod
UserSettingsRepository userSettingsRepository(Ref ref) {
  return UserSettingsRepository();
}

// Provider for calorie calculation service
@riverpod
CalorieCalculationService calorieCalculationService(Ref ref) {
  final healthService = ref.watch(healthServiceProvider);
  final mealRecords = ref.read(mealRecordsProvider.notifier);

  return CalorieCalculationService(
    healthService: healthService,
    mealRecordsProvider: mealRecords,
  );
}

// Provider for monthly target (from settings)
@riverpod
Future<double> monthlyTarget(Ref ref) async {
  final repository = ref.watch(userSettingsRepositoryProvider);
  return repository.getMonthlyTargetNetBurn();
}

// Provider for daily calorie summary (can be used for any date)
@riverpod
Future<DailyCalorieSummary> dailyCalorieSummary(Ref ref, DateTime date) async {
  developer.log(
    'dailyCalorieSummaryProvider called for date: $date',
    name: 'TonTon.MonthlyProgressProvider',
  );
  final service = ref.watch(calorieCalculationServiceProvider);
  return service.calculateDailyCalorieSummary(date);
}

// Provider for today's calorie summary (convenience)
@riverpod
Future<DailyCalorieSummary> todayCalorieSummary(Ref ref) async {
  developer.log(
    'todayCalorieSummaryProvider called',
    name: 'TonTon.MonthlyProgressProvider',
  );
  final date = DateTime.now();
  return ref.watch(dailyCalorieSummaryProvider(date).future);
}

// Provider for monthly progress summary
@riverpod
Future<MonthlyProgressSummary> monthlyProgressSummary(Ref ref) async {
  developer.log(
    'monthlyProgressSummaryProvider called',
    name: 'TonTon.MonthlyProgressProvider',
  );
  final service = ref.watch(calorieCalculationServiceProvider);
  final target = await ref.watch(monthlyTargetProvider.future);
  final startDate = ref.watch(onboardingStartDateProvider);

  return service.calculateMonthlyProgressSummary(
    targetMonthlyNetBurn: target,
    startDate: startDate,
  );
}

/// Average daily calorie savings over the past 7 days.
final weeklyAverageSavingsProvider = Provider<double>((ref) {
  final recordsAsync = ref.watch(calorieSavingsDataProvider);
  return recordsAsync.maybeWhen(
    data: (records) {
      if (records.isEmpty) return 0.0;
      final recent = records.reversed.take(7).toList();
      final total = recent.fold<double>(0, (sum, r) => sum + r.dailyBalance);
      return total / recent.length;
    },
    orElse: () => 0.0,
  );
});

// Provider to update the monthly calorie target
@riverpod
class MonthlyTargetNotifier extends _$MonthlyTargetNotifier {
  @override
  FutureOr<double> build() async {
    final repository = ref.watch(userSettingsRepositoryProvider);
    return repository.getMonthlyTargetNetBurn();
  }

  Future<bool> updateTarget(double newTarget) async {
    developer.log(
      'Updating monthly target to $newTarget',
      name: 'TonTon.MonthlyProgressProvider',
    );
    final repository = ref.read(userSettingsRepositoryProvider);
    final success = await repository.setMonthlyTargetNetBurn(newTarget);

    if (success) {
      // Refresh the state with the new value
      state = AsyncValue.data(newTarget);

      // Invalidate the monthlyProgressSummary provider to recalculate with new target
      ref.invalidate(monthlyProgressSummaryProvider);
    }

    return success;
  }

  Future<bool> resetToDefault() async {
    developer.log(
      'Resetting monthly target to default',
      name: 'TonTon.MonthlyProgressProvider',
    );
    final repository = ref.read(userSettingsRepositoryProvider);
    final success = await repository.resetMonthlyTargetNetBurn();

    if (success) {
      // Refresh the state with the new default value
      final defaultValue = await repository.getMonthlyTargetNetBurn();
      state = AsyncValue.data(defaultValue);

      // Invalidate the monthlyProgressSummary provider to recalculate with new target
      ref.invalidate(monthlyProgressSummaryProvider);
    }

    return success;
  }
}
