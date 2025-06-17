import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tonton/design_system/molecules/pfc_bar_display.dart';

final pfcBarDisplayUseCases = WidgetbookComponent(
  name: 'PFCBarDisplay',
  useCases: [
    WidgetbookUseCase(
      name: 'Interactive PFC Bar',
      builder: (context) {
        final protein = context.knobs.double.slider(
          label: 'Protein (g)',
          min: 0,
          max: 100,
          initialValue: 50,
        );
        final fat = context.knobs.double.slider(
          label: 'Fat (g)',
          min: 0,
          max: 100,
          initialValue: 30,
        );
        final carbs = context.knobs.double.slider(
          label: 'Carbs (g)',
          min: 0,
          max: 200,
          initialValue: 120,
        );
        final showLabels = context.knobs.boolean(
          label: 'Show Labels',
          initialValue: true,
        );
        final showPercentages = context.knobs.boolean(
          label: 'Show Percentages',
          initialValue: true,
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PFCBarDisplay(
              protein: protein,
              fat: fat,
              carbs: carbs,
              showLabels: showLabels,
              showPercentages: showPercentages,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Different Ratios',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildExample(
                'Balanced Diet',
                const PFCBarDisplay(protein: 50, fat: 40, carbs: 110),
              ),
              _buildExample(
                'High Protein',
                const PFCBarDisplay(protein: 80, fat: 30, carbs: 90),
              ),
              _buildExample(
                'Low Carb',
                const PFCBarDisplay(protein: 60, fat: 60, carbs: 30),
              ),
              _buildExample(
                'High Carb',
                const PFCBarDisplay(protein: 30, fat: 20, carbs: 150),
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Display Variants',
      builder: (context) {
        const protein = 55.0;
        const fat = 35.0;
        const carbs = 110.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildExample(
                'With Labels and Percentages',
                const PFCBarDisplay(
                  protein: protein,
                  fat: fat,
                  carbs: carbs,
                  showLabels: true,
                  showPercentages: true,
                ),
              ),
              _buildExample(
                'Only Percentages',
                const PFCBarDisplay(
                  protein: protein,
                  fat: fat,
                  carbs: carbs,
                  showLabels: false,
                  showPercentages: true,
                ),
              ),
              _buildExample(
                'Only Labels',
                const PFCBarDisplay(
                  protein: protein,
                  fat: fat,
                  carbs: carbs,
                  showLabels: true,
                  showPercentages: false,
                ),
              ),
              _buildExample(
                'Minimal (No Labels)',
                const PFCBarDisplay(
                  protein: protein,
                  fat: fat,
                  carbs: carbs,
                  showLabels: false,
                  showPercentages: false,
                ),
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Edge Cases',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildExample(
                'All Zero',
                const PFCBarDisplay(protein: 0, fat: 0, carbs: 0),
              ),
              _buildExample(
                'Only Protein',
                const PFCBarDisplay(protein: 100, fat: 0, carbs: 0),
              ),
              _buildExample(
                'Very Small Values',
                const PFCBarDisplay(protein: 1, fat: 2, carbs: 3),
              ),
              _buildExample(
                'Very Large Values',
                const PFCBarDisplay(protein: 200, fat: 150, carbs: 350),
              ),
            ],
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
