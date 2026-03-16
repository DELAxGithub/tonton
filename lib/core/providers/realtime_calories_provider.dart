import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/daily_summary.dart';
import '../../models/weight_record.dart';
import '../../services/daily_summary_service.dart';
import '../../providers/providers.dart';

/// Provides an instance of [DailySummaryService].
final dailySummaryServiceProvider = Provider<DailySummaryService>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  final mealRecords = ref.read(mealRecordsProvider.notifier);
  final dataService = ref.read(dailySummaryDataServiceProvider);
  return DailySummaryService(
    healthService: healthService,
    mealRecords: mealRecords,
    dataService: dataService,
  );
});

/// Real-time summary for today based on meal records and HealthKit data.
/// Also syncs the latest HealthKit weight to profile providers.
final realtimeDailySummaryProvider = FutureProvider<DailySummary>((ref) async {
  final service = ref.watch(dailySummaryServiceProvider);
  final summary = await service.getDailySummary(DateTime.now());

  // Sync HealthKit weight to profile providers so the profile screen
  // always shows the latest value without manual input.
  if (summary.weight != null) {
    final record = WeightRecord(
      weight: summary.weight!,
      date: summary.date,
      bodyFatPercentage: summary.bodyFatPercentage,
    );
    ref.read(latestWeightRecordProvider.notifier).setRecord(record);
    ref.read(userWeightProvider.notifier).setWeight(summary.weight!);
  }

  return summary;
});

/// Net calories for today in real time.
final realtimeNetCaloriesProvider = Provider<double>((ref) {
  final summaryAsync = ref.watch(realtimeDailySummaryProvider);
  return summaryAsync.maybeWhen(data: (s) => s.netCalories, orElse: () => 0.0);
});
