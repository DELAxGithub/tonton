import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';
import '../providers/providers.dart';
import '../design_system/atoms/tonton_card_base.dart';
import '../design_system/molecules/feedback/loading_indicator.dart';
import '../features/meal_logging/providers/ai_advice_provider.dart';
import '../features/meal_logging/providers/meal_records_provider.dart';
import '../features/meal_logging/providers/ai_advice_cache_provider.dart';
import 'ai_advice_modal.dart';

/// コンパクトなAIアドバイス表示カード
class AiAdviceCardCompact extends ConsumerStatefulWidget {
  const AiAdviceCardCompact({super.key});
  
  @override
  ConsumerState<AiAdviceCardCompact> createState() => _AiAdviceCardCompactState();
}

class _AiAdviceCardCompactState extends ConsumerState<AiAdviceCardCompact> {
  @override
  void initState() {
    super.initState();
    // ウィジェットがビルドされた後にアドバイスをフェッチ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAdviceIfNeeded();
    });
  }
  
  void _fetchAdviceIfNeeded() {
    final adviceState = ref.read(aiAdviceProvider);
    final todayMeals = ref.read(todaysMealRecordsProvider);
    
    // アドバイスがまだ取得されていない、またはエラーの場合にフェッチ
    if (!adviceState.hasValue || adviceState.hasError) {
      final locale = Localizations.localeOf(context).languageCode;
      ref.read(aiAdviceProvider.notifier).fetchAdvice(todayMeals, locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adviceAsync = ref.watch(cachedAiAdviceProvider);

    return adviceAsync.when(
      loading: () => TontonCardBase(
        child: Container(
          padding: const EdgeInsets.all(TontonSpacing.md),
          child: Row(
            children: [
              Icon(
                TontonIcons.ai,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: TontonSpacing.md),
              const Expanded(
                child: LoadingIndicator(
                  size: 16,
                  message: 'AIアドバイスを生成中...',
                ),
              ),
            ],
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (advice) {
        if (advice == null || advice.adviceMessage.isEmpty) {
          return const SizedBox.shrink();
        }

        // アドバイスを最初の2文に制限
        final sentences = advice.adviceMessage.split('。');
        final shortAdvice = sentences.take(2).join('。') + 
            (sentences.length > 2 ? '。' : '');

        return TontonCardBase(
          child: InkWell(
            onTap: () {
              // モーダルで詳細表示
              showAIAdviceModal(context);
            },
            borderRadius: BorderRadius.circular(TontonRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(TontonSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(TontonSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(TontonRadius.sm),
                    ),
                    child: Icon(
                      TontonIcons.ai,
                      size: 24,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: TontonSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AIコーチからのアドバイス',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: TontonColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: TontonSpacing.xs),
                        Text(
                          shortAdvice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: TontonColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (advice.menuSuggestion != null) ...[
                          const SizedBox(height: TontonSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'おすすめ: ${advice.menuSuggestion!.menuName}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: TontonSpacing.xs),
                        Text(
                          'タップして全文を読む',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: () async {
                          // キャッシュを無効化して再取得
                          await ref.read(aiAdviceCacheProvider.notifier).invalidateCache();
                          ref.read(aiAdviceProvider.notifier).reset();
                          _fetchAdviceIfNeeded();
                        },
                        tooltip: '更新',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: TontonColors.textSecondary,
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: TontonColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullAdvice(BuildContext context, dynamic advice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              TontonIcons.ai,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: TontonSpacing.sm),
            const Text('AIコーチからのアドバイス'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(advice.adviceMessage ?? advice.advice ?? ''),
              if (advice.suggestions != null && advice.suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'おすすめの食品・メニュー',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...advice.suggestions.map<Widget>((suggestion) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: TontonColors.success),
                      const SizedBox(width: 8),
                      Expanded(child: Text(suggestion)),
                    ],
                  ),
                )).toList(),
              ],
              if (advice.warning != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TontonColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TontonColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 20, color: TontonColors.warning),
                      const SizedBox(width: 8),
                      Expanded(child: Text(advice.warning)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}