import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/meal_records_provider.dart';
import '../providers/ai_advice_provider.dart';
import '../providers/calorie_savings_provider.dart';
import '../providers/monthly_progress_provider.dart';
import '../providers/realtime_calories_provider.dart';
import '../design_system/templates/standard_page_layout.dart';
import '../design_system/organisms/hero_piggy_bank_display.dart';
import '../design_system/organisms/daily_summary_section.dart';
import '../design_system/molecules/pfc_bar_display.dart';
import '../design_system/molecules/navigation_link_card.dart';
import '../design_system/atoms/tonton_button.dart';
import '../widgets/ai_advice_display_new.dart';
import '../utils/icon_mapper.dart';
import '../theme/tokens.dart';
import '../routes/router.dart';
import '../models/meal_record.dart';

/// Experimental home screen used when [FeatureFlags.usePhase3Design] is enabled.
class HomeScreenPhase3 extends ConsumerWidget {
  const HomeScreenPhase3({super.key});

  String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'おはよう';
    if (hour < 18) return 'こんにちは';
    return 'こんばんは';
  }

  String _displayName(User? user) {
    final meta = user?.userMetadata ?? {};
    final name = meta['full_name'] ?? meta['name'] ?? meta['username'];
    if (name is String && name.isNotEmpty) return name;
    final email = user?.email ?? '';
    return email.split('@').first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    final savingsRecordsAsync = ref.watch(calorieSavingsDataProvider);
    final totalSavings = savingsRecordsAsync.maybeWhen(
      data: (records) =>
          records.isNotEmpty ? records.last.cumulativeSavings : 0.0,
      orElse: () => 0.0,
    );

    final todayMeals = ref.watch(todaysMealRecordsProvider);
    final dailySummaryAsync = ref.watch(todayCalorieSummaryProvider);
    final realtimeSummaryAsync = ref.watch(realtimeDailySummaryProvider);

    final protein = todayMeals.fold<double>(0, (sum, m) => sum + m.protein);
    final fat = todayMeals.fold<double>(0, (sum, m) => sum + m.fat);
    final carbs = todayMeals.fold<double>(0, (sum, m) => sum + m.carbs);

    final greeting = _greetingFor(DateTime.now());
    final userName = _displayName(user);

    return dailySummaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (summary) {
        final l10n = AppLocalizations.of(context);
        return StandardPageLayout(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$greeting、$userName',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: Icon(TontonIcons.settings),
                    tooltip: l10n.tabSettings,
                    onPressed: () => context.push(TontonRoutes.settings),
                  ),
                ],
              ),
            ),
            HeroPiggyBankDisplay(
              totalSavings: totalSavings,
              onUsePressed: () {},
            ),
            const SizedBox(height: Spacing.lg),
            DailySummarySection(
              eatenCalories: summary.totalCaloriesConsumed,
              burnedCalories: summary.totalCaloriesBurned,
              realtimeBurnedCalories: realtimeSummaryAsync.maybeWhen(
                data: (s) => s.caloriesBurned,
                orElse: () => null,
              ),
              dailySavings: summary.netCalories,
            ),
            const SizedBox(height: Spacing.lg),
            PfcBarDisplay(
              title: '今日の栄養バランス (PFC)',
              nutrients: [
                NutrientBarData(
                  label: 'タンパク質',
                  current: protein,
                  target: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                NutrientBarData(
                  label: '脂質',
                  current: fat,
                  target: 70,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                NutrientBarData(
                  label: '炭水化物',
                  current: carbs,
                  target: 250,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            TontonButton.primary(
              label: '📷 写真でパシャ！食事をきろく',
              leading: TontonIcons.camera,
              onPressed: () => context.push(TontonRoutes.aiMealCamera),
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavigationLinkCard(
                  icon: TontonIcons.trend,
                  label: '貯金ダイアリー',
                  onTap: () => context.push(TontonRoutes.savingsTrend),
                ),
                NavigationLinkCard(
                  icon: TontonIcons.weight,
                  label: '体重ジャーニー',
                  onTap: () => context.push(TontonRoutes.progressAchievements),
                ),
                NavigationLinkCard(
                  icon: TontonIcons.ai,
                  label: 'トントンコーチ',
                  onTap: () => context.push(TontonRoutes.tontonCoach),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            _buildAiAdviceSection(todayMeals, context, ref),
            const SizedBox(height: Spacing.xxl),
          ],
        );
      },
    );
  }

  Widget _buildAiAdviceSection(
      List<MealRecord> todayMeals, BuildContext context, WidgetRef ref) {
    final aiAdviceState = ref.watch(aiAdviceProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              TontonIcons.ai,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              l10n.aiAdviceShort,
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        if (aiAdviceState.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.md),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Tooltip(
            message: l10n.aiAdviceRequest,
            child: ElevatedButton.icon(
              icon: Icon(TontonIcons.ai),
              label: Text(l10n.aiAdviceShort),
              onPressed: todayMeals.length < 2
                  ? null
                  : () => ref
                      .read(aiAdviceProvider.notifier)
                      .fetchAdvice(todayMeals, context),
            ),
          ),
        if (todayMeals.length < 2)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.sm),
            child: Text(
              l10n.aiAdviceDisabled,
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        aiAdviceState.when(
          data: (advice) => advice != null
              ? Padding(
                  padding: const EdgeInsets.only(top: Spacing.md),
                  child: AiAdviceDisplayNew(advice: advice),
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Padding(
            padding: const EdgeInsets.only(top: Spacing.sm),
            child: Text(
              l10n.aiAdviceError(e.toString()),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}
