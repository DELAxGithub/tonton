import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/progress/providers/pfc_balance_provider.dart';
import 'calorie_savings_provider.dart';
import 'diagnosis_logic.dart';

/// Final diagnosis for the current user state. Null if no data yet.
final diagnosisProvider = Provider<DiagnosisResult?>((ref) {
  final summariesAsync = ref.watch(dailySummariesProvider);
  final goals = ref.watch(userGoalsProvider);

  return summariesAsync.maybeWhen(
    data: (summaries) {
      if (summaries.isEmpty) return null;
      final weightKg = goals.bodyWeightKg;
      if (weightKg == null) return null;

      final periodDays = summaries.length;
      final totalDailyDeficit = summaries.fold<double>(
        0,
        (sum, s) => sum + (s.caloriesBurned - s.caloriesConsumed),
      );
      final avgDaily = periodDays == 0 ? 0.0 : totalDailyDeficit / periodDays;

      final weighted = summaries.where((s) => s.weight != null).toList();
      final double? startWeight =
          weighted.isNotEmpty ? weighted.first.weight : null;
      final double? currentWeight =
          weighted.isNotEmpty ? weighted.last.weight : null;
      final withBf =
          summaries.where((s) => s.bodyFatPercentage != null).toList();
      final double? startBf =
          withBf.isNotEmpty ? withBf.first.bodyFatPercentage : null;
      final double? currentBf =
          withBf.isNotEmpty ? withBf.last.bodyFatPercentage : null;

      final input = DiagnosisInput(
        periodDays: periodDays,
        weightKg: weightKg,
        dailyDeficitGoalKcal: goals.dailyDeficitGoalKcal,
        averageDailyActualDeficitKcal: avgDaily,
        targetWeeklyPercentLoss: goals.targetWeeklyPercentLoss,
        startWeightKg: startWeight,
        currentWeightKg: currentWeight,
        startBodyFatPercent: startBf,
        currentBodyFatPercent: currentBf,
      );
      return runDiagnosis(input);
    },
    orElse: () => null,
  );
});
