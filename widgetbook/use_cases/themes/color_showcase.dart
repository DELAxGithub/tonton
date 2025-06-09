import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tonton/theme/colors.dart';

final colorShowcaseUseCase = WidgetbookComponent(
  name: 'Color Palette',
  useCases: [
    WidgetbookUseCase(
      name: 'Brand Colors',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Primary Brand Colors'),
              _buildColorTile(
                'Pig Pink',
                TontonColors.pigPink,
                '#F7B6B9',
              ),
              _buildColorTile(
                'Pig Pink Dark',
                TontonColors.pigPinkDark,
                '#E89B9E',
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'System Colors',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('iOS System Colors'),
              _buildColorTile(
                'System Red',
                TontonColors.systemRed,
                '#FF3B30',
              ),
              _buildColorTile(
                'System Orange',
                TontonColors.systemOrange,
                '#FF9500',
              ),
              _buildColorTile(
                'System Yellow',
                TontonColors.systemYellow,
                '#FFCC00',
              ),
              _buildColorTile(
                'System Green',
                TontonColors.systemGreen,
                '#34C759',
              ),
              _buildColorTile(
                'System Mint',
                TontonColors.systemMint,
                '#00C7BE',
              ),
              _buildColorTile(
                'System Teal',
                TontonColors.systemTeal,
                '#30B0C7',
              ),
              _buildColorTile(
                'System Cyan',
                TontonColors.systemCyan,
                '#32ADE6',
              ),
              _buildColorTile(
                'System Blue',
                TontonColors.systemBlue,
                '#007AFF',
              ),
              _buildColorTile(
                'System Indigo',
                TontonColors.systemIndigo,
                '#5856D6',
              ),
              _buildColorTile(
                'System Purple',
                TontonColors.systemPurple,
                '#AF52DE',
              ),
              _buildColorTile(
                'System Pink',
                TontonColors.systemPink,
                '#FF2D55',
              ),
              _buildColorTile(
                'System Brown',
                TontonColors.systemBrown,
                '#A2845E',
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Gray Scale',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('System Grays'),
              _buildColorTile(
                'System Gray',
                TontonColors.systemGray,
                '#8E8E93',
              ),
              _buildColorTile(
                'System Gray 2',
                TontonColors.systemGray2,
                '#AEAEB2',
              ),
              _buildColorTile(
                'System Gray 3',
                TontonColors.systemGray3,
                '#C7C7CC',
              ),
              _buildColorTile(
                'System Gray 4',
                TontonColors.systemGray4,
                '#D1D1D6',
              ),
              _buildColorTile(
                'System Gray 5',
                TontonColors.systemGray5,
                '#E5E5EA',
              ),
              _buildColorTile(
                'System Gray 6',
                TontonColors.systemGray6,
                '#F2F2F7',
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Semantic Colors',
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Status Colors'),
              _buildColorTile(
                'Success',
                TontonColors.success,
                '#34C759',
                icon: Icons.check_circle,
              ),
              _buildColorTile(
                'Warning',
                TontonColors.warning,
                '#FF9500',
                icon: Icons.warning,
              ),
              _buildColorTile(
                'Error',
                TontonColors.error,
                '#FF3B30',
                icon: Icons.error,
              ),
              _buildColorTile(
                'Info',
                TontonColors.info,
                '#007AFF',
                icon: Icons.info,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Nutrition Colors'),
              _buildColorTile(
                'Protein',
                TontonColors.proteinColor,
                '#FF3B30',
                subtitle: 'タンパク質',
              ),
              _buildColorTile(
                'Fat',
                TontonColors.fatColor,
                '#FFCC00',
                subtitle: '脂質',
              ),
              _buildColorTile(
                'Carbs',
                TontonColors.carbsColor,
                '#007AFF',
                subtitle: '炭水化物',
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Dynamic Colors',
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Current Mode: ${isDarkMode ? "Dark" : "Light"}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Theme-Aware Colors'),
              _buildDynamicColorTile(
                context,
                'Label',
                TontonColors.labelColor(context),
              ),
              _buildDynamicColorTile(
                context,
                'Secondary Label',
                TontonColors.secondaryLabelColor(context),
              ),
              _buildDynamicColorTile(
                context,
                'Tertiary Label',
                TontonColors.tertiaryLabelColor(context),
              ),
              _buildDynamicColorTile(
                context,
                'Background',
                TontonColors.backgroundColor(context),
              ),
              _buildDynamicColorTile(
                context,
                'Secondary Background',
                TontonColors.secondaryBackgroundColor(context),
              ),
              _buildDynamicColorTile(
                context,
                'Grouped Background',
                TontonColors.groupedBackgroundColor(context),
              ),
              _buildDynamicColorTile(
                context,
                'Separator',
                TontonColors.separatorColor(context),
              ),
              _buildDynamicColorTile(
                context,
                'Fill',
                TontonColors.fillColor(context),
              ),
            ],
          ),
        );
      },
    ),
  ],
);

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _buildColorTile(
  String name,
  Color color,
  String hex, {
  IconData? icon,
  String? subtitle,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.withOpacity(0.2)),
    ),
    child: ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: icon != null
            ? Icon(icon, color: Colors.white)
            : null,
      ),
      title: Text(name),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          hex,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}

Widget _buildDynamicColorTile(
  BuildContext context,
  String name,
  Color color,
) {
  final hexValue = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.withOpacity(0.2)),
    ),
    child: ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: color.computeLuminance() > 0.9
              ? Border.all(color: Colors.grey.withOpacity(0.2))
              : null,
        ),
      ),
      title: Text(name),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          hexValue,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}