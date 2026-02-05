import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart' as design_colors;
import '../models/meal_record.dart';

/// Compact horizontal meal record card matching .pen MealRecordCard design
class MealRecordCard extends StatelessWidget {
  final MealRecord mealRecord;
  final VoidCallback? onTap;

  const MealRecordCard({super.key, required this.mealRecord, this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat.jm().format(mealRecord.consumedAt);
    final mealType = mealRecord.mealTimeType.displayName;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: design_colors.TontonColors.shadowSubtle,
            offset: Offset(0, 1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                // Photo thumbnail placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: design_colors.TontonColors.borderSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: TontonColors.textTertiary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealRecord.mealName,
                        style: const TextStyle(
                          color: TontonColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$timeStr · $mealType',
                        style: TextStyle(
                          color: TontonColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Calories
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      mealRecord.calories.toStringAsFixed(0),
                      style: const TextStyle(
                        color: design_colors.TontonColors.pigPink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'kcal',
                      style: TextStyle(
                        color: TontonColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
