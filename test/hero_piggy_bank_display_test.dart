import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tonton/design_system/organisms/hero_piggy_bank_display.dart';
import 'package:tonton/design_system/atoms/tonton_icon.dart';
import 'package:tonton/utils/icon_mapper.dart';

void main() {
  testWidgets('shows coin animation when recentChange positive', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: HeroPiggyBankDisplay(
          totalSavings: 500,
          recentChange: 50,
        ),
      ),
    ));

    expect(find.byIcon(TontonIcons.coin), findsOneWidget);
  });
}
