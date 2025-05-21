import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'dart:developer' as developer;

import '../l10n/app_localizations.dart';
import '../models/meal_record.dart';
import '../providers/health_provider.dart';
import '../providers/meal_records_provider.dart';
import '../providers/ai_advice_provider.dart';
import '../providers/monthly_progress_provider.dart';
import '../providers/calorie_savings_provider.dart';
import '../utils/icon_mapper.dart';
import '../routes/router.dart';
import '../routes/app_page.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/ai_advice_display_new.dart';
import '../design_system/templates/standard_page_layout.dart';
import '../design_system/organisms/hero_piggy_bank_display.dart';
import '../design_system/organisms/daily_summary_section.dart';
import '../design_system/molecules/navigation_link_card.dart';
import '../design_system/molecules/pfc_bar_display.dart';
import '../design_system/atoms/tonton_button.dart';

/// A completely redesigned home screen with better information layout
class HomeScreenNew extends ConsumerStatefulWidget {
  const HomeScreenNew({super.key});

  @override
  ConsumerState<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends ConsumerState<HomeScreenNew> implements AppPage {

  @override
  void initState() {
    super.initState();
    
    // Request permissions on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final provider = provider_pkg.Provider.of<HealthProvider>(context, listen: false);
        provider.requestPermissions();
      } catch (e, stack) {
        developer.log('Error in postFrameCallback: $e', name: 'TonTon.HomeScreen.error', error: e, stackTrace: stack);
      }
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      title: Text(l10n.appTitle),
      actions: [
        IconButton(
          icon: Icon(TontonIcons.profile),
          onPressed: () {
            context.push(TontonRoutes.profile);
          },
        ),
      ],
    );
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) => null;
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Calorie savings data (dummy/demo from provider)
    final savingsRecords = ref.watch(calorieSavingsDataProvider);
    final totalSavings =
        savingsRecords.isNotEmpty ? savingsRecords.last.cumulativeSavings : 0.0;

    // Meals and nutrition data
    final todayMeals = ref.watch(todaysMealRecordsProvider);
    final dailySummaryAsync = ref.watch(todayCalorieSummaryProvider);

    final protein =
        todayMeals.fold<double>(0, (sum, m) => sum + m.protein);
    final fat = todayMeals.fold<double>(0, (sum, m) => sum + m.fat);
    final carbs = todayMeals.fold<double>(0, (sum, m) => sum + m.carbs);

    return dailySummaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (summary) {
        return StandardPageLayout(
          children: [
            HeroPiggyBankDisplay(
              totalSavings: totalSavings,
              onUsePressed: () {},
            ),
            const SizedBox(height: Spacing.lg),
            DailySummarySection(
              eatenCalories: summary.totalCaloriesConsumed,
              targetCalories: 2000,
              burnedCalories: summary.totalCaloriesBurned,
              dailySavings: summary.netCalories,
            ),
            const SizedBox(height: Spacing.lg),
            PfcBarDisplay(
              title: '今日の栄養バランス (PFC)',
              nutrients: [
                NutrientBarData(
                    label: 'タンパク質', current: protein, target: 60, color: Colors.red),
                NutrientBarData(
                    label: '脂質', current: fat, target: 70, color: Colors.orange),
                NutrientBarData(
                    label: '炭水化物', current: carbs, target: 250, color: Colors.blue),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            TontonButton.primary(
              label: '📷 写真でパシャ！食事をきろく',
              onPressed: () => context.push(TontonRoutes.addMeal),
              leading: TontonIcons.camera,
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
                  onTap: () {},
                ),
                NavigationLinkCard(
                  icon: TontonIcons.ai,
                  label: 'トントンコーチ',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            _buildAiAdviceSection(todayMeals, context),
            const SizedBox(height: Spacing.xxl),
          ],
        );
      },
    );
  }
  
  
  Widget _buildAiAdviceSection(List<MealRecord> todayMeals, BuildContext context) {
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
            const SizedBox(width: TontonSpacing.sm),
            Text(
              l10n.aiAdviceShort,
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: TontonSpacing.sm),
        
        if (aiAdviceState.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: TontonSpacing.md),
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: TontonSpacing.md, 
                  vertical: TontonSpacing.sm,
                ),
              ),
            ),
          ),
          
        if (todayMeals.length < 2)
          Padding(
            padding: const EdgeInsets.only(top: TontonSpacing.sm),
            child: Text(
              l10n.aiAdviceDisabled,
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
          
        aiAdviceState.when(
          data: (advice) => advice != null
              ? Padding(
                  padding: const EdgeInsets.only(top: TontonSpacing.md),
                  child: AiAdviceDisplayNew(advice: advice),
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Padding(
            padding: const EdgeInsets.only(top: TontonSpacing.sm),
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