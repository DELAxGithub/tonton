import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tonton/features/savings/providers/savings_balance_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and deducts balance within the current month', () async {
    final notifier = SavingsBalanceNotifier(now: () => DateTime(2026, 6, 15));
    addTearDown(notifier.dispose);

    await notifier.reload();
    await notifier.add(800);
    await notifier.deduct(250);

    expect(notifier.state, 550);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('calorieSavings:2026-06'), 550);
  });

  test('starts from zero when the month changes', () async {
    final may = SavingsBalanceNotifier(now: () => DateTime(2026, 5, 31));
    addTearDown(may.dispose);

    await may.reload();
    await may.add(1200);
    expect(may.state, 1200);

    final june = SavingsBalanceNotifier(now: () => DateTime(2026, 6, 1));
    addTearDown(june.dispose);

    await june.reload();
    expect(june.state, 0);
  });

  test('does not migrate the legacy all-time balance key', () async {
    SharedPreferences.setMockInitialValues({'calorieSavings': 9999.0});

    final notifier = SavingsBalanceNotifier(now: () => DateTime(2026, 6, 1));
    addTearDown(notifier.dispose);

    await notifier.reload();
    expect(notifier.state, 0);
  });
}
