import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// 統一されたローディング表示コンポーネント
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  
  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 24.0,
    this.color,
  });

  /// フルスクリーンローディング
  static Widget fullScreen({String? message}) {
    return Scaffold(
      body: Center(
        child: LoadingIndicator(message: message),
      ),
    );
  }

  /// カード内ローディング
  static Widget card({String? message}) {
    return Container(
      padding: const EdgeInsets.all(TontonSpacing.xl),
      child: LoadingIndicator(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: effectiveColor,
            strokeWidth: 3.0,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: TontonSpacing.md),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: TontonColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}