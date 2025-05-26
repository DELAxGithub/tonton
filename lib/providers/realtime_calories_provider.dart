import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_summary.dart';
import '../services/daily_summary_service.dart';
import 'monthly_progress_provider.dart';
import 'providers.dart';

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
final realtimeDailySummaryProvider = FutureProvider<DailySummary>((ref) async {
  final service = ref.watch(dailySummaryServiceProvider);
  return service.getDailySummary(DateTime.now());
});

/// Net calories for today in real time.
final realtimeNetCaloriesProvider = Provider<double>((ref) {
  final summaryAsync = ref.watch(realtimeDailySummaryProvider);
  return summaryAsync.maybeWhen(
    data: (s) => s.netCalories,
    orElse: () => 0.0,
  );
});
