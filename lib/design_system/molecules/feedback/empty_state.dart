import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../atoms/tonton_button.dart';
import '../../../utils/icon_mapper.dart';

/// 統一された空状態表示コンポーネント
class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final Widget? action;
  final bool isCompact;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.action,
    this.isCompact = false,
  });

  /// 食事記録なし
  factory EmptyState.noMeals({VoidCallback? onAdd}) {
    return EmptyState(
      title: '食事の記録がありません',
      message: '食事を記録して、健康管理を始めましょう',
      icon: TontonIcons.restaurantIcon,
      action: onAdd != null
          ? TontonButton.primary(
              label: '食事を記録する',
              onPressed: onAdd,
            )
          : null,
    );
  }

  /// データなし（汎用）
  factory EmptyState.noData({
    String? message,
    IconData? icon,
    Widget? action,
  }) {
    return EmptyState(
      title: 'データがありません',
      message: message,
      icon: icon ?? Icons.inbox_outlined,
      action: action,
    );
  }

  /// 進捗なし
  factory EmptyState.noProgress() {
    return EmptyState(
      title: 'まだ進捗がありません',
      message: '目標を設定して、達成を目指しましょう',
      icon: TontonIcons.graph,
    );
  }

  /// 貯金なし
  factory EmptyState.noSavings() {
    return EmptyState(
      title: '貯金がまだありません',
      message: 'カロリーを節約して、貯金を始めましょう',
      icon: TontonIcons.piggybank,
    );
  }

  /// 検索結果なし
  factory EmptyState.noSearchResults({VoidCallback? onClear}) {
    return EmptyState(
      title: '検索結果がありません',
      message: '別のキーワードで検索してみてください',
      icon: Icons.search_off,
      action: onClear != null
          ? TontonButton.text(
              label: '検索をクリア',
              onPressed: onClear,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isCompact) {
      return _buildCompact(theme);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TontonSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 80,
              color: TontonColors.neutral400,
            ),
            const SizedBox(height: TontonSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: TontonColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: TontonSpacing.sm),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: TontonColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: TontonSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TontonSpacing.md,
        vertical: TontonSpacing.lg,
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 32,
            color: TontonColors.neutral400,
          ),
          const SizedBox(width: TontonSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TontonColors.textPrimary,
                  ),
                ),
                if (message != null)
                  Text(
                    message!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TontonColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: TontonSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}