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
import '../models/pfc_breakdown.dart';

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