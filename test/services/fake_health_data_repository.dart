import 'package:tonton/models/activity_summary.dart';
import 'package:tonton/models/weight_record.dart';
import 'package:tonton/services/health_data_repository.dart';

/// In-memory deterministic fake of [HealthDataRepository] for tests.
///
/// Each method returns a value pre-populated via the corresponding setter.
/// Defaults are minimal but valid: `permissionsGranted = true`,
/// empty `ActivitySummary`, `null` latest weight, empty history.
class FakeHealthDataRepository implements HealthDataRepository {
  bool permissionsGranted;
  ActivitySummary todaySummary;
  Map<DateTime, ActivitySummary> summariesByDate;
  WeightRecord? latestWeight;
  Map<DateTime, WeightRecord> latestWeightByDate;
  List<WeightRecord> weightHistory;

  int requestPermissionsCallCount = 0;
  int getTodayActivitySummaryCallCount = 0;
  int getActivitySummaryCallCount = 0;
  int getLatestWeightCallCount = 0;
  int getWeightHistoryCallCount = 0;

  FakeHealthDataRepository({
    this.permissionsGranted = false,
    ActivitySummary? todaySummary,
    Map<DateTime, ActivitySummary>? summariesByDate,
    this.latestWeight,
    Map<DateTime, WeightRecord>? latestWeightByDate,
    List<WeightRecord>? weightHistory,
  }) : todaySummary = todaySummary ??
            ActivitySummary(
              workoutTypes: const [],
              workoutCalories: 0,
              totalCalories: 0,
            ),
        summariesByDate = summariesByDate ?? <DateTime, ActivitySummary>{},
        latestWeightByDate =
            latestWeightByDate ?? <DateTime, WeightRecord>{},
        weightHistory = weightHistory ?? <WeightRecord>[];

  static DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Future<bool> requestPermissions() async {
    requestPermissionsCallCount++;
    return permissionsGranted;
  }

  @override
  Future<ActivitySummary> getTodayActivitySummary() async {
    getTodayActivitySummaryCallCount++;
    return todaySummary;
  }

  @override
  Future<ActivitySummary> getActivitySummary(DateTime date) async {
    getActivitySummaryCallCount++;
    final key = _dayKey(date);
    return summariesByDate[key] ??
        ActivitySummary(
          workoutTypes: const [],
          workoutCalories: 0,
          totalCalories: 0,
        );
  }

  @override
  Future<WeightRecord?> getLatestWeight(DateTime date) async {
    getLatestWeightCallCount++;
    final key = _dayKey(date);
    return latestWeightByDate[key] ?? latestWeight;
  }

  @override
  Future<List<WeightRecord>> getWeightHistory(
    DateTime start,
    DateTime end,
  ) async {
    getWeightHistoryCallCount++;
    final endOfDay =
        DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    final startOfDay = DateTime(start.year, start.month, start.day);
    return weightHistory
        .where((r) =>
            !r.date.isBefore(startOfDay) && !r.date.isAfter(endOfDay))
        .toList();
  }
}
