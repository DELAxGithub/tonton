import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/meal_record.dart';
import '../../../enums/meal_time_type.dart';
import '../../../providers/providers.dart';
import '../../../widgets/nutrition_editor.dart';
import '../../../widgets/nutrition_summary_card.dart';
import '../../../design_system/molecules/pfc_pie_chart.dart';
import '../../../theme/app_theme.dart';

class EditMealScreen extends ConsumerStatefulWidget {
  final MealRecord mealRecord;

  const EditMealScreen({super.key, required this.mealRecord});

  @override
  ConsumerState<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends ConsumerState<EditMealScreen> {
  late final TextEditingController _nameController;
  late double _calories;
  late double _protein;
  late double _fat;
  late double _carbs;
  late MealTimeType _mealTime;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final meal = widget.mealRecord;
    _nameController = TextEditingController(text: meal.mealName);
    _calories = meal.calories;
    _protein = meal.protein;
    _fat = meal.fat;
    _carbs = meal.carbs;
    _mealTime = meal.mealTimeType;
    _selectedDate = meal.consumedAt;
    _selectedTime = TimeOfDay.fromDateTime(meal.consumedAt);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _markChanged();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      _markChanged();
    }
  }

  void _onNutritionChanged(
    double calories,
    double protein,
    double fat,
    double carbs,
  ) {
    setState(() {
      _calories = calories;
      _protein = protein;
      _fat = fat;
      _carbs = carbs;
    });
    _markChanged();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final updated = widget.mealRecord.copyWith(
        mealName: _nameController.text,
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

      await ref.read(mealRecordsProvider.notifier).updateMealRecord(updated);
      ref.invalidate(mealRecordsProvider);
      ref.invalidate(todaysMealRecordsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${updated.mealName}を更新しました'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      context.pop();
    } catch (e) {
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

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('変更を破棄しますか？'),
        content: const Text('保存されていない変更があります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('破棄'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('食事を編集'),
          elevation: 0,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 80,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 料理名
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _nameController,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: '料理名',
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                        onChanged: (_) => _markChanged(),
                      ),
                    ),
                  ),

                  const SizedBox(height: TontonSpacing.lg),

                  // 栄養サマリー
                  NutritionSummaryCard(
                    calories: _calories,
                    protein: _protein,
                    fat: _fat,
                    carbs: _carbs,
                    title: '栄養成分',
                    showPercentages: true,
                  ),

                  const SizedBox(height: TontonSpacing.lg),

                  // 栄養素スライダー
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

                  // PFCバランス
                  Center(
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: PfcPieChart(
                        protein: _protein,
                        fat: _fat,
                        carbs: _carbs,
                      ),
                    ),
                  ),

                  const SizedBox(height: TontonSpacing.lg),

                  // 日時
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('日付'),
                          subtitle: Text(
                            DateFormat.yMd().format(_selectedDate),
                          ),
                          onTap: _pickDate,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('時刻'),
                          subtitle: Text(_selectedTime.format(context)),
                          onTap: _pickTime,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: TontonSpacing.md),

                  // 食事タイプ
                  SegmentedButton<MealTimeType>(
                    segments: MealTimeType.values
                        .map(
                          (e) => ButtonSegment(
                            value: e,
                            label: Text(e.displayName),
                          ),
                        )
                        .toList(),
                    selected: {_mealTime},
                    onSelectionChanged: (set) {
                      if (set.isNotEmpty) {
                        setState(() => _mealTime = set.first);
                        _markChanged();
                      }
                    },
                  ),
                ],
              ),
            ),

            // 保存ボタン
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
                label: Text(_isSaving ? '保存中...' : '更新する'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
