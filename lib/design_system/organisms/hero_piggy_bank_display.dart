import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../atoms/tonton_icon.dart';
import '../atoms/tonton_text.dart';
import '../atoms/tonton_card_base.dart';
import '../../theme/tokens.dart';
import '../../utils/icon_mapper.dart';
import '../../providers/monthly_progress_provider.dart';

class HeroPiggyBankDisplay extends ConsumerStatefulWidget {
  final double totalSavings;
  final double recentChange;

  const HeroPiggyBankDisplay({
    super.key,
    required this.totalSavings,
    this.recentChange = 0,
  });

  @override
  @override
  ConsumerState<HeroPiggyBankDisplay> createState() => _HeroPiggyBankDisplayState();
}

class _HeroPiggyBankDisplayState extends ConsumerState<HeroPiggyBankDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _offset = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    if (widget.recentChange > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
    }
  }

  @override
  void didUpdateWidget(covariant HeroPiggyBankDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recentChange > 0 && widget.recentChange != oldWidget.recentChange) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(monthlyProgressSummaryProvider);
    Color pigColor = theme.colorScheme.primary;
    if (widget.totalSavings >= 1000) {
      pigColor = theme.colorScheme.secondary;
    } else if (widget.totalSavings >= 500) {
      pigColor = theme.colorScheme.tertiary;
    }
    return TontonCardBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TontonIcon(
                  TontonIcons.piggybank,
                  size: 64,
                  color: pigColor,
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Positioned(
                      top: _offset.value,
                      child: Opacity(
                        opacity: _opacity.value,
                        child: child,
                      ),
                    );
                  },
                  child: TontonIcon(
                    TontonIcons.coin,
                    size: 24,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          TontonText(
            'わたしのトントン貯金',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TontonIcon(TontonIcons.piggybank, size: 24, color: pigColor),
              const SizedBox(width: Spacing.xs),
              TontonText(
                '+${widget.totalSavings.toStringAsFixed(0)} kcal',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: pigColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          summaryAsync.when(
            data: (summary) => Column(
              children: [
                Center(
                  child: TontonText(
                    '今月の目標進捗: ${summary.completionPercentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Center(
                  child: TontonText(
                    '残り${summary.remainingDaysInMonth}日',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: Spacing.md),
        ],
      ),
    );
  }
}
