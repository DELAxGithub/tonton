import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'meal_records_provider.dart';

part 'recent_intake_average_provider.g.dart';

const _windowDays = 14;
const _minActiveDays = 3;

/// 直近 [_windowDays] 日の摂取カロリー平均を返す（日単位で合算してから平均）。
/// 0 kcal の日は除外し、有効日数が [_minActiveDays] 未満なら null を返す。
/// null のときは呼び出し側で別の fallback（プロフィール由来 or デフォルト）を当てること。
@riverpod
double? recentIntakeAverage(Ref ref) {
  final asyncState = ref.watch(mealRecordsProvider);
  return asyncState.maybeWhen(
    data: (state) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final windowStart = today.subtract(const Duration(days: _windowDays));

      final byDate = <DateTime, double>{};
      for (final record in state.records) {
        final consumed = record.consumedAt.toLocal();
        final key = DateTime(consumed.year, consumed.month, consumed.day);
        if (key.isBefore(windowStart)) continue;
        if (key.isAfter(today)) continue;
        byDate.update(
          key,
          (v) => v + record.calories,
          ifAbsent: () => record.calories,
        );
      }

      final activeDayKcal = byDate.values.where((v) => v > 0).toList();
      if (activeDayKcal.length < _minActiveDays) return null;
      final total = activeDayKcal.fold<double>(0, (s, v) => s + v);
      return total / activeDayKcal.length;
    },
    orElse: () => null,
  );
}
