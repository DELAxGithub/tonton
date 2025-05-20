import 'package:dashbook/dashbook.dart';
import 'package:flutter/material.dart';

import 'design_system/atoms/tonton_icon.dart';
import 'design_system/atoms/tonton_text.dart';
import 'design_system/atoms/tonton_button.dart';
import 'design_system/atoms/tonton_card_base.dart';
import 'theme/tokens.dart';

Dashbook createDashbook() {
  final dashbook = Dashbook();

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
