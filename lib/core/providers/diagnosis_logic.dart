import '../../utils/weight_loss_calculator.dart';

/// 診断の種別。優先順 (上から先に評価):
///   tooShort → goalTooSmall → bodyComp → trackingMismatch → onTrack → unknown
enum DiagnosisKind {
  tooShort,
  goalTooSmall,
  trackingMismatch,
  bodyComp,
  onTrack,
  unknown,
}

/// 診断ロジックの純粋入力（Provider / Test 共通）。
class DiagnosisInput {
  final int periodDays;
  final double weightKg;
  final double dailyDeficitGoalKcal;
  final double averageDailyActualDeficitKcal;
  final double? startWeightKg;
  final double? currentWeightKg;
  final double targetWeeklyPercentLoss;
  final double? startBodyFatPercent;
  final double? currentBodyFatPercent;

  const DiagnosisInput({
    required this.periodDays,
    required this.weightKg,
    required this.dailyDeficitGoalKcal,
    required this.averageDailyActualDeficitKcal,
    required this.targetWeeklyPercentLoss,
    this.startWeightKg,
    this.currentWeightKg,
    this.startBodyFatPercent,
    this.currentBodyFatPercent,
  });
}

class DiagnosisResult {
  final DiagnosisKind kind;
  final double requiredDailyDeficitKcal;
  final double expectedWeeklyLossKg;
  final double? actualLossKg;
  final double? actualPerExpectedRatio;
  final String headline;
  final List<String> body;

  const DiagnosisResult({
    required this.kind,
    required this.requiredDailyDeficitKcal,
    required this.expectedWeeklyLossKg,
    required this.headline,
    required this.body,
    this.actualLossKg,
    this.actualPerExpectedRatio,
  });
}

DiagnosisResult runDiagnosis(DiagnosisInput input) {
  final required = WeightLossCalculator.requiredDailyDeficit(
    weightKg: input.weightKg,
    weeklyPercentLoss: input.targetWeeklyPercentLoss,
  );
  final expectedWeeklyKg = input.weightKg * input.targetWeeklyPercentLoss;

  // Actual observed weight loss (positive = loss).
  double? actualLossKg;
  if (input.startWeightKg != null && input.currentWeightKg != null) {
    actualLossKg = input.startWeightKg! - input.currentWeightKg!;
  }

  final expectedLossKg = WeightLossCalculator.expectedWeightLossKg(
    cumulativeDeficitKcal:
        input.averageDailyActualDeficitKcal * input.periodDays,
  );
  final ratio = (actualLossKg != null && expectedLossKg > 0.01)
      ? actualLossKg / expectedLossKg
      : null;

  DiagnosisKind kind;
  String headline;
  List<String> body;

  if (input.periodDays < 7) {
    kind = DiagnosisKind.tooShort;
    final daysLeft = 7 - input.periodDays;
    headline = '記録はまだ $daysLeft 日分足りません';
    body = [
      '体重は水分・グリコーゲンで ±1kg ほど揺れます。',
      'あと $daysLeft 日記録を続けると、傾向が見え始めます。',
    ];
  } else if (input.dailyDeficitGoalKcal + 1 < required) {
    kind = DiagnosisKind.goalTooSmall;
    final weeklyAtCurrent = input.dailyDeficitGoalKcal *
        7 /
        WeightLossCalculator.kcalPerKg;
    headline = '今の目標では週 -${weeklyAtCurrent.toStringAsFixed(2)}kg ペース';
    body = [
      '希望ペースは週 -${expectedWeeklyKg.toStringAsFixed(2)}kg（体重の'
          ' ${(input.targetWeeklyPercentLoss * 100).toStringAsFixed(1)}%）。',
      'これには日次赤字 ${required.round()} kcal/日 が必要です。',
      '今の設定 (${input.dailyDeficitGoalKcal.round()} kcal/日) では'
          '日々の体重揺れ (±1-2kg) に埋もれて傾向が見えにくくなります。',
      '目標を引き上げるか、希望ペースを緩めますか？',
    ];
  } else if (_isBodyCompWin(input)) {
    kind = DiagnosisKind.bodyComp;
    final bfDrop =
        (input.startBodyFatPercent! - input.currentBodyFatPercent!).abs();
    headline = '体重キープでも体脂肪は -${bfDrop.toStringAsFixed(1)}%';
    body = [
      '体重が減っていなくても、体脂肪率は下がっています。',
      '筋肉が増えている可能性が高く、「成功」と見て良い状態です。',
      '体組成計の数値もあわせて見守りましょう。',
    ];
  } else if (ratio != null && ratio < 0.5 && input.periodDays >= 14) {
    kind = DiagnosisKind.trackingMismatch;
    headline = '理論値より体重が減っていません';
    body = [
      '目標赤字は足りています（${required.round()} kcal/日 以上）。',
      'にも関わらず実測が期待の ${(ratio * 100).round()}% に留まっています。',
      '以下のどれかが起きているかも:',
      '・目分量で記録していて、実際は多めに摂取している',
      '・油・調味料・飲料（ラテ/ジュース/酒）の記録漏れ',
      '・試食・一口・摘みの記録漏れ',
      '・外食のカロリー（家庭の 1.5〜2 倍の油）',
      '・TDEE推定が高すぎる（活動量係数を下げる）',
    ];
  } else if (ratio != null && ratio >= 0.8) {
    kind = DiagnosisKind.onTrack;
    headline = '順調です';
    body = [
      '期待 -${expectedLossKg.toStringAsFixed(1)}kg / 実測 '
          '-${actualLossKg!.toStringAsFixed(1)}kg。',
      'このペースを続けましょう。',
    ];
  } else {
    kind = DiagnosisKind.unknown;
    headline = 'もう少し記録を続けましょう';
    body = [
      '判断に足るデータがまだ揃っていません。',
      '体重・食事の記録を続けてください。',
    ];
  }

  return DiagnosisResult(
    kind: kind,
    requiredDailyDeficitKcal: required,
    expectedWeeklyLossKg: expectedWeeklyKg,
    actualLossKg: actualLossKg,
    actualPerExpectedRatio: ratio,
    headline: headline,
    body: body,
  );
}

bool _isBodyCompWin(DiagnosisInput input) {
  final bf0 = input.startBodyFatPercent;
  final bf1 = input.currentBodyFatPercent;
  final w0 = input.startWeightKg;
  final w1 = input.currentWeightKg;
  if (bf0 == null || bf1 == null || w0 == null || w1 == null) return false;
  final weightChangedUpOrFlat = w1 >= w0 - 0.2;
  final bodyFatDropped = bf1 < bf0 - 0.5;
  return weightChangedUpOrFlat && bodyFatDropped;
}
