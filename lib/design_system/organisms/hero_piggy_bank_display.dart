import 'package:flutter/material.dart';
import '../atoms/tonton_button.dart';
import '../atoms/tonton_icon.dart';
import '../atoms/tonton_text.dart';
import '../atoms/tonton_card_base.dart';
import '../../theme/tokens.dart';
import '../../utils/icon_mapper.dart';

class HeroPiggyBankDisplay extends StatelessWidget {
  final double totalSavings;
  final VoidCallback? onUsePressed;

  const HeroPiggyBankDisplay({
    super.key,
    required this.totalSavings,
    this.onUsePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TontonCardBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TontonIcon(
            TontonIcons.piggybank,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: Spacing.sm),
          TontonText(
            'わたしのトントン貯金',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: Spacing.xs),
          TontonText(
            '+${totalSavings.toStringAsFixed(0)} kcal',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          TontonButton.secondary(
            label: '貯金をつかう',
            leading: TontonIcons.present,
            onPressed: onUsePressed,
          ),
        ],
      ),
    );
  }
}
