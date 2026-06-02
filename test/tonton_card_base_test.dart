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

    final containerFinder = find.descendant(
      of: find.byType(TontonCardBase),
      matching: find.byType(Container),
    );
    final container = tester.widget<Container>(containerFinder.first);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.boxShadow, Elevation.shadowLevel1);
  });
}
