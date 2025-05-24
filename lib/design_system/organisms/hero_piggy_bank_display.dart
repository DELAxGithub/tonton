import 'package:flutter/material.dart';
import '../atoms/tonton_button.dart';
import '../atoms/tonton_icon.dart';
import '../atoms/tonton_text.dart';
import '../atoms/tonton_card_base.dart';
import '../../theme/tokens.dart';
import '../../utils/icon_mapper.dart';

class HeroPiggyBankDisplay extends StatefulWidget {
  final double totalSavings;
  final double recentChange;
  final VoidCallback? onUsePressed;

  const HeroPiggyBankDisplay({
    super.key,
    required this.totalSavings,
    this.onUsePressed,
    this.recentChange = 0,
  });

  @override
  State<HeroPiggyBankDisplay> createState() => _HeroPiggyBankDisplayState();
}

class _HeroPiggyBankDisplayState extends State<HeroPiggyBankDisplay>
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
                  color: theme.colorScheme.primary,
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
          const SizedBox(height: Spacing.sm),
          TontonText(
            'わたしのトントン貯金',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: Spacing.xs),
          TontonText(
            '+${widget.totalSavings.toStringAsFixed(0)} kcal',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          TontonButton.secondary(
            label: '貯金をつかう',
            leading: TontonIcons.present,
            onPressed: widget.onUsePressed,
          ),
        ],
      ),
    );
  }
}
