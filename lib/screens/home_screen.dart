import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

import '../l10n/app_localizations.dart';
import '../models/meal_record.dart';
import '../providers/health_provider.dart';
import '../providers/meal_records_provider.dart';
import '../providers/ai_advice_provider.dart';
import '../widgets/meal_record_card.dart';
import '../widgets/monthly_progress_widget.dart';
import '../widgets/activity_content.dart';
import '../widgets/ai_advice_display.dart';
import '../utils/date_formatter.dart';
import '../utils/icon_mapper.dart';
import '../routes/router.dart';

// すべてのインポート後に定数宣言
const bool kShowDebugPanel = false;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    developer.log('HomeScreen initState called', name: 'TonTon.HomeScreen');
    super.initState();
    
    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);
    
    // Add listener for tab changes to update FloatingActionButton
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Force a rebuild when tab changes to update FAB
        setState(() {});
      }
    });
    
    // Request permissions on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log('HomeScreen postFrameCallback - requesting permissions', name: 'TonTon.HomeScreen');
      try {
        final provider = provider_pkg.Provider.of<HealthProvider>(context, listen: false);
        developer.log('Provider instance in postFrameCallback: ${provider.toString()}', name: 'TonTon.HomeScreen');
        provider.requestPermissions();
      } catch (e, stack) {
        developer.log('Error in postFrameCallback: $e', name: 'TonTon.HomeScreen.error', error: e, stackTrace: stack);
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    developer.log('HomeScreen build called', name: 'TonTon.HomeScreen');
    final today = DateTime.now();
    final todayMeals = ref.watch(todaysMealRecordsProvider);
    final todayTotalCalories = ref.watch(todaysTotalCaloriesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('TonTon Health Pro'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Tooltip(
                message: AppLocalizations.of(context).tabActivity,
                child: Icon(
                  CupertinoIcons.waveform_path,
                  semanticLabel: AppLocalizations.of(context).tabActivity,
                ),
              ),
            ),
            Tab(
              icon: Tooltip(
                message: AppLocalizations.of(context).tabMeals,
                child: Icon(
                  CupertinoIcons.cart,
                  semanticLabel: AppLocalizations.of(context).tabMeals,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Activity tab
          Column(
            children: [
              // Monthly progress widget at the top
              const MonthlyProgressWidget(),
              
              // Debug panel (optional)
              if (kShowDebugPanel)
                Container(
                  color: Colors.amber.shade100,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context).debugPanel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () {
                          developer.log('Manual provider test', name: 'TonTon.HomeScreen.debug');
                          try {
                            final provider = provider_pkg.Provider.of<HealthProvider>(context, listen: false);
                            developer.log('Provider accessible: ${provider.toString()}', name: 'TonTon.HomeScreen.debug');
                          } catch (e) {
                            developer.log('Provider access error: $e', name: 'TonTon.HomeScreen.debug');
                          }
                        },
                        child: Text(AppLocalizations.of(context).testProvider)
                      ),
                    ],
                  ),
                ),
              
              // Activity content
              const Expanded(
                child: ActivityContent(),
              ),
            ],
          ),
          
          // Meals tab
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Today's date and total calories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today, ${DateFormatter.formatDate(today)}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            TontonIcons.energy,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${todayTotalCalories.toStringAsFixed(0)} kcal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Meal list
                Expanded(
                  child: todayMeals.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              defaultTargetPlatform == TargetPlatform.iOS
                                  ? CupertinoIcons.cart_badge_minus
                                  : Icons.no_food,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).noMealsRecorded,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context).tapAddMeal,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.push(TontonRoutes.savingsTrend);
                              },
                              icon: const Icon(Icons.trending_up),
                              label: Text(AppLocalizations.of(context).calorieSavingsGraph),
                            ),
                            const SizedBox(height: 20),
                            _buildAiAdviceSection(todayMeals, context),
                          ],
                        ),
                      )
                    : Column( // Changed from ListView.builder to Column to add button below
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: todayMeals.length,
                              itemBuilder: (context, index) {
                                final meal = todayMeals[index];
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
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildAiAdviceSection(todayMeals, context),
                          const SizedBox(height: 10),
                        ],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAiAdviceSection(List<MealRecord> todayMeals, BuildContext context) {
    final aiAdviceState = ref.watch(aiAdviceProvider);

    return Column(
      children: [
        if (aiAdviceState.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: CircularProgressIndicator(),
          )
        else
          Tooltip(
            message: AppLocalizations.of(context).aiAdviceRequest,
            child: ElevatedButton.icon(
              icon: Icon(
                defaultTargetPlatform == TargetPlatform.iOS
                    ? CupertinoIcons.lightbulb
                    : Icons.lightbulb_outline,
                semanticLabel: AppLocalizations.of(context).aiAdviceRequest,
              ),
              label: Text(AppLocalizations.of(context).aiAdviceShort),
              onPressed: todayMeals.length < 2
                  ? null
                  : () => ref
                      .read(aiAdviceProvider.notifier)
                      .fetchAdvice(todayMeals, context),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        if (todayMeals.length < 2)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              AppLocalizations.of(context).aiAdviceDisabled,
              style: TextStyle(color: Theme.of(context).disabledColor),
              textAlign: TextAlign.center,
            ),
          ),
        aiAdviceState.when(
          data: (advice) => advice != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: AiAdviceDisplay(advice: advice),
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(AppLocalizations.of(context).aiAdviceError(e.toString())),
          ),
        ),
      ],
    );
  }

  
  Widget _buildFloatingActionButton() {
    // Show different FABs depending on which tab is active
    if (_tabController.index == 1) {
      // Meals tab - Show add meal button
      return FloatingActionButton(
        onPressed: () {
          // Navigate to the meal input screen
          context.pushNamed('addMeal');
        },
        tooltip: AppLocalizations.of(context).addMeal,
        child: Icon(
          Icons.add,
          semanticLabel: AppLocalizations.of(context).addMeal,
        ),
      );
    } else {
      // Activity tab - No FAB
      return const SizedBox.shrink();
    }
  }
}