import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tonton/core/providers/health_repository_provider.dart';
import 'package:tonton/models/activity_summary.dart';
import 'package:tonton/models/weight_record.dart';
import 'package:tonton/services/health_data_repository.dart';

import 'fake_health_data_repository.dart';

void main() {
  // HealthService is intentionally not instantiated in tests: its
  // `Health()` dependency requires platform channels and would hang in
  // `flutter test`. Type compatibility for HealthService is asserted at
  // compile time via `implements HealthDataRepository` in
  // health_service.dart, which is what the abstract contract guarantees.

  group('FakeHealthDataRepository', () {
    test('returns configured permissions and tracks call count', () async {
      final fake = FakeHealthDataRepository(permissionsGranted: false);
      expect(await fake.requestPermissions(), isFalse);
      expect(fake.requestPermissionsCallCount, equals(1));
    });

    test('defaults permissionsGranted to false (safe default for PII)',
        () async {
      final fake = FakeHealthDataRepository();
      expect(await fake.requestPermissions(), isFalse);
    });

    test('returns configured today summary', () async {
      final summary = ActivitySummary(
        workoutTypes: const ['Running'],
        workoutCalories: 250,
        totalCalories: 2200,
      );
      final fake = FakeHealthDataRepository(todaySummary: summary);
      final result = await fake.getTodayActivitySummary();
      expect(result.workoutCalories, equals(250));
      expect(result.workoutTypes, equals(['Running']));
    });

    test('getActivitySummary returns date-specific value when configured',
        () async {
      final targetDate = DateTime(2026, 5, 27);
      final specific = ActivitySummary(
        workoutTypes: const ['Cycling'],
        workoutCalories: 400,
        totalCalories: 2400,
      );
      final fake = FakeHealthDataRepository(
        summariesByDate: {targetDate: specific},
      );
      final result = await fake.getActivitySummary(targetDate);
      expect(result.workoutCalories, equals(400));
      expect(result.workoutTypes, equals(['Cycling']));
    });

    test('getActivitySummary returns empty summary when date not configured',
        () async {
      final fake = FakeHealthDataRepository();
      final result = await fake.getActivitySummary(DateTime(2026, 5, 27));
      expect(result.workoutTypes, isEmpty);
      expect(result.workoutCalories, equals(0));
      expect(result.totalCalories, equals(0));
    });

    test('getLatestWeight returns configured value or null', () async {
      final emptyFake = FakeHealthDataRepository();
      expect(await emptyFake.getLatestWeight(DateTime(2026, 5, 27)), isNull);

      final withWeight = FakeHealthDataRepository(
        latestWeight: WeightRecord(
          weight: 72.5,
          date: DateTime(2026, 5, 27),
          bodyFatPercentage: 0.18,
          bodyFatMass: 13.05,
        ),
      );
      final record = await withWeight.getLatestWeight(DateTime(2026, 5, 27));
      expect(record, isNotNull);
      expect(record!.weight, equals(72.5));
      expect(record.bodyFatPercentage, equals(0.18));
    });

    test('getLatestWeight respects per-date map when configured', () async {
      final dayA = DateTime(2026, 5, 25);
      final dayB = DateTime(2026, 5, 27);
      final fake = FakeHealthDataRepository(
        latestWeightByDate: {
          dayA: WeightRecord(weight: 73.0, date: dayA),
          dayB: WeightRecord(weight: 72.0, date: dayB),
        },
      );
      expect((await fake.getLatestWeight(dayA))!.weight, equals(73.0));
      expect((await fake.getLatestWeight(dayB))!.weight, equals(72.0));
    });

    test('getWeightHistory filters by date range', () async {
      final fake = FakeHealthDataRepository(
        weightHistory: [
          WeightRecord(weight: 73.0, date: DateTime(2026, 5, 20)),
          WeightRecord(weight: 72.5, date: DateTime(2026, 5, 25)),
          WeightRecord(weight: 72.0, date: DateTime(2026, 5, 27)),
        ],
      );
      final result = await fake.getWeightHistory(
        DateTime(2026, 5, 24),
        DateTime(2026, 5, 27),
      );
      expect(result.length, equals(2));
      expect(result.map((r) => r.weight), containsAll([72.5, 72.0]));
    });

    test('getWeightHistory includes records exactly on start and end days',
        () async {
      final fake = FakeHealthDataRepository(
        weightHistory: [
          // record at start-of-day on start
          WeightRecord(weight: 73.0, date: DateTime(2026, 5, 24, 0, 0)),
          // record near end-of-day on end
          WeightRecord(
              weight: 72.0,
              date: DateTime(2026, 5, 27, 23, 30)),
        ],
      );
      final result = await fake.getWeightHistory(
        DateTime(2026, 5, 24),
        DateTime(2026, 5, 27),
      );
      expect(result.length, equals(2));
    });

    test('getWeightHistory excludes records on the day after end', () async {
      final fake = FakeHealthDataRepository(
        weightHistory: [
          WeightRecord(weight: 72.0, date: DateTime(2026, 5, 28, 0, 1)),
        ],
      );
      final result = await fake.getWeightHistory(
        DateTime(2026, 5, 24),
        DateTime(2026, 5, 27),
      );
      expect(result, isEmpty);
    });
  });

  group('healthDataRepositoryProvider DI', () {
    // The unoverridden provider returns a `HealthService` instance whose
    // `Health()` field triggers platform channels at construction, so the
    // happy-path provider read is not exercised in `flutter test`. Override
    // behaviour (the only path exercised in unit tests) is verified below.

    test('provider can be overridden with a fake for tests', () async {
      final fake = FakeHealthDataRepository(
        todaySummary: ActivitySummary(
          workoutTypes: const ['Swimming'],
          workoutCalories: 300,
          totalCalories: 2100,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          healthDataRepositoryProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(healthDataRepositoryProvider);
      expect(repo, isA<FakeHealthDataRepository>());
      final summary = await repo.getTodayActivitySummary();
      expect(summary.workoutTypes, equals(['Swimming']));
      expect(fake.getTodayActivitySummaryCallCount, equals(1));
    });
  });
}
