import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/templates/standard_page_layout.dart';
import '../design_system/atoms/tonton_button.dart';
import '../providers/user_profile_provider.dart';
import '../providers/user_weight_provider.dart';
import '../providers/calorie_savings_provider.dart';
import '../providers/pfc_balance_provider.dart';
import '../models/pfc_breakdown.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  final _weightController = TextEditingController();

  double _proteinRatio = 0.3;
  double _fatRatio = 0.2;

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final goals = ref.read(userGoalsProvider);
    _proteinRatio = goals.pfcRatio.protein;
    _fatRatio = goals.pfcRatio.fat;
  }

  double get _carbRatio => 1 - _proteinRatio - _fatRatio;

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await ref.read(userNameProvider.notifier).setName(name);
    }

    final goal = double.tryParse(_goalController.text);
    if (goal != null) {
      ref.read(monthlyCalorieGoalProvider.notifier).setGoal(goal);
    }

    final weight = double.tryParse(_weightController.text);
    if (weight != null) {
      await ref.read(userWeightProvider.notifier).setWeight(weight);
      await ref.read(userGoalsProvider.notifier).setBodyWeight(weight);
    }

    await ref.read(userGoalsProvider.notifier).setPfcRatio(
          PfcRatio(protein: _proteinRatio, fat: _fatRatio, carbohydrate: _carbRatio),
        );

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(userNameProvider);
    final monthlyGoal = ref.watch(monthlyCalorieGoalProvider);
    final weight = ref.watch(userWeightProvider);

    if (name != null && _nameController.text.isEmpty) {
      _nameController.text = name;
    }
    if (_goalController.text.isEmpty) {
      _goalController.text = monthlyGoal.toStringAsFixed(0);
    }
    if (weight != null && _weightController.text.isEmpty) {
      _weightController.text = weight.toString();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール編集')),
      body: StandardPageLayout(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'ユーザー名'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _goalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '月間目標 (kcal)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '体重 (kg)'),
          ),
          const SizedBox(height: 24),
          Text('PFCバランス (炭水化物は自動計算)'),
          Slider(
            label: 'たんぱく質 ${(100 * _proteinRatio).round()}%',
            value: _proteinRatio,
            min: 0,
            max: 1 - _fatRatio,
            divisions: 100,
            onChanged: (v) => setState(() => _proteinRatio = v),
          ),
          Slider(
            label: '脂質 ${(100 * _fatRatio).round()}%',
            value: _fatRatio,
            min: 0,
            max: 1 - _proteinRatio,
            divisions: 100,
            onChanged: (v) => setState(() => _fatRatio = v),
          ),
          Text('炭水化物 ${(100 * _carbRatio).round()}%'),
          const SizedBox(height: 24),
          TontonButton.primary(
            label: '保存',
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

