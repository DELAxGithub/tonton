import 'package:dashbook/dashbook.dart';
import 'package:flutter/material.dart';

import 'design_system/atoms/tonton_icon.dart';
import 'design_system/atoms/tonton_text.dart';
import 'design_system/atoms/tonton_button.dart';
import 'design_system/atoms/tonton_card_base.dart';
import 'theme/theme.dart';
import 'utils/icon_mapper.dart';
import 'theme/tokens.dart';

Dashbook createDashbook() {
  final dashbook = Dashbook();

  // Theme
  dashbook.storiesOf('Theme')
    ..add('Color Palette', (_) => const _ColorPaletteStory());

  // Icons
  dashbook.storiesOf('Icons')
    ..add('Gallery', (_) => const _IconGalleryStory());

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
    ..add('TontonText', (ctx) => Center(
          child: TontonText(
            ctx.textProperty('text', 'こんにちは Tonton!'),
            style: Theme.of(ctx.context).textTheme.headlineSmall,
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
