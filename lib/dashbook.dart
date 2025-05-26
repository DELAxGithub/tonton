import 'package:dashbook/dashbook.dart';
import 'package:flutter/material.dart';

import 'design_system/atoms/tonton_icon.dart';
import 'design_system/atoms/tonton_text.dart';
import 'design_system/atoms/tonton_button.dart';
import 'design_system/atoms/tonton_card_base.dart';
import 'design_system/molecules/daily_stat_ring.dart';
import 'design_system/molecules/pfc_pie_chart.dart';
import 'design_system/molecules/navigation_link_card.dart';
import 'design_system/organisms/hero_piggy_bank_display.dart';
import 'design_system/organisms/daily_summary_section.dart';
import 'theme/theme.dart';
import 'utils/icon_mapper.dart';
import 'theme/tokens.dart';

Dashbook createDashbook() {
  final dashbook = Dashbook();

  // Theme
  dashbook.storiesOf('Theme')
    .add('Color Palette', (_) => const _ColorPaletteStory());

  // Icons
  dashbook.storiesOf('Icons')
    .add('Gallery', (_) => const _IconGalleryStory());

  // Atoms
  dashbook.storiesOf('Atoms')
    ..add('TontonIcon', (ctx) => Center(
          child: TontonIcon(
            IconData(ctx.numberProperty('codePoint', 0xe900).toInt(),
                fontFamily: 'TontonIcons'),
            size: ctx.numberProperty('size', 48),
            color: Colors.pink,
          ),
        ))
    ..add('TontonText', (ctx) => Builder( // Wrap with Builder
          builder: (context) => Center( // 'context' here is a valid BuildContext
            child: TontonText(
              ctx.textProperty('text', 'こんにちは Tonton!'),
              style: Theme.of(context).textTheme.headlineSmall, // Use 'context'
            ),
          ),
        ))
    ..add('TontonButton', (ctx) {
      final variant = ctx.listProperty<TontonButtonVariant>(
        'variant',
        TontonButtonVariant.primary,
        TontonButtonVariant.values,
      );
      final disabled = ctx.boolProperty('disabled', false);
      final label = ctx.textProperty('label', '食事を記録');

      TontonButton button;
      switch (variant) {
        case TontonButtonVariant.primary:
          button = TontonButton.primary(
            label: label,
            onPressed: disabled ? null : () {},
            leading: Icons.camera_alt,
          );
          break;
        case TontonButtonVariant.secondary:
          button = TontonButton.secondary(
            label: label,
            onPressed: disabled ? null : () {},
          );
          break;
        case TontonButtonVariant.text:
          button = TontonButton.text(
            label: label,
            onPressed: disabled ? null : () {},
          );
          break;
      }
      return Center(child: button);
    })
    ..add('TontonCardBase', (ctx) {
      final elevation = ctx.listProperty<double>(
        'elevation',
        Elevation.level1,
        const [Elevation.level0, Elevation.level1, Elevation.level2],
      );
      return Center(
        child: TontonCardBase(
          elevation: elevation,
          child: const TontonText('カード'),
        ),
      );
    });

  // Molecules
  dashbook.storiesOf('Molecules')
    ..add('DailyStatRing', (_) => Center(
          child: DailyStatRing(
            icon: TontonIcons.food,
            label: '食べたキロカロリー',
            currentValue: '1200',
            targetValue: '/ 2000 kcal',
            progress: 0.6,
          ),
        ))
    ..add('DailyStatRing - Burned', (_) => Center(
          child: DailyStatRing(
            icon: TontonIcons.workout,
            label: '活動したキロカロリー',
            currentValue: '500 kcal',
            progress: 0.5,
            color: Colors.orange,
          ),
        ))
    ..add('PfcPieChart', (_) => const PfcPieChart(
          protein: 40,
          fat: 20,
          carbs: 150,
        ))
    ..add('NavigationLinkCard', (_) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NavigationLinkCard(
              icon: TontonIcons.trend,
              label: '貯金ダイアリー',
              onTap: () {},
            ),
            const SizedBox(width: Spacing.md),
            NavigationLinkCard(
              icon: TontonIcons.weight,
              label: '体重ジャーニー',
              onTap: () {},
            ),
            const SizedBox(width: Spacing.md),
            NavigationLinkCard(
              icon: TontonIcons.ai,
              label: 'トントンコーチ',
              onTap: () {},
            ),
          ],
        ));

  // Organisms
  dashbook.storiesOf('Organisms')
    ..add('HeroPiggyBankDisplay', (_) => Center(
          child: HeroPiggyBankDisplay(
            totalSavings: 3500,
            recentChange: 250,
          ),
        ))
    ..add('DailySummarySection', (_) => DailySummarySection(
          eatenCalories: 1200,
          targetCalories: 2000,
          burnedCalories: 500,
          dailySavings: 250,
        ));

  return dashbook;
}

class _ColorPaletteStory extends StatelessWidget {
  const _ColorPaletteStory();

  @override
  Widget build(BuildContext context) {
    final colors = {
      'pigPink': TontonColors.pigPink,
      'mintGreen': TontonColors.mintGreen,
      'skyBlue': TontonColors.skyBlue,
      'creamYellow': TontonColors.creamYellow,
      'offWhite': TontonColors.offWhite,
      'softGreen': TontonColors.softGreen,
      'softRed': TontonColors.softRed,
      'softOrange': TontonColors.softOrange,
      'darkBrown': TontonColors.darkBrown,
      'warmGray': TontonColors.warmGray,
      'lightGray': TontonColors.lightGray,
      'surface': TontonColors.surface,
    };

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final entry in colors.entries)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 60, height: 60, color: entry.value),
                  const SizedBox(height: 8),
                  Text(entry.key, style: const TextStyle(fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _IconGalleryStory extends StatelessWidget {
  const _IconGalleryStory();

  @override
  Widget build(BuildContext context) {
    final icons = {
      'arrow': TontonIcons.arrow,
      'bicycle': TontonIcons.bicycle,
      'camera': TontonIcons.camera,
      'coin': TontonIcons.coin,
      'graph': TontonIcons.graph,
      'pigface': TontonIcons.pigface,
      'piggybank': TontonIcons.piggybank,
      'present': TontonIcons.present,
      'restaurant': TontonIcons.restaurantIcon,
      'scale': TontonIcons.scale,
      'workout': TontonIcons.workout,
      'energy': TontonIcons.energy,
      'home': TontonIcons.home,
      'activity': TontonIcons.activity,
      'food': TontonIcons.food,
      'insights': TontonIcons.insights,
      'settings': TontonIcons.settings,
      'add': TontonIcons.add,
      'ai': TontonIcons.ai,
      'profile': TontonIcons.profile,
      'trend': TontonIcons.trend,
      'weight': TontonIcons.weight,
      'calendar': TontonIcons.calendar,
      'progress': TontonIcons.progress,
      'info': TontonIcons.info,
    };

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final entry in icons.entries)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TontonIcon(entry.value, size: 32),
                  const SizedBox(height: 8),
                  Text(entry.key, style: const TextStyle(fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(createDashbook());
}
