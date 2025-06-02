import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/estimated_meal_nutrition.dart';
import '../../../models/meal_record.dart';
import '../../../models/pfc_breakdown.dart';
import '../../../enums/meal_time_type.dart';
import '../../../providers/providers.dart';
import '../../../routes/router.dart';
import '../../../widgets/nutrition_editor.dart';
import '../../../widgets/nutrition_summary_card.dart';
import '../../../design_system/molecules/pfc_pie_chart.dart';
import '../../../features/progress/providers/auto_pfc_provider.dart';
import '../../../theme/app_theme.dart';

class AIMealLoggingStep3ConfirmEdit extends ConsumerStatefulWidget {
  final File imageFile;
  final EstimatedMealNutrition nutrition;
  const AIMealLoggingStep3ConfirmEdit({
    super.key,
    required this.imageFile,
    required this.nutrition,
  });

  @override
  ConsumerState<AIMealLoggingStep3ConfirmEdit> createState() => _State();
}

class _State extends ConsumerState<AIMealLoggingStep3ConfirmEdit> {
  late final TextEditingController _name;
  late double _calories;
  late double _protein;
  late double _fat;
  late double _carbs;
  double _quantityMultiplier = 1.0;
  late MealTimeType _mealTime;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.nutrition.mealName);
    _calories = widget.nutrition.calories;
    _protein = widget.nutrition.nutrients.protein;
    _fat = widget.nutrition.nutrients.fat;
    _carbs = widget.nutrition.nutrients.carbs;
    
    // Set meal time based on current time
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) {
      _mealTime = MealTimeType.breakfast;
    } else if (hour >= 10 && hour < 15) {
      _mealTime = MealTimeType.lunch;
    } else if (hour >= 15 && hour < 21) {
      _mealTime = MealTimeType.dinner;
    } else {
      _mealTime = MealTimeType.snack;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _updateQuantity(double multiplier) {
    setState(() {
      _quantityMultiplier = multiplier;
      final baseNutrition = widget.nutrition;
      _calories = baseNutrition.calories * multiplier;
      _protein = baseNutrition.nutrients.protein * multiplier;
      _fat = baseNutrition.nutrients.fat * multiplier;
      _carbs = baseNutrition.nutrients.carbs * multiplier;
    });
  }

  void _onNutritionChanged(double calories, double protein, double fat, double carbs) {
    setState(() {
      _calories = calories;
      _protein = protein;
      _fat = fat;
      _carbs = carbs;
      // Reset quantity multiplier when manually editing
      _quantityMultiplier = 0;
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final record = MealRecord(
        mealName: _name.text,
        calories: _calories,
        protein: _protein,
        fat: _fat,
        carbs: _carbs,
        mealTimeType: _mealTime,
        consumedAt: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
      );

      final notifier = ref.read(mealRecordsProvider.notifier);
      await notifier.addMealRecord(record);
      ref.invalidate(mealRecordsProvider);
      ref.invalidate(todaysMealRecordsProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${record.mealName}を記録しました！'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      context.go(TontonRoutes.home);
    } catch (e, _) {

      if (!mounted) return;
      setState(() => _isSaving = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('エラー'),
          content: Text('保存に失敗しました:\n$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todaysTotals = ref.watch(todaysPfcProvider);
    final dailyTarget = ref.watch(dailyCalorieTargetProvider);
    final pfcTargets = ref.watch(autoPfcTargetProvider);
    
    // Calculate totals including this meal
    final currentTotalCalories = ref.watch(todaysTotalCaloriesProvider);
    final totalCalories = (currentTotalCalories ?? 0) + _calories;
    final totalProtein = (todaysTotals?.protein ?? 0) + _protein;
    final totalFat = (todaysTotals?.fat ?? 0) + _fat;
    final totalCarbs = (todaysTotals?.carbohydrate ?? 0) + _carbs;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(TontonRoutes.aiMealCamera),
        ),
        title: const Text('これで合ってる？'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 80, // Space for FAB
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image preview card
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: '料理名',
                            border: InputBorder.none,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: TontonSpacing.lg),
                
                // Nutrition summary card
                NutritionSummaryCard(
                  calories: _calories,
                  protein: _protein,
                  fat: _fat,
                  carbs: _carbs,
                  title: '栄養成分',
                  showPercentages: true,
                ),
                
                const SizedBox(height: TontonSpacing.lg),
                
                // Quantity adjustment buttons
                _buildQuantityAdjustmentSection(),
                
                const SizedBox(height: TontonSpacing.lg),
                
                // Nutrition editor with sliders
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(TontonSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '栄養素を調整',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: TontonSpacing.md),
                        NutritionEditor(
                          calories: _calories,
                          protein: _protein,
                          fat: _fat,
                          carbs: _carbs,
                          onChanged: _onNutritionChanged,
                          maxCalories: 1500,
                          maxProtein: 150,
                          maxFat: 100,
                          maxCarbs: 300,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: TontonSpacing.lg),
                
                // PFC balance visualization
                Row(
                  children: [
                    // PFC Pie Chart
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: PfcPieChart(
                        protein: _protein,
                        fat: _fat,
                        carbs: _carbs,
                      ),
                    ),
                    const SizedBox(width: TontonSpacing.md),
                    // Daily goal comparison
                    Expanded(
                      child: _buildDailyGoalComparison(
                        totalCalories: totalCalories,
                        totalProtein: totalProtein,
                        totalFat: totalFat,
                        totalCarbs: totalCarbs,
                        dailyTarget: dailyTarget.toDouble(),
                        pfcTargets: pfcTargets,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: TontonSpacing.lg),
                
                // Date and time selection
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('いつ食べた？'),
                        subtitle: Text(DateFormat.yMd().format(_selectedDate)),
                        onTap: _pickDate,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('何時に食べた？'),
                        subtitle: Text(_selectedTime.format(context)),
                        onTap: _pickTime,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: TontonSpacing.md),
                
                // Meal type selection
                SegmentedButton<MealTimeType>(
                  segments: MealTimeType.values
                      .map((e) => ButtonSegment(value: e, label: Text(e.displayName)))
                      .toList(),
                  selected: {_mealTime},
                  onSelectionChanged: (set) {
                    if (set.isNotEmpty) {
                      setState(() => _mealTime = set.first);
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Floating action button for save
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSaving ? '保存中...' : '記録する'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityAdjustmentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TontonSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '量の調整',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TontonSpacing.sm),
            Wrap(
              spacing: TontonSpacing.sm,
              runSpacing: TontonSpacing.sm,
              children: [
                _buildQuantityButton('1/2', 0.5),
                _buildQuantityButton('3/4', 0.75),
                _buildQuantityButton('標準', 1.0),
                _buildQuantityButton('1.5倍', 1.5),
                _buildQuantityButton('2倍', 2.0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(String label, double multiplier) {
    final isSelected = _quantityMultiplier == multiplier;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _updateQuantity(multiplier),
      backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildDailyGoalComparison({
    required double totalCalories,
    required double totalProtein,
    required double totalFat,
    required double totalCarbs,
    required double dailyTarget,
    required PfcBreakdown? pfcTargets,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TontonSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日の合計（この食事含む）',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: TontonSpacing.sm),
            
            // Calories
            _buildProgressRow(
              label: 'カロリー',
              value: totalCalories,
              target: dailyTarget,
              unit: 'kcal',
              color: theme.colorScheme.primary,
            ),
            
            if (pfcTargets != null) ...[
              const SizedBox(height: TontonSpacing.xs),
              
              // Protein
              _buildProgressRow(
                label: 'タンパク質',
                value: totalProtein,
                target: pfcTargets.protein,
                unit: 'g',
                color: TontonColors.proteinColor,
              ),
              
              const SizedBox(height: TontonSpacing.xs),
              
              // Fat
              _buildProgressRow(
                label: '脂質',
                value: totalFat,
                target: pfcTargets.fat,
                unit: 'g',
                color: TontonColors.fatColor,
              ),
              
              const SizedBox(height: TontonSpacing.xs),
              
              // Carbs
              _buildProgressRow(
                label: '炭水化物',
                value: totalCarbs,
                target: pfcTargets.carbohydrate,
                unit: 'g',
                color: TontonColors.carbsColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow({
    required String label,
    required double value,
    required double target,
    required String unit,
    required Color color,
  }) {
    final percentage = target > 0 ? (value / target * 100).clamp(0, 150) : 0;
    final isOver = value > target;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${value.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isOver ? Colors.orange : null,
                fontWeight: isOver ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            isOver ? Colors.orange : color,
          ),
        ),
      ],
    );
  }
}
