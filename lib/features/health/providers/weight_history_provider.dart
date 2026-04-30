import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/monthly_progress_provider.dart';
import '../../../core/providers/onboarding_start_date_provider.dart';
import '../../../models/weight_record.dart';

part 'weight_history_provider.g.dart';

/// HealthKit から onboardingStartDate 〜 今日の体重履歴を取得し、
/// 同日複数測定はその日の最新 1 件に丸めて日付昇順で返す。
/// startDate が未設定なら空リストを返す（理想ペースも引けないため）。
@riverpod
Future<List<WeightRecord>> weightHistory(Ref ref) async {
  final startDate = ref.watch(onboardingStartDateProvider);
  if (startDate == null) return [];

  final service = ref.watch(healthServiceProvider);
  final raw = await service.getWeightHistory(startDate, DateTime.now());

  final byDay = <String, WeightRecord>{};
  for (final r in raw) {
    final key = '${r.date.year}-${r.date.month}-${r.date.day}';
    final existing = byDay[key];
    if (existing == null || r.date.isAfter(existing.date)) {
      byDay[key] = r;
    }
  }
  final result = byDay.values.toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return result;
}
