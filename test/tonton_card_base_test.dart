import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tonton/design_system/atoms/tonton_card_base.dart';
import 'package:tonton/theme/tokens.dart';

void main() {
  testWidgets('default elevation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TontonCardBase(child: Text('card'))),
      ),
    );

    final materialFinder = find.descendant(
      of: find.byType(TontonCardBase),
      matching: find.byType(Material),
    );
    final material = tester.widget<Material>(materialFinder);
    expect(material.elevation, Elevation.level1);
  });
}
