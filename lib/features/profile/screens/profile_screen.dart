import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../design_system/templates/standard_page_layout.dart';
import '../../../design_system/atoms/tonton_card_base.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../providers/providers.dart';
import '../providers/user_profile_provider.dart';
import '../../progress/providers/pfc_balance_provider.dart';
import '../../health/providers/weight_record_provider.dart';
import '../../health/providers/last_health_fetch_provider.dart';
import '../../../services/health_service.dart';
import '../../../theme/tokens.dart';
import '../../../theme/app_theme.dart';
import '../../progress/providers/auto_pfc_provider.dart';
import '../../../core/providers/monthly_progress_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _targetDaysController = TextEditingController();
  final _weightFocusNode = FocusNode();
  final _targetWeightFocusNode = FocusNode();
  final _targetDaysFocusNode = FocusNode();

  bool _isEditing = false;
  String? _savingField;
  
  // Track the last known weight to detect changes
  double? _lastKnownWeight;

  @override
  void initState() {
    super.initState();
    // フォーカス状態の変更を監視
    _weightFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _targetDaysController.dispose();
    _weightFocusNode.dispose();
    _targetWeightFocusNode.dispose();
    _targetDaysFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveName(String value) async {
    // バリデーション
    if (value.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ニックネームを入力してください')));
      return;
    }
    if (value.trim().length > 20) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ニックネームは20文字以内で入力してください')));
      return;
    }

    setState(() {
      _isEditing = true;
      _savingField = 'name';
    });
    await ref
        .read(userProfileProvider.notifier)
        .updateDisplayName(value.trim());
    setState(() {
      _isEditing = false;
      _savingField = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ニックネームを更新しました')));
    }
  }

  Future<void> _saveGoal(String value) async {
    final goal = double.tryParse(value);
    if (goal == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('数値を入力してください')));
      return;
    }
    if (goal < 1000) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('月間目標は1000kcal以上で設定してください')));
      return;
    }

    setState(() {
      _isEditing = true;
      _savingField = 'goal';
    });
    
    // Use the monthly target notifier to ensure synchronization with home screen
    await ref.read(monthlyTargetNotifierProvider.notifier).updateTarget(goal);
    
    setState(() {
      _isEditing = false;
      _savingField = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('月間目標を更新しました')));
    }
  }

  Future<void> _saveWeight(String value) async {
    final weight = double.tryParse(value);
    if (weight == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('数値を入力してください')));
      return;
    }
    if (weight <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('体重は0より大きい値を入力してください')));
      return;
    }

    setState(() {
      _isEditing = true;
      _savingField = 'weight';
    });
    await ref.read(userWeightProvider.notifier).setWeight(weight);
    await ref.read(userGoalsProvider.notifier).setBodyWeight(weight);
    
    // Update the last known weight to prevent field from being overwritten
    _lastKnownWeight = weight;
    
    setState(() {
      _isEditing = false;
      _savingField = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('体重を更新しました')));
    }
  }

  Future<void> _saveTargetWeight(String value) async {
    final targetWeight = double.tryParse(value);
    if (targetWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数値を入力してください')),
      );
      return;
    }
    if (targetWeight < 30 || targetWeight > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('現実的な目標体重を入力してください')),
      );
      return;
    }

    setState(() {
      _isEditing = true;
      _savingField = 'targetWeight';
    });
    
    await ref.read(userProfileProvider.notifier).updateTargetWeight(targetWeight);
    
    setState(() {
      _isEditing = false;
      _savingField = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('目標体重を更新しました')),
      );
    }
  }

  Future<void> _saveTargetDays(String value) async {
    final targetDays = int.tryParse(value);
    if (targetDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日数を入力してください')),
      );
      return;
    }
    if (targetDays < 30 || targetDays > 365) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('30〜365日の範囲で入力してください')),
      );
      return;
    }

    setState(() {
      _isEditing = true;
      _savingField = 'targetDays';
    });
    
    await ref.read(userProfileProvider.notifier).updateTargetDays(targetDays);
    
    setState(() {
      _isEditing = false;
      _savingField = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('目標期間を更新しました')),
      );
    }
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
        await ref.read(userGoalsProvider.notifier).setBodyWeight(record.weight);
        await ref.read(latestWeightRecordProvider.notifier).setRecord(record);
      }
      await ref.read(lastHealthFetchProvider.notifier).setTime(DateTime.now());
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('データを再計算しています...')));
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('アカウント削除の確認'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('本当にアカウントを削除しますか？'),
              SizedBox(height: 16),
              Text(
                'この操作は取り消すことができません。',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '• すべての体重データが削除されます\n'
                '• すべての目標設定が削除されます\n'
                '• プロフィール情報が削除されます',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('削除する'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        await authService.deleteAccount();
        
        // The deletion will automatically sign out the user
        // and the auth state change will redirect to login
      } catch (e) {
        // Hide loading indicator
        if (context.mounted) {
          Navigator.of(context).pop();
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('アカウントの削除に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userName = ref.watch(userNameProvider);
    final userProfile = ref.watch(userProfileProvider);
    final startDate = ref.watch(onboardingStartDateProvider);
    final monthlyGoalAsync = ref.watch(monthlyTargetProvider);
    final userWeightRecord = ref.watch(latestWeightRecordProvider);
    final lastFetched = ref.watch(lastHealthFetchProvider);

    if (userName != null && _nameController.text.isEmpty) {
      _nameController.text = userName;
    }
    // Handle monthly goal field updates
    monthlyGoalAsync.when(
      data: (monthlyGoal) {
        if (_goalController.text.isEmpty) {
          _goalController.text = monthlyGoal.toStringAsFixed(0);
        }
      },
      loading: () {},
      error: (_, __) {},
    );
    
    // Handle weight field updates more carefully
    if (userWeightRecord != null) {
      final currentWeight = userWeightRecord.weight;
      // Update if the weight value has changed or if the field is empty
      if (_lastKnownWeight != currentWeight || _weightController.text.isEmpty) {
        _weightController.text = currentWeight.toString();
        _lastKnownWeight = currentWeight;
      }
    }
    
    // Handle target weight and days field updates
    if (userProfile.targetWeight != null && _targetWeightController.text.isEmpty) {
      _targetWeightController.text = userProfile.targetWeight!.toString();
    }
    if (userProfile.targetDays != null && _targetDaysController.text.isEmpty) {
      _targetDaysController.text = userProfile.targetDays!.toString();
    }

    return GestureDetector(
      onTap: () {
        // 画面タップでキーボードを閉じる
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('プロフィール')),
        body: StandardPageLayout(
          children: [
            // ユーザー情報カード
            TontonCardBase(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('基本情報', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: Spacing.sm),
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'ニックネーム',
                      hintText: 'ニックネームを入力',
                      helperText: 'アプリ内での表示名',
                      border: const OutlineInputBorder(),
                      suffixIcon:
                          _savingField == 'name' && _isEditing
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : IconButton(
                                icon: const Icon(Icons.save),
                                onPressed:
                                    () => _saveName(_nameController.text),
                              ),
                    ),
                    // onChangedを削除して自動保存を無効化
                    onSubmitted: (value) => _saveName(value),
                  ),
                  const SizedBox(height: Spacing.md),

                  // ダイエット目的の選択
                  Text(
                    'ダイエット目的',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'weight_loss',
                        label: Text('体重減少', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.trending_down, size: 16),
                      ),
                      ButtonSegment(
                        value: 'muscle_gain',
                        label: Text('筋肉増強', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.fitness_center, size: 16),
                      ),
                      ButtonSegment(
                        value: 'maintain',
                        label: Text('体型維持', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.balance, size: 16),
                      ),
                    ],
                    selected: userProfile.dietGoal != null ? {userProfile.dietGoal!} : {},
                    onSelectionChanged: (Set<String> newSelection) async {
                      if (newSelection.isNotEmpty) {
                        final goal = newSelection.first;
                        await ref
                            .read(userProfileProvider.notifier)
                            .updateDietGoal(goal);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ダイエット目的を更新しました'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: Spacing.md),

                  Text('メール: ${user?.email ?? "未設定"}'),
                  const SizedBox(height: Spacing.md),
                  TextField(
                    controller: _weightController,
                    focusNode: _weightFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: '体重',
                      suffixText: 'kg',
                      border: const OutlineInputBorder(),
                      suffixIcon:
                          _savingField == 'weight' && _isEditing
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : IconButton(
                                icon: const Icon(Icons.save),
                                onPressed: () {
                                  _weightFocusNode.unfocus();
                                  _saveWeight(_weightController.text);
                                },
                              ),
                    ),
                    // onChangedを削除して自動保存を無効化
                    onSubmitted: (value) {
                      _weightFocusNode.unfocus();
                      _saveWeight(value);
                    },
                  ),
                  Row(
                    children: [
                      Icon(
                        lastFetched != null ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color:
                            lastFetched != null
                                ? TontonColors.success
                                : TontonColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lastFetched != null ? 'HealthKit連携済み' : 'HealthKit未連携',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              lastFetched != null
                                  ? TontonColors.success
                                  : TontonColors.warning,
                        ),
                      ),
                    ],
                  ),
                  if (lastFetched != null) ...[
                    const SizedBox(height: Spacing.md),
                    Text(
                      '最終更新: ${DateFormat('MM/dd HH:mm').format(lastFetched)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
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
                  
                  // 目標体重と目標期間
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _targetWeightController,
                          focusNode: _targetWeightFocusNode,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: '目標体重',
                            suffixText: 'kg',
                            border: const OutlineInputBorder(),
                            suffixIcon: _savingField == 'targetWeight' && _isEditing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () {
                                      _targetWeightFocusNode.unfocus();
                                      _saveTargetWeight(_targetWeightController.text);
                                    },
                                  ),
                          ),
                          onSubmitted: (value) {
                            _targetWeightFocusNode.unfocus();
                            _saveTargetWeight(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _targetDaysController,
                          focusNode: _targetDaysFocusNode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: '目標期間',
                            suffixText: '日',
                            border: const OutlineInputBorder(),
                            suffixIcon: _savingField == 'targetDays' && _isEditing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () {
                                      _targetDaysFocusNode.unfocus();
                                      _saveTargetDays(_targetDaysController.text);
                                    },
                                  ),
                          ),
                          onSubmitted: (value) {
                            _targetDaysFocusNode.unfocus();
                            _saveTargetDays(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // 自動計算された月間目標カロリー
                  if (userProfile.targetWeight != null && userProfile.targetDays != null && userWeightRecord != null) ...[
                    const SizedBox(height: Spacing.sm),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '自動計算された目標',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _calculateMonthlyCalorieTarget(
                              currentWeight: userWeightRecord.weight,
                              targetWeight: userProfile.targetWeight!,
                              targetDays: userProfile.targetDays!,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: Spacing.sm),
                  const Divider(),
                  const SizedBox(height: Spacing.sm),
                  
                  // 開始日設定
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('開始日'),
                    trailing: Text(
                      startDate != null
                          ? DateFormat('yyyy/MM/dd').format(startDate)
                          : '未設定',
                    ),
                    onTap: _pickStartDate,
                  ),
                  const SizedBox(height: Spacing.sm),
                  
                  // 月間目標（手動設定）
                  TextField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: '月間目標（手動設定）',
                      suffixText: 'kcal',
                      border: const OutlineInputBorder(),
                      helperText: '自動計算を使用しない場合は手動で設定',
                      suffixIcon:
                          _savingField == 'goal' && _isEditing
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : IconButton(
                                icon: const Icon(Icons.save),
                                onPressed:
                                    () => _saveGoal(_goalController.text),
                              ),
                    ),
                    // onChangedを削除して自動保存を無効化
                    onSubmitted: (value) => _saveGoal(value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // 栄養バランスカード
            _buildNutritionBalanceCard(context, ref),
            const SizedBox(height: Spacing.lg),

            // データ管理カード
            TontonCardBase(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('データ管理', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: Spacing.sm),
                  TontonButton.text(
                    label: 'データを再計算',
                    onPressed: () => _recalculateData(context),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    '※ HealthKitから最新データを取得して再計算します',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    'その他の機能は開発中です',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // アカウント削除ボタン
            const SizedBox(height: 16),
            TontonButton(
              label: 'アカウント削除',
              icon: CupertinoIcons.delete,
              onPressed: () => _showDeleteAccountDialog(context, ref),
              style: TontonButtonStyle.destructive,
              isFullWidth: true,
            ),

          ],
        ),
      ),
    );
  }

  String _calculateMonthlyCalorieTarget({
    required double currentWeight,
    required double targetWeight,
    required int targetDays,
  }) {
    // 体重差（kg）
    final weightDiff = currentWeight - targetWeight;
    // 必要な総カロリー赤字（1kg = 7200kcal）
    final totalCalorieDeficit = weightDiff * 7200;
    // 1日あたりの必要カロリー赤字
    final dailyCalorieDeficit = totalCalorieDeficit / targetDays;
    // 月間（30日）換算
    final monthlyCalorieDeficit = dailyCalorieDeficit * 30;
    
    return '${monthlyCalorieDeficit.toStringAsFixed(0)} kcal/月（${dailyCalorieDeficit.toStringAsFixed(0)} kcal/日）';
  }

  Widget _buildNutritionBalanceCard(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final autoPfc = ref.watch(autoPfcTargetProvider);
    final dailyTarget = ref.watch(dailyCalorieTargetProvider);

    // ダイエット目的の表示テキスト
    final dietGoalText =
        userProfile.dietGoal == 'weight_loss'
            ? '体重減少'
            : userProfile.dietGoal == 'muscle_gain'
            ? '筋肉増強'
            : userProfile.dietGoal == 'maintain'
            ? '体型維持'
            : '未設定';

    return TontonCardBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('栄養バランス', style: Theme.of(context).textTheme.titleMedium),
              if (autoPfc != null)
                Icon(Icons.check_circle, color: TontonColors.success, size: 20),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          if (autoPfc != null) ...[
            // ユーザー情報表示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'ダイエット目的: $dietGoalText',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '体重: ${userProfile.weight?.toStringAsFixed(1) ?? "未設定"} kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),

            // 自動計算されたPFC値
            Text(
              '目標カロリー: $dailyTarget kcal/日',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Spacing.sm),

            _buildPfcRow(
              context,
              'たんぱく質',
              autoPfc.protein,
              autoPfc.protein * 4,
              TontonColors.proteinColor,
            ),
            const SizedBox(height: 8),
            _buildPfcRow(
              context,
              '脂質',
              autoPfc.fat,
              autoPfc.fat * 9,
              TontonColors.fatColor,
            ),
            const SizedBox(height: 8),
            _buildPfcRow(
              context,
              '炭水化物',
              autoPfc.carbohydrate,
              autoPfc.carbohydrate * 4,
              TontonColors.carbsColor,
            ),

            const SizedBox(height: Spacing.md),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TontonColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: TontonColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '※ ダイエット目的に応じて自動計算されています',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: TontonColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // プロフィール未設定の場合
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TontonColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: TontonColors.warning,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'プロフィール情報が不足しています',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '体重・性別・年齢層を設定すると\n最適な栄養バランスを自動計算します',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPfcRow(
    BuildContext context,
    String label,
    double grams,
    double calories,
    Color color,
  ) {
    final percentage =
        (calories / ref.read(dailyCalorieTargetProvider) * 100).round();

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(
          '${grams.round()}g',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          '(${calories.round()}kcal / $percentage%)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
