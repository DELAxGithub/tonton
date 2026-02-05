import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart' as app_theme;
import '../../utils/icon_mapper.dart';
import '../../providers/providers.dart';

/// Three horizontal MetricCards: intake, burn, savings — matching .pen design
class CalorieSummaryRow extends ConsumerWidget {
  const CalorieSummaryRow({super.key});

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

    final savings = burnedCalories - consumedCalories;
    final savingsText =
        savings >= 0
            ? '+${savings.toStringAsFixed(0)}'
            : savings.toStringAsFixed(0);

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            iconBgColor: const Color(0xFFE8F5E9),
            icon: Icons.restaurant,
            iconColor: TontonColors.systemGreen,
            value: consumedCalories.toStringAsFixed(0),
            label: '摂取',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            iconBgColor: const Color(0xFFFFF3E0),
            icon: Icons.local_fire_department,
            iconColor: TontonColors.systemOrange,
            value: burnedCalories.toStringAsFixed(0),
            label: '消費',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            iconBgColor: TontonColors.pigPinkLight,
            icon: TontonIcons.piggybank,
            iconColor: TontonColors.pigPink,
            value: savingsText,
            label: '貯金',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final Color iconBgColor;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MetricCard({
    required this.iconBgColor,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Icon with background
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 4),

          // Value
          Text(
            value,
            style: TextStyle(
              color: app_theme.TontonColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),

          // Label
          Text(
            label,
            style: TextStyle(
              color: app_theme.TontonColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
