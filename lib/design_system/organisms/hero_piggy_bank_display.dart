import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../providers/providers.dart';
import '../../utils/icon_mapper.dart';

/// Daily calorie savings hero card with pink gradient
class HeroPiggyBankDisplay extends ConsumerWidget {
  const HeroPiggyBankDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMeals = ref.watch(todaysMealRecordsProvider);
    final consumedCalories = todayMeals.fold<double>(
      0,
      (sum, meal) => sum + meal.calories,
    );

    final realtimeSummaryAsync = ref.watch(realtimeDailySummaryProvider);
    final burnedCalories = realtimeSummaryAsync.maybeWhen(
      data: (summary) => summary.caloriesBurned,
      orElse: () => 0.0,
    );

    // Savings = burned - consumed (positive = calorie deficit = "savings")
    final savings = burnedCalories - consumedCalories;
    final savingsText =
        savings >= 0
            ? '+${savings.toStringAsFixed(0)}'
            : savings.toStringAsFixed(0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9AA2), Color(0xFFFFB7BD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30FF9AA2),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: title + piggy icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '今日のカロリー貯金',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                TontonIcons.piggybank,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Value row: large savings number + kcal
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                savingsText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'kcal',
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Sub row: intake + burn
          Row(
            children: [
              Text(
                '摂取: ${consumedCalories.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xBBFFFFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '消費: ${burnedCalories.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xBBFFFFFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
