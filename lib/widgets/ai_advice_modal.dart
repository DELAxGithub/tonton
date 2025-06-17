import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';
import '../features/meal_logging/providers/ai_advice_provider.dart';
import '../features/meal_logging/providers/ai_advice_cache_provider.dart';
import '../features/meal_logging/providers/meal_records_provider.dart';
import '../design_system/atoms/tonton_button.dart';
import '../design_system/molecules/feedback/loading_indicator.dart';

/// AIアドバイスをモーダルボトムシートで表示
Future<void> showAIAdviceModal(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AIAdviceModalContent(),
  );
}

class _AIAdviceModalContent extends ConsumerStatefulWidget {
  const _AIAdviceModalContent();

  @override
  ConsumerState<_AIAdviceModalContent> createState() =>
      _AIAdviceModalContentState();
}

class _AIAdviceModalContentState extends ConsumerState<_AIAdviceModalContent> {
  @override
  void initState() {
    super.initState();
    // モーダルが開かれたときに最新のアドバイスを取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAdviceIfNeeded();
    });
  }

  void _fetchAdviceIfNeeded() {
    final adviceState = ref.read(cachedAiAdviceProvider);
    final todayMeals = ref.read(todaysMealRecordsProvider);

    // キャッシュがない場合やエラーの場合に新規取得
    if (!adviceState.hasValue || adviceState.hasError) {
      final locale = Localizations.localeOf(context).languageCode;
      ref.read(aiAdviceProvider.notifier).fetchAdvice(todayMeals, locale);
    }
  }

  Future<void> _refreshAdvice() async {
    // キャッシュを無効化して再取得
    await ref.read(aiAdviceCacheProvider.notifier).invalidateCache();
    ref.read(aiAdviceProvider.notifier).reset();

    final todayMeals = ref.read(todaysMealRecordsProvider);
    final locale = Localizations.localeOf(context).languageCode;
    ref.read(aiAdviceProvider.notifier).fetchAdvice(todayMeals, locale);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adviceAsync = ref.watch(cachedAiAdviceProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85, // 高さを増やして表示領域を拡大
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ハンドルバー
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('🐷', style: theme.textTheme.titleLarge),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'トントンコーチ',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AIがあなたの食事をサポート',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // コンテンツ
          Expanded(
            child: adviceAsync.when(
              loading:
                  () => const Center(
                    child: LoadingIndicator(message: 'AIアドバイスを生成中...'),
                  ),
              error:
                  (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'アドバイスの取得に失敗しました',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TontonButton.primary(
                            label: '再試行',
                            onPressed: _refreshAdvice,
                          ),
                        ],
                      ),
                    ),
                  ),
              data: (advice) {
                if (advice == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'アドバイスがありません',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '食事を記録すると、AIからアドバイスが届きます',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TontonButton.primary(
                            label: 'アドバイスを取得',
                            onPressed: _refreshAdvice,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    48,
                  ), // 下部に余白を追加
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // カロリー貯金状況
                      if (advice.currentSavings != null &&
                          advice.savingsStatus != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                advice.savingsStatus == '黒字'
                                    ? TontonColors.success.withValues(
                                      alpha: 0.1,
                                    )
                                    : TontonColors.warning.withValues(
                                      alpha: 0.1,
                                    ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  advice.savingsStatus == '黒字'
                                      ? TontonColors.success.withValues(
                                        alpha: 0.3,
                                      )
                                      : TontonColors.warning.withValues(
                                        alpha: 0.3,
                                      ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                advice.savingsStatus == '黒字'
                                    ? Icons.savings
                                    : Icons.trending_down,
                                size: 24,
                                color:
                                    advice.savingsStatus == '黒字'
                                        ? TontonColors.success
                                        : TontonColors.warning,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'カロリー貯金',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                  Text(
                                    '${advice.currentSavings} kcal (${advice.savingsStatus})',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              advice.savingsStatus == '黒字'
                                                  ? TontonColors.success
                                                  : TontonColors.warning,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // トントン先生からのメッセージ
                      if (advice.tontonAdvice != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  advice.isHaruMode == true
                                      ? [
                                        Colors.pink.shade50,
                                        Colors.purple.shade50,
                                      ]
                                      : [
                                        theme.colorScheme.primaryContainer,
                                        theme.colorScheme.secondaryContainer,
                                      ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    advice.isHaruMode == true ? '🌸' : '🐷',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    advice.isHaruMode == true
                                        ? 'ハルちゃん'
                                        : 'トントン先生',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (advice.specialDayTheme != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.tertiary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        advice.specialDayTheme!,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onTertiary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                advice.tontonAdvice!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 今日の摂取状況サマリー
                      if (advice.todaysSummary != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.assessment,
                                    size: 20,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '今日の摂取状況',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${advice.todaysSummary!.consumedCalories.toStringAsFixed(0)} / ${advice.todaysSummary!.targetCalories.toStringAsFixed(0)} kcal',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildBalanceStatus(
                                    'タンパク質',
                                    advice
                                        .todaysSummary!
                                        .balanceStatus['protein']!,
                                    theme,
                                  ),
                                  _buildBalanceStatus(
                                    '脂質',
                                    advice.todaysSummary!.balanceStatus['fat']!,
                                    theme,
                                  ),
                                  _buildBalanceStatus(
                                    '炭水化物',
                                    advice
                                        .todaysSummary!
                                        .balanceStatus['carbohydrate']!,
                                    theme,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // メインアドバイス
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.tips_and_updates,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '今日のアドバイス',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              advice.adviceMessage ?? advice.advice ?? '',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      // メニュー提案（v1形式）
                      if (advice.menuSuggestion != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'おすすめメニュー',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.secondaryContainer,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                advice.menuSuggestion!.menuName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                advice.menuSuggestion!.description,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              // 栄養情報
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildNutrientInfo(
                                      'カロリー',
                                      '${advice.menuSuggestion!.estimatedNutrition.calories.toStringAsFixed(0)}kcal',
                                      theme,
                                    ),
                                    _buildNutrientInfo(
                                      'タンパク質',
                                      '${advice.menuSuggestion!.estimatedNutrition.protein.toStringAsFixed(1)}g',
                                      theme,
                                    ),
                                    _buildNutrientInfo(
                                      '脂質',
                                      '${advice.menuSuggestion!.estimatedNutrition.fat.toStringAsFixed(1)}g',
                                      theme,
                                    ),
                                    _buildNutrientInfo(
                                      '炭水化物',
                                      '${advice.menuSuggestion!.estimatedNutrition.carbohydrates.toStringAsFixed(1)}g',
                                      theme,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      advice
                                          .menuSuggestion!
                                          .recommendationReason,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              if (advice.rationaleExplanation != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  advice.rationaleExplanation!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      // おすすめの食品・メニュー（v2形式）
                      if (advice.suggestions != null &&
                          advice.suggestions!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'その他のおすすめ',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...advice.suggestions!
                            .map(
                              (suggestion) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: TontonColors.success.withValues(
                                          alpha: 0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        size: 12,
                                        color: TontonColors.success,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        suggestion,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ],

                      // 注意事項
                      if (advice.warning != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TontonColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: TontonColors.warning.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 20,
                                color: TontonColors.warning,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  advice.warning!,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 更新ボタン
                      const SizedBox(height: 32),
                      Center(
                        child: TontonButton.secondary(
                          label: '新しいアドバイスを取得',
                          onPressed: _refreshAdvice,
                          icon: Icons.refresh,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceStatus(String nutrient, String status, ThemeData theme) {
    final color =
        status == '過剰'
            ? TontonColors.error
            : status == '不足'
            ? TontonColors.warning
            : TontonColors.success;

    final icon =
        status == '過剰'
            ? Icons.arrow_upward
            : status == '不足'
            ? Icons.arrow_downward
            : Icons.check_circle;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nutrient,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              status,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
