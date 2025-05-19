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
import '../utils/date_formatter.dart';
import '../utils/icon_mapper.dart';
import '../routes/router.dart';
import '../theme/app_theme.dart';
import '../widgets/meal_record_card.dart';
import '../widgets/ai_advice_display_new.dart';

/// A completely redesigned home screen with better information layout
class HomeScreenNew extends ConsumerStatefulWidget {
  const HomeScreenNew({super.key});

  @override
  ConsumerState<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends ConsumerState<HomeScreenNew> {
  // Current bottom navigation index
  int _currentIndex = 0;

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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // Get today's meals
    final todayMeals = ref.watch(todaysMealRecordsProvider);
    final todayTotalCalories = ref.watch(todaysTotalCaloriesProvider);
    
    // Get activity data 
    final healthProvider = provider_pkg.Provider.of<HealthProvider>(context);
    final activeCalories = healthProvider.activeCaloriesForToday;
    final basalCalories = healthProvider.basalCaloriesForToday;
    final totalBurnedCalories = activeCalories + basalCalories;
    
    // Get monthly progress
    final monthlyProgressAsync = ref.watch(monthlyProgressSummaryProvider);
    
    // Calculate calorie balance
    final calorieBalance = totalBurnedCalories - todayTotalCalories;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: Icon(TontonIcons.profile),
            onPressed: () {
              // TODO: Navigate to profile screen or settings
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home tab
          _buildHomeTab(
            context: context,
            todayMeals: todayMeals,
            todayTotalCalories: todayTotalCalories,
            activeCalories: activeCalories,
            basalCalories: basalCalories,
            totalBurnedCalories: totalBurnedCalories,
            calorieBalance: calorieBalance,
            monthlyProgress: monthlyProgressAsync.when(
              data: (summary) => summary.completionPercentage,
              loading: () => 0,
              error: (_, __) => 0,
            ),
          ),
          
          // Activity tab - To be implemented
          Center(child: Text(l10n.tabActivity)),
          
          // Meals tab - To be implemented
          Center(child: Text(l10n.tabMeals)),
          
          // Insights tab - To be implemented
          Center(child: Text(l10n.tabInsights)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(TontonIcons.home),
            label: l10n.tabHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(TontonIcons.activity),
            label: l10n.tabActivity,
          ),
          BottomNavigationBarItem(
            icon: Icon(TontonIcons.food),
            label: l10n.tabMeals,
          ),
          BottomNavigationBarItem(
            icon: Icon(TontonIcons.insights),
            label: l10n.tabInsights,
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  Widget _buildFloatingActionButton() {
    if (_currentIndex == 2) { // Meals tab
      return FloatingActionButton(
        onPressed: () {
          context.pushNamed('addMeal');
        },
        tooltip: AppLocalizations.of(context).addMeal,
        child: Icon(TontonIcons.add),
      );
    }
    return const SizedBox.shrink();
  }
  
  Widget _buildHomeTab({
    required BuildContext context,
    required List<MealRecord> todayMeals,
    required double todayTotalCalories,
    required double activeCalories,
    required double basalCalories,
    required double totalBurnedCalories,
    required double calorieBalance,
    required double monthlyProgress,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = DateTime.now();
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh health data
        final healthProvider = provider_pkg.Provider.of<HealthProvider>(context, listen: false);
        await healthProvider.fetchHealthData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(TontonSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's date
            Text(
              DateFormatter.formatDate(today),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: TontonSpacing.md),
            
            // Calorie summary card
            _buildCalorieSummaryCard(
              context: context,
              consumed: todayTotalCalories,
              burned: totalBurnedCalories,
              balance: calorieBalance,
            ),
            const SizedBox(height: TontonSpacing.lg),
            
            // Monthly progress
            _buildProgressSection(
              context: context,
              monthlyProgress: monthlyProgress,
            ),
            const SizedBox(height: TontonSpacing.lg),
            
            // Today's Meals Section
            Text(
              l10n.todaysMeals,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: TontonSpacing.sm),
            
            // Today's meals
            todayMeals.isEmpty 
              ? _buildEmptyMealsState(context)
              : _buildMealsList(context, todayMeals),
            
            const SizedBox(height: TontonSpacing.lg),
            
            // AI Advice Section
            _buildAiAdviceSection(todayMeals, context),
            
            // Add some bottom spacing for visibility
            const SizedBox(height: TontonSpacing.xxl),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCalorieSummaryCard({
    required BuildContext context,
    required double consumed,
    required double burned,
    required double balance,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(TontonSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todaysCalories,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: TontonSpacing.md),
            
            Row(
              children: [
                // Consumed
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        TontonIcons.food,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: TontonSpacing.xs),
                      Text(
                        l10n.consumed,
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${consumed.toStringAsFixed(0)} kcal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Container(
                  height: 50,
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                
                // Burned
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        TontonIcons.energy,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(height: TontonSpacing.xs),
                      Text(
                        l10n.burned,
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${burned.toStringAsFixed(0)} kcal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Container(
                  height: 50,
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                
                // Balance
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        balance >= 0 ? TontonIcons.trend : Icons.arrow_downward,
                        color: balance >= 0 
                          ? TontonColors.success 
                          : TontonColors.error,
                      ),
                      const SizedBox(height: TontonSpacing.xs),
                      Text(
                        l10n.balance,
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${balance.toStringAsFixed(0)} kcal',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: balance >= 0 
                            ? TontonColors.success 
                            : TontonColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressSection({
    required BuildContext context,
    required double monthlyProgress,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    // Calculate progress percentage (capped at 100%)
    final progressPercentage = (monthlyProgress / 100).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.yourProgress,
              style: theme.textTheme.titleLarge,
            ),
            TextButton.icon(
              onPressed: () {
                context.push(TontonRoutes.savingsTrend);
              },
              icon: Icon(TontonIcons.trend, size: 16),
              label: Text(l10n.calorieSavingsGraph),
            ),
          ],
        ),
        const SizedBox(height: TontonSpacing.sm),
        
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(TontonSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.monthlyGoal,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      '${monthlyProgress.toStringAsFixed(0)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TontonSpacing.sm),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(TontonRadius.full),
                  child: LinearProgressIndicator(
                    value: progressPercentage,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyMealsState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              TontonIcons.food,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: TontonSpacing.md),
            Text(
              l10n.noMealsRecorded,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: TontonSpacing.sm),
            Text(
              l10n.tapAddMeal,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMealsList(BuildContext context, List<MealRecord> meals) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return MealRecordCard(
          mealRecord: meal,
          onTap: () {
            context.pushNamed(
              'editMeal',
              extra: meal,
            );
          },
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