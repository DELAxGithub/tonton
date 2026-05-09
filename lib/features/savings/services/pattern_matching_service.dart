import 'dart:math' as math;

import '../../../models/calorie_savings_record.dart';
import '../../../models/weight_record.dart';
import '../../../utils/weight_loss_calculator.dart';
import '../models/dietary_pattern.dart';

/// 1 件の判定結果。
class PatternMatchResult {
  final DietaryPatternId patternId;

  /// 0.0〜1.0。低い場合は UI 側で「データ不足」表示に切り替える。
  final double similarity;

  /// 客観的な数値サマリ (1-2 行)。テンプレと結合してカードに描画される。
  /// LLM 自由生成ではなくルールから機械的に組み立てる。
  final String dataObservation;

  const PatternMatchResult({
    required this.patternId,
    required this.similarity,
    required this.dataObservation,
  });
}

/// 8 パターン辞典に対するルールベースの分類器。
///
/// **設計方針:**
/// - LLM のフリー生成は使わない (App Store Review 1.4.1 リスク回避)
/// - 入力データから決定論的に pattern_id + similarity + 数値 observation を出す
/// - 判定不能 (データ不足) は similarity = 0 で返し UI 側で「もう少しログを溜めて」を出す
///
/// 将来 LLM 強化したい場合は同じ output schema を返す PatternMatchingServiceLlm を
/// 作れば差し替え可能。
class PatternMatchingService {
  /// 過去 30 日 (records) のデータからパターン分類する。
  ///
  /// [records] は時系列順 (古→新)。[weightRecords] / [idealKgList] は
  /// records と同じ並び/長さで揃える前提。
  static PatternMatchResult classify({
    required List<CalorieSavingsRecord> records,
    required List<WeightRecord?> weightRecords,
    required List<double?> idealKgList,
    required double startingBodyWeightKg,
  }) {
    // データ不足は早期 return。
    if (records.length < 7) {
      return const PatternMatchResult(
        patternId: DietaryPatternId.smooth,
        similarity: 0.0,
        dataObservation: 'データが7日分未満のため判定できません。もう少しログを溜めてください。',
      );
    }

    final n = records.length;

    // 理論線 (kg)
    final theoryKgs = <double>[
      for (final r in records)
        startingBodyWeightKg -
            (r.cumulativeSavings / WeightLossCalculator.kcalPerKg),
    ];

    // 実測 (有効値のみ)
    final actualKgs = <int, double>{};
    for (int i = 0; i < n && i < weightRecords.length; i++) {
      final w = weightRecords[i];
      if (w != null) actualKgs[i] = w.weight;
    }
    final hasActual = actualKgs.isNotEmpty;

    // 計画線 (有効値のみ)
    final planKgs = <int, double>{};
    for (int i = 0; i < n && i < idealKgList.length; i++) {
      final p = idealKgList[i];
      if (p != null) planKgs[i] = p;
    }

    // ----- 統計量 -----
    final theoryDelta = theoryKgs.last - theoryKgs.first; // 負 = 減量
    final actualDelta = hasActual
        ? actualKgs.values.last - actualKgs.values.first
        : 0.0;
    final planDelta = planKgs.isNotEmpty
        ? planKgs.values.last - planKgs.values.first
        : theoryDelta;

    // 実測のトレンド除去後の標準偏差 (= 折れ線の "ジグザグ度")。
    // 単純な std だと右肩下がりの単調減少でも値が大きくなる (range/√12) ため、
    // 始点-終点で線形トレンドを引いて、その残差の std を取る。
    double actualDetrendedStd = 0;
    if (actualKgs.length >= 3) {
      final entries = actualKgs.entries.toList();
      final first = entries.first;
      final last = entries.last;
      final span = last.key - first.key;
      final slope = span > 0 ? (last.value - first.value) / span : 0;
      final residuals = <double>[
        for (final e in entries) e.value - (first.value + slope * (e.key - first.key)),
      ];
      final mean = residuals.reduce((a, b) => a + b) / residuals.length;
      final variance = residuals
              .map((r) => (r - mean) * (r - mean))
              .reduce((a, b) => a + b) /
          residuals.length;
      actualDetrendedStd = math.sqrt(variance);
    }

    // 半分前後で実測の slope を比較 (whoosh 検出に使う)
    final firstHalfActual = actualKgs.entries
        .where((e) => e.key < n / 2)
        .map((e) => e.value)
        .toList();
    final secondHalfActual = actualKgs.entries
        .where((e) => e.key >= n / 2)
        .map((e) => e.value)
        .toList();
    final firstHalfDrop = firstHalfActual.length >= 2
        ? firstHalfActual.last - firstHalfActual.first
        : 0.0;
    final secondHalfDrop = secondHalfActual.length >= 2
        ? secondHalfActual.last - secondHalfActual.first
        : 0.0;

    // 初週 (最初の 7 日) と それ以降の slope を比較 (initial water shed)
    final firstWeekActual = actualKgs.entries
        .where((e) => e.key < 7)
        .map((e) => e.value)
        .toList();
    final restActual = actualKgs.entries
        .where((e) => e.key >= 7)
        .map((e) => e.value)
        .toList();
    final firstWeekDrop = firstWeekActual.length >= 2
        ? firstWeekActual.last - firstWeekActual.first
        : 0.0;
    final restDrop = restActual.length >= 2
        ? restActual.last - restActual.first
        : 0.0;

    String fmt(double kg) {
      final sign = kg >= 0 ? '+' : '−';
      return '$sign${kg.abs().toStringAsFixed(2)} kg';
    }

    String observation(String body) =>
        '直近${n}日: 計画 ${fmt(planDelta)} / 理論 ${fmt(theoryDelta)} / 実測 ${fmt(actualDelta)}。$body';

    // ----- 判定ルール (優先順位順) -----

    // ⑦ 初期の水分抜け: 最初の 7 日で大きく落ちて、その後ほぼ横ばい
    if (firstWeekDrop < -0.8 && restActual.length >= 2 && restDrop.abs() < 0.4) {
      return PatternMatchResult(
        patternId: DietaryPatternId.initialWaterShed,
        similarity: _clamp01(0.6 + (firstWeekDrop.abs() - 0.8) * 0.3),
        dataObservation: observation(
          '初週で ${fmt(firstWeekDrop)} 落ちた後、第 2 週以降はほぼ横ばい。',
        ),
      );
    }

    // ⑤ Whoosh: 前半ほぼ横ばい、後半に急降下
    if (firstHalfActual.length >= 3 &&
        secondHalfActual.length >= 3 &&
        firstHalfDrop.abs() < 0.3 &&
        secondHalfDrop < -0.6) {
      return PatternMatchResult(
        patternId: DietaryPatternId.whoosh,
        similarity: _clamp01(0.6 + (secondHalfDrop.abs() - 0.6) * 0.4),
        dataObservation: observation(
          '前半は横ばい、後半に ${fmt(secondHalfDrop)} の降下。',
        ),
      );
    }

    // ⑧ 塩分スパイク: 直近 3-7 日で実測が急上昇 (>1.0kg) でその前は安定
    if (actualKgs.length >= 10) {
      final recent = actualKgs.entries.toList();
      final lastWeekStart = recent[recent.length - 7].value;
      final lastWeekEnd = recent.last.value;
      final priorStart = recent[math.max(0, recent.length - 14)].value;
      final priorEnd = recent[recent.length - 7].value;
      final lastWeekChange = lastWeekEnd - lastWeekStart;
      final priorWeekChange = priorEnd - priorStart;
      if (lastWeekChange > 1.0 && priorWeekChange.abs() < 0.5) {
        return PatternMatchResult(
          patternId: DietaryPatternId.saltSpike,
          similarity: _clamp01(0.5 + (lastWeekChange - 1.0) * 0.3),
          dataObservation: observation(
            '直近 7 日で実測が ${fmt(lastWeekChange)} 急上昇 (それ以前は ${fmt(priorWeekChange)})。',
          ),
        );
      }
    }

    // ⑥ ジグザグ: トレンド除去後の標準偏差が大きく、理論線は steady decline
    if (actualDetrendedStd > 0.4 && theoryDelta < -0.3) {
      return PatternMatchResult(
        patternId: DietaryPatternId.zigzag,
        similarity: _clamp01(0.5 + (actualDetrendedStd - 0.4) * 1.0),
        dataObservation: observation(
          '実測のトレンド残差 (標準偏差 ${actualDetrendedStd.toStringAsFixed(2)} kg) が大きい。',
        ),
      );
    }

    // ④ 食べすぎリバウンド: 理論↑ 実測↑ で一致
    if (theoryDelta > 0.2 && actualDelta > 0.2) {
      return PatternMatchResult(
        patternId: DietaryPatternId.rebound,
        similarity: _clamp01(0.6 + (theoryDelta + actualDelta) * 0.2),
        dataObservation: observation(
          '理論と実測が一致して上向き。',
        ),
      );
    }

    // ② 体側で停滞: 理論↓ だが実測がほぼ動かない
    if (theoryDelta < -0.3 && actualDelta.abs() < 0.3) {
      final gap = (actualDelta - theoryDelta).abs();
      return PatternMatchResult(
        patternId: DietaryPatternId.bodyStall,
        similarity: _clamp01(0.5 + gap * 0.5),
        dataObservation: observation(
          '理論との乖離が ${fmt(actualDelta - theoryDelta)} (実測 - 理論)。',
        ),
      );
    }

    // ③ 食事側で逸脱: 理論がほぼ動かない (赤字が作れていない)
    if (theoryDelta.abs() < 0.3 && planDelta < -0.5) {
      return PatternMatchResult(
        patternId: DietaryPatternId.foodDrift,
        similarity: _clamp01(0.5 + (planDelta - theoryDelta).abs() * 0.5),
        dataObservation: observation(
          '理論が計画から ${fmt(theoryDelta - planDelta)} 上振れ。',
        ),
      );
    }

    // ① 順調 (デフォルト): 計画/理論/実測がだいたい一致
    final maxDeviation = [
      (theoryDelta - planDelta).abs(),
      (actualDelta - planDelta).abs(),
    ].reduce(math.max);
    return PatternMatchResult(
      patternId: DietaryPatternId.smooth,
      similarity: _clamp01(1.0 - maxDeviation),
      dataObservation: observation('3 線がほぼ整合しています。'),
    );
  }

  static double _clamp01(double v) => v.clamp(0.0, 1.0);
}
