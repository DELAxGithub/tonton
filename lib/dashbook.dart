import 'package:dashbook/dashbook.dart';
import 'package:flutter/material.dart';

import 'design_system/atoms/tonton_icon.dart';
import 'design_system/atoms/tonton_text.dart';

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
        ));

  return dashbook;
}
