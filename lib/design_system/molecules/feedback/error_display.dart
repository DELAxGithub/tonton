import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../atoms/tonton_button.dart';
import '../../../utils/icon_mapper.dart';

/// 統一されたエラー表示コンポーネント
class ErrorDisplay extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool isCompact;

  const ErrorDisplay({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.icon,
    this.isCompact = false,
  });

  /// ネットワークエラー用
  factory ErrorDisplay.network({VoidCallback? onRetry}) {
    return ErrorDisplay(
      title: 'ネットワークエラー',
      message: 'インターネット接続を確認してください',
      icon: TontonIcons.pigface,
      onRetry: onRetry,
    );
  }

  /// 認証エラー用
  factory ErrorDisplay.auth({VoidCallback? onRetry}) {
    return ErrorDisplay(
      title: '認証エラー',
      message: 'ログインし直してください',
      icon: Icons.lock_outline,
      onRetry: onRetry,
    );
  }

  /// データ取得エラー用
  factory ErrorDisplay.data({String? message, VoidCallback? onRetry}) {
    return ErrorDisplay(
      title: 'データの取得に失敗しました',
      message: message ?? 'しばらく時間をおいてから再度お試しください',
      icon: Icons.error_outline,
      onRetry: onRetry,
    );
  }

  /// カスタムエラー用
  factory ErrorDisplay.custom({
    required String title,
    String? message,
    IconData? icon,
    VoidCallback? onRetry,
  }) {
    return ErrorDisplay(
      title: title,
      message: message,
      icon: icon,
      onRetry: onRetry,
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
        padding: const EdgeInsets.all(TontonSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: TontonColors.error,
            ),
            const SizedBox(height: TontonSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleLarge,
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
            if (onRetry != null) ...[
              const SizedBox(height: TontonSpacing.lg),
              TontonButton.primary(
                label: '再試行',
                onPressed: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(TontonSpacing.md),
      decoration: BoxDecoration(
        color: TontonColors.error.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(TontonRadius.md),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: TontonColors.error,
            size: 24,
          ),
          const SizedBox(width: TontonSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TontonColors.error,
                  ),
                ),
                if (message != null)
                  Text(
                    message!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: TontonColors.error,
                    ),
                  ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: TontonSpacing.sm),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              color: TontonColors.error,
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }
}