import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../design_system/templates/standard_page_layout.dart';
import '../design_system/atoms/tonton_card_base.dart';
import '../design_system/atoms/tonton_button.dart';
import '../providers/onboarding_start_date_provider.dart';
import '../providers/calorie_savings_provider.dart';
import '../providers/user_weight_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/pfc_balance_provider.dart';
import '../providers/weight_record_provider.dart';
import '../providers/last_health_fetch_provider.dart';
import '../services/health_service.dart';
import '../theme/tokens.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  final _weightController = TextEditingController();

  double _proteinRatio = 0.3;
  double _fatRatio = 0.2;
  bool _isEditing = false;
  String? _savingField;

  double get _carbRatio => 1 - _proteinRatio - _fatRatio;

  @override
  void initState() {
    super.initState();
    final goals = ref.read(userGoalsProvider);
    _proteinRatio = goals.pfcRatio.protein;
    _fatRatio = goals.pfcRatio.fat;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveName(String value) async {
    setState(() {
      _isEditing = true;
      _savingField = 'name';
    });
    await ref.read(userNameProvider.notifier).setName(value.trim());
    setState(() {
      _isEditing = false;
      _savingField = null;
    });
  }

  Future<void> _saveGoal(String value) async {
    final goal = double.tryParse(value);
    if (goal == null) return;
    setState(() {
      _isEditing = true;
      _savingField = 'goal';
    });
    ref.read(monthlyCalorieGoalProvider.notifier).setGoal(goal);
    setState(() {
      _isEditing = false;
      _savingField = null;
    });
  }

  Future<void> _saveWeight(String value) async {
    final weight = double.tryParse(value);
    if (weight == null) return;
    setState(() {
      _isEditing = true;
      _savingField = 'weight';
    });
    await ref.read(userWeightProvider.notifier).setWeight(weight);
    await ref.read(userGoalsProvider.notifier).setBodyWeight(weight);
    setState(() {
      _isEditing = false;
      _savingField = null;
    });
  }

  Future<void> _savePfc() async {
    setState(() {
      _isEditing = true;
      _savingField = 'pfc';
    });
    await ref.read(userGoalsProvider.notifier).setPfcRatio(
          PfcRatio(
            protein: _proteinRatio,
            fat: _fatRatio,
            carbohydrate: _carbRatio,
          ),
        );
    setState(() {
      _isEditing = false;
      _savingField = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userName = ref.watch(userNameProvider);
    final startDate = ref.watch(onboardingStartDateProvider);
    final savingsRecordsAsync = ref.watch(calorieSavingsDataProvider);
    final monthlyGoal = ref.watch(monthlyCalorieGoalProvider);
    final userWeightRecord = ref.watch(latestWeightRecordProvider);
    final lastFetched = ref.watch(lastHealthFetchProvider);

    if (userName != null && _nameController.text.isEmpty) {
      _nameController.text = userName;
    }
    if (_goalController.text.isEmpty) {
      _goalController.text = monthlyGoal.toStringAsFixed(0);
    }
    if (userWeightRecord != null && _weightController.text.isEmpty) {
      _weightController.text = userWeightRecord.weight.toString();
    }

    // 計算の詳細
    final totalDays = startDate != null
        ? DateTime.now().difference(startDate).inDays + 1
        : 0;
    final firstRecord = savingsRecordsAsync.maybeWhen(
      data: (records) => records.isNotEmpty ? records.first : null,
      orElse: () => null,
    );
    final lastRecord = savingsRecordsAsync.maybeWhen(
      data: (records) => records.isNotEmpty ? records.last : null,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
      ),
      body: StandardPageLayout(
        children: [
          // ユーザー情報カード
          TontonCardBase(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('アカウント情報',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.sm),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    suffixIcon: _savingField == 'name' && _isEditing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit, size: 16),
                  ),
                  onChanged: _saveName,
                ),
                const SizedBox(height: Spacing.md),
                Text('メール: ${user?.email ?? "未設定"}'),
                const SizedBox(height: Spacing.md),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: 'kg',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    suffixIcon: _savingField == 'weight' && _isEditing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit, size: 16),
                  ),
                  onChanged: _saveWeight,
                ),
                const SizedBox(height: Spacing.md),
                if (lastFetched != null)
                  Text(
                    '最終更新: ${DateFormat('MM/dd HH:mm').format(lastFetched)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // 目標設定カード
          TontonCardBase(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('目標設定', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('貯金開始日'),
                  trailing: Text(startDate != null
                      ? DateFormat('yyyy/MM/dd').format(startDate)
                      : '未設定'),
                  onTap: _pickStartDate,
                ),
                const SizedBox(height: Spacing.sm),
                TextField(
                  controller: _goalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: 'kcal',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    suffixIcon: _savingField == 'goal' && _isEditing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit, size: 16),
                  ),
                  onChanged: _saveGoal,
                ),
                const SizedBox(height: Spacing.sm),
                Text('PFCバランス',
                    style: Theme.of(context).textTheme.bodyMedium),
                Slider(
                  value: _proteinRatio,
                  min: 0.1,
                  max: 0.5,
                  divisions: 40,
                  label: 'たんぱく質 ${(100 * _proteinRatio).round()}%',
                  onChanged: (v) => setState(() => _proteinRatio = v),
                  onChangeEnd: (_) => _savePfc(),
                ),
                Slider(
                  value: _fatRatio,
                  min: 0.1,
                  max: 0.5,
                  divisions: 40,
                  label: '脂質 ${(100 * _fatRatio).round()}%',
                  onChanged: (v) => setState(() => _fatRatio = v),
                  onChangeEnd: (_) => _savePfc(),
                ),
                Text('炭水化物 ${(100 * _carbRatio).round()}%'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // データ管理カード
          TontonCardBase(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('データ管理',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.sm),
                if (lastRecord != null) ...[
                  Text(
                    '${lastRecord.cumulativeSavings.toStringAsFixed(0)} kcal',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text('記録日数: ${savingsRecordsAsync.maybeWhen(data: (r) => r.length, orElse: () => 0)} 日'),
                ],
                const SizedBox(height: Spacing.md),
                TontonButton.text(
                  label: 'データを再計算',
                  onPressed: () => _recalculateData(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final current = ref.read(onboardingStartDateProvider) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (!mounted) return;
    if (picked != null) {
      await ref.read(onboardingStartDateProvider.notifier).setDate(picked);
    }
  }

  void _recalculateData(BuildContext context) {
    ref.invalidate(calorieSavingsDataProvider);
    final service = HealthService();
    service.getLatestWeight(DateTime.now()).then((record) async {
      if (record != null) {
        await ref.read(userWeightProvider.notifier).setWeight(record.weight);
        await ref
            .read(userGoalsProvider.notifier)
            .setBodyWeight(record.weight);
        await ref.read(latestWeightRecordProvider.notifier).setRecord(record);
      }
      await ref.read(lastHealthFetchProvider.notifier).setTime(DateTime.now());
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('データを再計算しています...')),
    );
  }
}