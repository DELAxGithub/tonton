import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tonton/design_system/atoms/tonton_button.dart';

void main() {
  testWidgets('primary button disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TontonButton.primary(label: 'X', onPressed: null)),
      ),
    );
    final button = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(button).enabled, isFalse);
  });
}
