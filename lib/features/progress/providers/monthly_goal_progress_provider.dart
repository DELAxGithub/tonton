import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/calorie_savings_provider.dart';

part 'monthly_goal_progress_provider.g.dart';

/// 月内のペース判定。経過日数で按分した期待ラインと実績の比率で決まる。
enum MonthlyPace {
  onTrack,         // ペース通り or 上回り (≥ 1.0)
  slightlyBehind,  // やや遅れ (0.7 - 1.0)
  wayBehind,       // 大きく遅れ (< 0.7)
  notStarted,      // 経過日数 0（月初未スタート想定の保険）
}

class MonthlyGoalProgress {
  final double goalKcal;
  final double actualKcal;
  /// 達成率 (actualKcal / goalKcal)。100% を超える場合あり、上限カットなし。
  final double progressRatio;
  /// ペース率 (actualKcal / expectedKcal)。`expectedKcal` は経過日数で按分した期待ライン。
  final double paceRatio;
  final int daysElapsed;
  final int daysInMonth;
  final int daysRemaining;
  final MonthlyPace pace;
  final DateTime monthStart;
  final DateTime monthEnd;

  const MonthlyGoalProgress({
    required this.goalKcal,
    required this.actualKcal,
    required this.progressRatio,
    required this.paceRatio,
    required this.daysElapsed,
    required this.daysInMonth,
    required this.daysRemaining,
    required this.pace,
    required this.monthStart,
    required this.monthEnd,
  });

  double get remainingKcal => (goalKcal - actualKcal).clamp(0, double.infinity);
}

@riverpod
MonthlyGoalProgress monthlyGoalProgress(Ref ref) {
  final recordsAsync = ref.watch(calorieSavingsDataProvider);
  final goal = ref.watch(monthlyCalorieGoalProvider);

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  // month + 1 day 0 = 当月末日
  final monthEnd = DateTime(now.year, now.month + 1, 0);
  final daysInMonth = monthEnd.day;
  final daysElapsed = now.day; // 1-based、当日含む
  final daysRemaining = daysInMonth - daysElapsed;

  final actual = recordsAsync.maybeWhen(
    data: (records) => records
        .where((r) => !r.date.isBefore(monthStart))
        .fold<double>(0, (s, r) => s + r.dailyBalance),
    orElse: () => 0.0,
  );

  final progressRatio = goal > 0 ? actual / goal : 0.0;
  final expected = goal * (daysElapsed / daysInMonth);

  final MonthlyPace pace;
  final double paceRatio;
  if (daysElapsed <= 0 || expected <= 0) {
    pace = MonthlyPace.notStarted;
    paceRatio = 0.0;
  } else {
    paceRatio = actual / expected;
    if (paceRatio >= 1.0) {
      pace = MonthlyPace.onTrack;
    } else if (paceRatio >= 0.7) {
      pace = MonthlyPace.slightlyBehind;
    } else {
      pace = MonthlyPace.wayBehind;
    }
  }

  return MonthlyGoalProgress(
    goalKcal: goal,
    actualKcal: actual,
    progressRatio: progressRatio,
    paceRatio: paceRatio,
    daysElapsed: daysElapsed,
    daysInMonth: daysInMonth,
    daysRemaining: daysRemaining,
    pace: pace,
    monthStart: monthStart,
    monthEnd: monthEnd,
  );
}
