import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tonton/design_system/atoms/tonton_button.dart';

void main() {
  testWidgets('primary button disabled', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TontonButton.primary(label: 'X', onPressed: null)),
      ),
    );

    expect(find.text('X'), findsOneWidget);
    await tester.tap(find.text('X'));
    expect(tapped, isFalse);
  });
}
