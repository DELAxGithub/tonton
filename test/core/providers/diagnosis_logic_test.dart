import 'package:flutter_test/flutter_test.dart';
import 'package:tonton/core/providers/diagnosis_logic.dart';

void main() {
  DiagnosisInput baseInput({
    int days = 30,
    double weightKg = 70,
    double dailyDeficitGoalKcal = 540,
    double avgDailyActualDeficit = 540,
    double startWeight = 70,
    double currentWeight = 69.5,
    double targetWeeklyPercentLoss = 0.007,
    double? startBodyFat,
    double? currentBodyFat,
  }) {
    return DiagnosisInput(
      periodDays: days,
      weightKg: weightKg,
      dailyDeficitGoalKcal: dailyDeficitGoalKcal,
      averageDailyActualDeficitKcal: avgDailyActualDeficit,
      startWeightKg: startWeight,
      currentWeightKg: currentWeight,
      targetWeeklyPercentLoss: targetWeeklyPercentLoss,
      startBodyFatPercent: startBodyFat,
      currentBodyFatPercent: currentBodyFat,
    );
  }

  test('period < 7 days -> tooShort', () {
    final r = runDiagnosis(baseInput(days: 5));
    expect(r.kind, DiagnosisKind.tooShort);
  });

  test('goal deficit smaller than required -> goalTooSmall', () {
    // 70kg * 0.007/week needs ~540 kcal/day; user set only 240
    final r = runDiagnosis(
      baseInput(days: 30, dailyDeficitGoalKcal: 240),
    );
    expect(r.kind, DiagnosisKind.goalTooSmall);
    expect(r.requiredDailyDeficitKcal, closeTo(539, 1));
  });

  test('goal ok but actual way below expected (>=14d) -> trackingMismatch', () {
    // Required ~540/day, goal 540, actual reported 540, but weight barely moved
    // Expected loss: 540 * 30 / 7700 ≈ 2.1 kg. Actual loss: 0.2 kg -> 10%.
    final r = runDiagnosis(
      baseInput(
        days: 30,
        dailyDeficitGoalKcal: 540,
        avgDailyActualDeficit: 540,
        startWeight: 70,
        currentWeight: 69.8,
      ),
    );
    expect(r.kind, DiagnosisKind.trackingMismatch);
  });

  test('weight up but body fat down -> bodyComp', () {
    final r = runDiagnosis(
      baseInput(
        days: 30,
        startWeight: 70,
        currentWeight: 70.5,
        startBodyFat: 22,
        currentBodyFat: 20,
      ),
    );
    expect(r.kind, DiagnosisKind.bodyComp);
  });

  test('actual ~= expected -> onTrack', () {
    // Expected: 540*30/7700 ≈ 2.1 kg. Actual 1.8 kg -> 85%.
    final r = runDiagnosis(
      baseInput(
        days: 30,
        dailyDeficitGoalKcal: 540,
        avgDailyActualDeficit: 540,
        startWeight: 70,
        currentWeight: 68.2,
      ),
    );
    expect(r.kind, DiagnosisKind.onTrack);
  });

  test('settings diagnosis wins over trackingMismatch when both would match',
      () {
    // Low goal + bad actual — diagnosis prioritizes fixing the goal first.
    final r = runDiagnosis(
      baseInput(
        days: 30,
        dailyDeficitGoalKcal: 240,
        avgDailyActualDeficit: 240,
        startWeight: 70,
        currentWeight: 69.9,
      ),
    );
    expect(r.kind, DiagnosisKind.goalTooSmall);
  });
}
