import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/estimated_meal_nutrition.dart';
import '../../models/meal_record.dart';
import '../../enums/meal_time_type.dart';
import '../../providers/meal_records_provider.dart';
import '../../routes/router.dart';
import '../../widgets/labeled_text_field.dart';

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
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _fat;
  late final TextEditingController _carbs;
  MealTimeType _mealTime = MealTimeType.lunch;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.nutrition.mealName);
    _calories = TextEditingController(text: widget.nutrition.calories.toString());
    _protein =
        TextEditingController(text: widget.nutrition.nutrients.protein.toString());
    _fat = TextEditingController(text: widget.nutrition.nutrients.fat.toString());
    _carbs =
        TextEditingController(text: widget.nutrition.nutrients.carbs.toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _calories.dispose();
    _protein.dispose();
    _fat.dispose();
    _carbs.dispose();
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

  Future<void> _save() async {
    final record = MealRecord(
      mealName: _name.text,
      calories: double.tryParse(_calories.text) ?? 0,
      protein: double.tryParse(_protein.text) ?? 0,
      fat: double.tryParse(_fat.text) ?? 0,
      carbs: double.tryParse(_carbs.text) ?? 0,
      mealTimeType: _mealTime,
      consumedAt: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
    );
    await ref.read(mealRecordsProvider.notifier).addMealRecord(record);
    if (!mounted) return;
    context.go(TontonRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(TontonRoutes.aiMealCamera),
        ),
        title: const Text('これで合ってる？'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(height: 16),
            LabeledTextField(label: '料理名', controller: _name),
            const SizedBox(height: 8),
            LabeledTextField(label: 'カロリー', controller: _calories),
            const SizedBox(height: 8),
            LabeledTextField(label: 'タンパク質', controller: _protein),
            const SizedBox(height: 8),
            LabeledTextField(label: '脂質', controller: _fat),
            const SizedBox(height: 8),
            LabeledTextField(label: '炭水化物', controller: _carbs),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('いつ食べた？'),
              subtitle: Text(DateFormat.yMd().format(_selectedDate)),
              onTap: _pickDate,
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('何時に食べた？'),
              subtitle: Text(_selectedTime.format(context)),
              onTap: _pickTime,
            ),
            const SizedBox(height: 16),
            SegmentedButton<MealTimeType>(
              segments: MealTimeType.values
                  .map((e) => ButtonSegment(value: e, label: Text(e.displayName)))
                  .toList(),
              selected: {_mealTime},
              onSelectionChanged: (set) => setState(() => _mealTime = set.first),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: const Text('この内容で記録する！'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.go(
                TontonRoutes.aiMealAnalyzing,
                extra: widget.imageFile.path,
              ),
              child: const Text('もう一度AI解析'),
            )
          ],
        ),
      ),
    );
  }
}
