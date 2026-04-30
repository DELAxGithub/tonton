import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'pfc_balance_provider.dart';

part 'ideal_weight_trajectory_provider.g.dart';

/// 理想体重 trajectory の 1 点（実測との比較に使う）。
typedef IdealWeightPoint = ({DateTime date, double idealKg});

/// UserGoals.startingBodyWeight + targetWeeklyPercentLoss から
/// startingBodyWeightDate 〜 当月末日までの理想体重曲線を返す。
///
/// 計算式: ideal(d) = start × (1 - pace × elapsedWeeks)
///   - pace は週あたりの減量割合 (例: 0.007 = 0.7%/週)
///   - elapsedWeeks は startingBodyWeightDate からの経過週数 (連続値)
///
/// startingBodyWeight が未設定 (cold start / プロフィール未完) なら
/// 空リストを返す。呼び出し側で "未スナップ" と判定して UI を分岐する。
@riverpod
List<IdealWeightPoint> idealWeightTrajectory(Ref ref) {
  final goals = ref.watch(userGoalsProvider);
  final start = goals.startingBodyWeightKg;
  final startDate = goals.startingBodyWeightDate;
  if (start == null || startDate == null) return const [];

  final pace = goals.targetWeeklyPercentLoss;
  final now = DateTime.now();
  // 当月末まで線を引く（先取り表示で月単位の達成感を出す）。
  // 開始日が将来 (再スタート前夜の設定) の場合は、その月末まで延長して
  // 5/1 起点の予定線が必ず描けるようにする。
  final anchor = DateTime(
    startDate.year,
    startDate.month,
    startDate.day,
  );
  final currentMonthEnd = DateTime(now.year, now.month + 1, 0);
  final anchorMonthEnd = DateTime(anchor.year, anchor.month + 1, 0);
  final end = anchorMonthEnd.isAfter(currentMonthEnd)
      ? anchorMonthEnd
      : currentMonthEnd;

  final points = <IdealWeightPoint>[];
  var d = anchor;
  while (!d.isAfter(end)) {
    final elapsedHours = d.difference(anchor).inHours.toDouble();
    final elapsedWeeks = elapsedHours / (7 * 24);
    final ideal = start * (1 - pace * elapsedWeeks);
    points.add((date: d, idealKg: ideal));
    d = d.add(const Duration(days: 1));
  }
  return points;
}
