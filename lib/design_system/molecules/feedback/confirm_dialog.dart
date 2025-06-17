import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../atoms/tonton_button.dart';

/// 統一された確認ダイアログコンポーネント
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmText = '確認',
    this.cancelText = 'キャンセル',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
  });

  /// 削除確認ダイアログ
  static Future<bool?> showDelete({
    required BuildContext context,
    required String itemName,
    String? message,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmDialog.delete(
            itemName: itemName,
            message: message,
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
    );
  }

  /// 保存確認ダイアログ
  static Future<bool?> showSave({
    required BuildContext context,
    String? message,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmDialog.save(
            message: message,
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
    );
  }

  /// 終了確認ダイアログ
  static Future<bool?> showExit({
    required BuildContext context,
    String? message,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmDialog.exit(
            message: message,
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
    );
  }

  /// 削除用プリセット
  factory ConfirmDialog.delete({
    required String itemName,
    String? message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ConfirmDialog(
      title: '$itemNameを削除',
      message: message ?? 'この操作は取り消せません。本当に削除しますか？',
      confirmText: '削除',
      cancelText: 'キャンセル',
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
  }

  /// 保存用プリセット
  factory ConfirmDialog.save({
    String? message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ConfirmDialog(
      title: '変更を保存',
      message: message ?? '変更を保存しますか？',
      confirmText: '保存',
      cancelText: 'キャンセル',
      onConfirm: onConfirm,
      onCancel: onCancel,
      icon: Icons.save_outlined,
    );
  }

  /// 終了用プリセット
  factory ConfirmDialog.exit({
    String? message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ConfirmDialog(
      title: '終了の確認',
      message: message ?? '未保存の変更は失われます。終了しますか？',
      confirmText: '終了',
      cancelText: 'キャンセル',
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDestructive: true,
      icon: Icons.exit_to_app,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TontonRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TontonSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color:
                    isDestructive
                        ? TontonColors.error
                        : theme.colorScheme.primary,
              ),
              const SizedBox(height: TontonSpacing.md),
            ],
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
            const SizedBox(height: TontonSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TontonButton.text(
                  label: cancelText,
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: TontonSpacing.sm),
                if (isDestructive)
                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TontonColors.error,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TontonRadius.md),
                      ),
                    ),
                    child: Text(confirmText),
                  )
                else
                  TontonButton.primary(
                    label: confirmText,
                    onPressed: onConfirm,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
