import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tonton/features/progress/providers/ideal_weight_trajectory_provider.dart';
import 'package:tonton/features/progress/providers/pfc_balance_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('returns empty list when starting weight is not snapshot', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(idealWeightTrajectoryProvider), isEmpty);
  });

  test('first point equals starting weight on the anchor date', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final start = DateTime.utc(2026, 5, 1);
    await container.read(userGoalsProvider.notifier).setStartingBodyWeight(
          weight: 60.0,
          date: start,
        );

    final points = container.read(idealWeightTrajectoryProvider);
    expect(points, isNotEmpty);
    expect(points.first.idealKg, closeTo(60.0, 1e-9));
  });

  test('after 14 days at 0.7%/week pace from 60kg the ideal is ~59.16kg', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final start = DateTime.utc(2026, 5, 1);
    await container.read(userGoalsProvider.notifier).setStartingBodyWeight(
          weight: 60.0,
          date: start,
        );
    // Default targetWeeklyPercentLoss is 0.007 (0.7%/week).

    final points = container.read(idealWeightTrajectoryProvider);
    final day15 = points.firstWhere(
      (p) =>
          p.date.year == 2026 && p.date.month == 5 && p.date.day == 15,
      orElse: () => (date: DateTime(0), idealKg: double.nan),
    );
    expect(day15.date.year, 2026);
    // 14 elapsed days = 2 weeks → 60 * (1 - 0.007 * 2) = 59.16
    expect(day15.idealKg, closeTo(59.16, 0.01));
  });
}
