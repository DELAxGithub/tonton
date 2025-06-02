import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart' as colors;
import '../theme/typography.dart' as typography;
import '../theme/tokens.dart' as tokens;
import '../utils/icon_mapper.dart';
import '../providers/providers.dart';
import '../design_system/atoms/tonton_card_base.dart';
import '../features/progress/providers/auto_pfc_provider.dart';

/// 今日のサマリーを横スクロールカードで表示
class TodaySummaryCards extends ConsumerWidget {
  const TodaySummaryCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMeals = ref.watch(todaysMealRecordsProvider);
    final summaryAsync = ref.watch(todayCalorieSummaryProvider);
    final realtimeSummaryAsync = ref.watch(realtimeDailySummaryProvider);
    final autoPfc = ref.watch(autoPfcTargetProvider);
    
    // PFC計算
    final protein = todayMeals.fold<double>(0, (sum, m) => sum + m.protein);
    final fat = todayMeals.fold<double>(0, (sum, m) => sum + m.fat);
    final carbs = todayMeals.fold<double>(0, (sum, m) => sum + m.carbs);
    
    // 達成率計算
    final proteinAchievement = autoPfc != null && autoPfc.protein > 0 
        ? (protein / autoPfc.protein * 100).round() 
        : 0;
    final fatAchievement = autoPfc != null && autoPfc.fat > 0 
        ? (fat / autoPfc.fat * 100).round() 
        : 0;
    final carbsAchievement = autoPfc != null && autoPfc.carbohydrate > 0 
        ? (carbs / autoPfc.carbohydrate * 100).round() 
        : 0;

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: tokens.Spacing.md),
        children: [
          // 今日の貯金額カード
          _SummaryCard(
            icon: TontonIcons.piggybank,
            iconColor: colors.TontonColors.pigPink,
            title: '今日の貯金',
            value: summaryAsync.maybeWhen(
              data: (summary) => '${summary.netCalories.toStringAsFixed(0)} kcal',
              orElse: () => '-- kcal',
            ),
          ),
          const SizedBox(width: tokens.Spacing.sm),
          
          // 運動カロリーカード
          _SummaryCard(
            icon: TontonIcons.workout,
            iconColor: colors.TontonColors.systemBlue,
            title: '消費カロリー',
            value: realtimeSummaryAsync.maybeWhen(
              data: (summary) => '${summary.caloriesBurned.toStringAsFixed(0)} kcal',
              orElse: () => '-- kcal',
            ),
          ),
          const SizedBox(width: tokens.Spacing.sm),
          
          // PFC達成率カード
          _PfcAchievementCard(
            proteinAchievement: proteinAchievement,
            fatAchievement: fatAchievement,
            carbsAchievement: carbsAchievement,
            hasTarget: autoPfc != null,
          ),
        ],
      ),
    );
  }
}

/// 個別のサマリーカード
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: TontonCardBase(
        elevation: tokens.Elevation.level1,
        padding: const EdgeInsets.all(tokens.Spacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                  const SizedBox(width: tokens.Spacing.xs),
                  Text(
                    title,
                    style: typography.TontonTypography.caption1.copyWith(
                      color: colors.TontonColors.secondaryLabelColor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: tokens.Spacing.xs),
              Text(
                value,
                style: typography.TontonTypography.headline.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.TontonColors.labelColor(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
        ),
      ),
    );
  }
}

/// PFC達成率カード
class _PfcAchievementCard extends StatelessWidget {
  final int proteinAchievement;
  final int fatAchievement;
  final int carbsAchievement;
  final bool hasTarget;

  const _PfcAchievementCard({
    required this.proteinAchievement,
    required this.fatAchievement,
    required this.carbsAchievement,
    required this.hasTarget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 平均達成率を計算
    final averageAchievement = hasTarget 
        ? ((proteinAchievement + fatAchievement + carbsAchievement) / 3).round()
        : 0;
    
    // 達成率に応じた色を選択
    Color getAchievementColor(int achievement) {
      if (achievement >= 80 && achievement <= 120) {
        return colors.TontonColors.systemGreen;
      } else if (achievement >= 60 && achievement < 80) {
        return colors.TontonColors.systemOrange;
      } else {
        return colors.TontonColors.systemGray;
      }
    }
    
    return SizedBox(
      width: 160,
      child: TontonCardBase(
        elevation: tokens.Elevation.level1,
        padding: const EdgeInsets.all(tokens.Spacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 20,
                    color: hasTarget ? getAchievementColor(averageAchievement) : colors.TontonColors.systemGray,
                  ),
                  const SizedBox(width: tokens.Spacing.xs),
                  Text(
                    'PFC達成率',
                    style: typography.TontonTypography.caption1.copyWith(
                      color: colors.TontonColors.secondaryLabelColor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: tokens.Spacing.xs),
              if (hasTarget) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMiniAchievement('P', proteinAchievement, colors.TontonColors.proteinColor),
                    _buildMiniAchievement('F', fatAchievement, colors.TontonColors.fatColor),
                    _buildMiniAchievement('C', carbsAchievement, colors.TontonColors.carbsColor),
                  ],
                ),
              ] else
                Text(
                  '目標未設定',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.TontonColors.systemGray,
                  ),
                ),
            ],
        ),
      ),
    );
  }

  Widget _buildMiniAchievement(String label, int achievement, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          '$achievement%',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}