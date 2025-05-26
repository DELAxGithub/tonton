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
import 'package:go_router/go_router.dart';
import '../routes/router.dart';
import '../services/health_service.dart';
import '../theme/tokens.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userName = ref.watch(userNameProvider);
    final startDate = ref.watch(onboardingStartDateProvider);
    final savingsRecordsAsync = ref.watch(calorieSavingsDataProvider);
    final monthlyGoal = ref.watch(monthlyCalorieGoalProvider);
    final userWeightRecord = ref.watch(latestWeightRecordProvider);
    final lastFetched = ref.watch(lastHealthFetchProvider);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(TontonRoutes.profileEdit),
          ),
        ],
      ),
      body: StandardPageLayout(
        children: [
          // ユーザー情報
          TontonCardBase(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('アカウント情報',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.sm),
                Text('メール: ${user?.email ?? "未設定"}'),
                Text('名前: ${userName ?? "未設定"}'),
                Text('体重: ${userWeightRecord?.formattedWeight ?? "データなし"}'),
                Text('体脂肪率: ${userWeightRecord?.formattedBodyFat ?? "データなし"}'),
                Text('体脂肪量: ${userWeightRecord?.formattedBodyFatMass ?? "データなし"}'),
                if (lastFetched != null)
                  Text('最終更新: ${DateFormat('MM/dd HH:mm').format(lastFetched)}'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // 貯金設定
          TontonCardBase(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('貯金設定',
                        style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showStartDateEditDialog(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Text('開始日: ${startDate != null ? DateFormat('yyyy/MM/dd').format(startDate) : "未設定"}'),
                Text('月間目標: ${monthlyGoal.toStringAsFixed(0)} kcal'),
                Text('計算期間: $totalDays 日間'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // 貯金計算の詳細
          TontonCardBase(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('貯金計算の内訳',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.sm),
                if (firstRecord != null && lastRecord != null) ...[
                  Text('データ取得期間: ${DateFormat('MM/dd').format(firstRecord.date)} 〜 ${DateFormat('MM/dd').format(lastRecord.date)}'),
                  Text(
                    '記録日数: ${savingsRecordsAsync.maybeWhen(data: (r) => r.length, orElse: () => 0)} 日',
                  ),
                  const Divider(),
                  Text('累積貯金額: ${lastRecord.cumulativeSavings.toStringAsFixed(0)} kcal',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(height: Spacing.xs),
                  Text('※ 開始日以降のHealthKitデータから計算',
                      style: Theme.of(context).textTheme.bodySmall),
                ] else
                  const Text('データがありません'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          // データリセット
          TontonCardBase(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('データ管理',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Spacing.sm),
                TontonButton.secondary(
                  label: 'データを再計算',
                  onPressed: () => _recalculateData(context, ref),
                ),
                const SizedBox(height: Spacing.sm),
                Text('※ HealthKitから最新データを取得して再計算します',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStartDateEditDialog(BuildContext context, WidgetRef ref) {
    showDatePicker(
      context: context,
      initialDate: ref.read(onboardingStartDateProvider) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    ).then((picked) {
      if (!context.mounted) return;
      if (picked != null) {
        ref.read(onboardingStartDateProvider.notifier).setDate(picked);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('開始日を更新しました。データを再計算してください。')),
        );
      }
    });
  }

  void _recalculateData(BuildContext context, WidgetRef ref) {
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