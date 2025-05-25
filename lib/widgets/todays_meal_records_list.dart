import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/meal_records_provider.dart';
import 'meal_record_card.dart';
import '../theme/tokens.dart';

/// Displays a list of today's meal records using [todaysMealRecordsProvider].
class TodaysMealRecordsList extends ConsumerWidget {
  const TodaysMealRecordsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(todaysMealRecordsProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.todaysMeals,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: Spacing.sm),
        if (meals.isEmpty)
          Text(
            l10n.noMealsRecorded,
            style: theme.textTheme.bodyMedium,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              return MealRecordCard(mealRecord: meals[index]);
            },
          ),
      ],
    );
  }
}
