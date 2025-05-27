import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/templates/standard_page_layout.dart';
import '../design_system/atoms/tonton_card_base.dart';
import '../providers/onboarding_start_date_provider.dart';
import '../providers/calorie_savings_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/pfc_balance_provider.dart';
import '../providers/weight_record_provider.dart';
import '../providers/last_health_fetch_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userNameProvider);
    ref.watch(onboardingStartDateProvider);
    final savingsRecordsAsync = ref.watch(calorieSavingsDataProvider);
    final monthlyGoal = ref.watch(monthlyCalorieGoalProvider);
    final userWeightRecord = ref.watch(latestWeightRecordProvider);
    ref.watch(lastHealthFetchProvider);

    if (userName != null && _nameController.text.isEmpty) {
      _nameController.text = userName;
    }
    if (_goalController.text.isEmpty) {
      _goalController.text = monthlyGoal.toStringAsFixed(0);
    }
    if (userWeightRecord != null && _weightController.text.isEmpty) {
      _weightController.text = userWeightRecord.weight.toString();
    }



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
              children: const [],
            ),
          ),
        ],
      ),
    ),
  );
  }
}
