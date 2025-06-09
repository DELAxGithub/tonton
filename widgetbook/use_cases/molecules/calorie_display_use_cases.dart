import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tonton/design_system/molecules/metric_displays.dart';
import 'package:tonton/design_system/molecules/daily_stat_ring.dart';
import 'package:tonton/theme/colors.dart';

final calorieDisplayUseCases = WidgetbookComponent(
  name: 'Calorie Displays',
  useCases: [
    WidgetbookUseCase(
      name: 'Calorie Metric Display',
      builder: (context) {
        final value = context.knobs.double.slider(
          label: 'Calories',
          min: 0,
          max: 3000,
          initialValue: 1850,
        );
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Consumed',
        );
        final showIcon = context.knobs.boolean(
          label: 'Show Icon',
          initialValue: true,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CalorieMetricDisplay(
              value: value,
              label: label,
              icon: showIcon ? Icons.local_fire_department : null,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Daily Stat Ring',
      builder: (context) {
        final consumed = context.knobs.double.slider(
          label: 'Consumed',
          min: 0,
          max: 3000,
          initialValue: 1500,
        );
        final burned = context.knobs.double.slider(
          label: 'Burned',
          min: 0,
          max: 3000,
          initialValue: 2000,
        );
        final target = context.knobs.double.slider(
          label: 'Target',
          min: 1500,
          max: 3000,
          initialValue: 2000,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DailyStatRing(
              consumed: consumed,
              burned: burned,
              target: target,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Metric Display Variants',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CalorieMetricDisplay(
                    value: 1850,
                    label: 'Consumed',
                    icon: Icons.restaurant,
                    color: TontonColors.systemGreen,
                  ),
                  CalorieMetricDisplay(
                    value: 2200,
                    label: 'Burned',
                    icon: Icons.local_fire_department,
                    color: TontonColors.systemOrange,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CalorieMetricDisplay(
                    value: -350,
                    label: 'Net',
                    icon: Icons.trending_down,
                    color: TontonColors.pigPink,
                  ),
                  CalorieMetricDisplay(
                    value: 12500,
                    label: 'Saved',
                    icon: Icons.savings,
                    color: TontonColors.systemBlue,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Daily Progress States',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildExample(
                'Under Target (Good)',
                DailyStatRing(
                  consumed: 1500,
                  burned: 2000,
                  target: 2000,
                ),
              ),
              _buildExample(
                'At Target',
                DailyStatRing(
                  consumed: 2000,
                  burned: 2000,
                  target: 2000,
                ),
              ),
              _buildExample(
                'Over Target',
                DailyStatRing(
                  consumed: 2500,
                  burned: 2000,
                  target: 2000,
                ),
              ),
              _buildExample(
                'Very Active Day',
                DailyStatRing(
                  consumed: 1800,
                  burned: 3000,
                  target: 2200,
                ),
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Calorie Summary Row',
      builder: (context) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
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
                    children: [
                      const Text(
                        'Today\'s Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CalorieMetricDisplay(
                            value: 1650,
                            label: 'Food',
                            icon: Icons.fastfood,
                            fontSize: 14,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Theme.of(context).dividerColor,
                          ),
                          CalorieMetricDisplay(
                            value: 2100,
                            label: 'Burned',
                            icon: Icons.whatshot,
                            fontSize: 14,
                            color: TontonColors.systemOrange,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Theme.of(context).dividerColor,
                          ),
                          CalorieMetricDisplay(
                            value: 450,
                            label: 'Saved',
                            icon: Icons.savings,
                            fontSize: 14,
                            color: TontonColors.pigPink,
                          ),
                        ],
                      ),
                    ],
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
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      widget,
      const SizedBox(height: 24),
    ],
  );
}