import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tonton/design_system/organisms/hero_piggy_bank_display.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final heroPiggyBankUseCases = WidgetbookComponent(
  name: 'HeroPiggyBankDisplay',
  useCases: [
    WidgetbookUseCase(
      name: 'Interactive Progress',
      builder: (context) {
        final currentSaved = context.knobs.double.slider(
          label: 'Current Saved',
          min: 0,
          max: 20000,
          initialValue: 8500,
        );
        final targetSaved = context.knobs.double.slider(
          label: 'Target Savings',
          min: 10000,
          max: 30000,
          initialValue: 15000,
        );
        final remainingDays = context.knobs.int.slider(
          label: 'Remaining Days',
          min: 0,
          max: 31,
          initialValue: 12,
        );

        return ProviderScope(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _MockHeroPiggyBank(
                currentSaved: currentSaved,
                targetSaved: targetSaved,
                remainingDays: remainingDays,
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Different States',
      builder: (context) {
        return ProviderScope(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildExample(
                  'Just Started',
                  _MockHeroPiggyBank(
                    currentSaved: 500,
                    targetSaved: 15000,
                    remainingDays: 28,
                  ),
                ),
                _buildExample(
                  'On Track',
                  _MockHeroPiggyBank(
                    currentSaved: 7500,
                    targetSaved: 15000,
                    remainingDays: 15,
                  ),
                ),
                _buildExample(
                  'Almost There',
                  _MockHeroPiggyBank(
                    currentSaved: 13500,
                    targetSaved: 15000,
                    remainingDays: 5,
                  ),
                ),
                _buildExample(
                  'Goal Achieved!',
                  _MockHeroPiggyBank(
                    currentSaved: 16000,
                    targetSaved: 15000,
                    remainingDays: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Edge Cases',
      builder: (context) {
        return ProviderScope(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildExample(
                  'No Progress',
                  _MockHeroPiggyBank(
                    currentSaved: 0,
                    targetSaved: 10000,
                    remainingDays: 30,
                  ),
                ),
                _buildExample(
                  'Last Day',
                  _MockHeroPiggyBank(
                    currentSaved: 8000,
                    targetSaved: 10000,
                    remainingDays: 1,
                  ),
                ),
                _buildExample(
                  'Month Ended - Success',
                  _MockHeroPiggyBank(
                    currentSaved: 12000,
                    targetSaved: 10000,
                    remainingDays: 0,
                  ),
                ),
                _buildExample(
                  'Month Ended - Missed',
                  _MockHeroPiggyBank(
                    currentSaved: 8000,
                    targetSaved: 10000,
                    remainingDays: 0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);

Widget _buildExample(String title, Widget widget) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      widget,
      const SizedBox(height: 24),
    ],
  );
}

// Mock widget that displays static data instead of using providers
class _MockHeroPiggyBank extends StatelessWidget {
  final double currentSaved;
  final double targetSaved;
  final int remainingDays;

  const _MockHeroPiggyBank({
    required this.currentSaved,
    required this.targetSaved,
    required this.remainingDays,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentSaved / targetSaved).clamp(0.0, 1.0);
    final requiredDaily =
        remainingDays > 0 ? (targetSaved - currentSaved) / remainingDays : 0.0;

    // Replicate the actual HeroPiggyBankDisplay UI
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('今月の貯金目標', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '${currentSaved.toStringAsFixed(0)} / ${targetSaved.toStringAsFixed(0)} kcal',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 20,
              backgroundColor: Theme.of(context).dividerColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% 達成',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'あと$remainingDays日',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          if (requiredDaily > 0 && remainingDays > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'あと$remainingDays日で平均${requiredDaily.toStringAsFixed(0)}kcal/日必要',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
