import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/calorie_savings_provider.dart';
import '../../progress/providers/auto_pfc_provider.dart';

/// 「推定で埋める」ボタンのベースとなる日次カロリー。
/// 直近7日に実測された食事記録の平均を使い、データが無ければ目標カロリーに
/// フォールバックする。
final estimationBaseCaloriesProvider = Provider<double>((ref) {
  final summariesAsync = ref.watch(dailySummariesProvider);
  final dailyTarget = ref.watch(dailyCalorieTargetProvider).toDouble();

  return summariesAsync.maybeWhen(
    data: (summaries) {
      // 直近7件で caloriesConsumed > 50 のものだけを使って平均
      final recent = summaries.reversed
          .take(14) // 余裕をもって14件走査
          .where((s) => s.caloriesConsumed > 50)
          .take(7)
          .toList();
      if (recent.isEmpty) return dailyTarget;
      final total = recent.fold<double>(
        0,
        (sum, s) => sum + s.caloriesConsumed,
      );
      return total / recent.length;
    },
    orElse: () => dailyTarget,
  );
});
