import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../theme/app_theme.dart' as app_theme;
import '../../features/meal_logging/providers/meal_records_provider.dart';
import '../../features/progress/providers/meal_score_provider.dart';
import '../../features/progress/providers/weekly_pfc_provider.dart';
import '../molecules/pfc_bar_display.dart';
import '../molecules/pfc_weekly_bar_chart.dart';

/// PFC Dashboard card: today's balance + 7-day trend chart.
/// Replaces the former _PfcBalanceCard in HomeScreen.
class PfcDashboardCard extends ConsumerWidget {
  const PfcDashboardCard({super.key});

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return TontonColors.systemGreen;
      case 'B':
        return TontonColors.systemBlue;
      case 'C':
        return TontonColors.systemOrange;
      default:
        return TontonColors.systemRed;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMeals = ref.watch(todaysMealRecordsProvider);
    final score = ref.watch(dailyMealScoreProvider);
    final weekData = ref.watch(weeklyPfcSummaryProvider);

    final protein = todayMeals.fold<double>(0, (s, m) => s + m.protein);
    final fat = todayMeals.fold<double>(0, (s, m) => s + m.fat);
    final carbs = todayMeals.fold<double>(0, (s, m) => s + m.carbs);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: TontonColors.shadowSubtle,
            offset: Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Today's score row ===
          if (score != null) ...[
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gradeColor(score.grade).withValues(alpha: 0.12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${score.score}',
                    style: TextStyle(
                      color: _gradeColor(score.grade),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      score.grade,
                      style: TextStyle(
                        color: _gradeColor(score.grade),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      score.label,
                      style: TextStyle(
                        color: app_theme.TontonColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: TontonColors.borderSubtle, height: 1),
            const SizedBox(height: 14),
          ],

          // === Today's PFC bars ===
          PfcBarDisplay(
            title: '',
            protein: protein,
            fat: fat,
            carbs: carbs,
          ),

          // === Feedback text ===
          if (score != null) ...[
            const SizedBox(height: 14),
            Divider(color: TontonColors.borderSubtle, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: TontonColors.systemOrange,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    score.feedback,
                    style: TextStyle(
                      color: app_theme.TontonColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // === Weekly trend section ===
          const SizedBox(height: 18),
          Divider(color: TontonColors.borderSubtle, height: 1),
          const SizedBox(height: 14),
          Text(
            '週間推移',
            style: TextStyle(
              color: app_theme.TontonColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Bar chart
          PfcWeeklyBarChart(weekData: weekData),
          const SizedBox(height: 8),

          // Score dots row
          _ScoreDots(weekData: weekData, gradeColor: _gradeColor),
        ],
      ),
    );
  }
}

/// Row of 7 small dots showing each day's grade color.
class _ScoreDots extends StatelessWidget {
  final List<dynamic> weekData;
  final Color Function(String) gradeColor;

  const _ScoreDots({required this.weekData, required this.gradeColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(weekData.length, (index) {
        final day = weekData[index];
        final hasGrade = day.grade != null;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasGrade
                ? gradeColor(day.grade!)
                : TontonColors.borderSubtle,
          ),
        );
      }),
    );
  }
}
