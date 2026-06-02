import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavingsBalanceNotifier extends StateNotifier<double> {
  SavingsBalanceNotifier({DateTime Function()? now})
    : _now = now ?? DateTime.now,
      super(0) {
    reload();
  }

  final DateTime Function() _now;

  String get _storageKey {
    final now = _now();
    final month = now.month.toString().padLeft(2, '0');
    return 'calorieSavings:${now.year}-$month';
  }

  Future<void> reload() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_storageKey) ?? 0;
  }

  Future<void> add(double amount) async {
    await reload();
    state += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_storageKey, state);
  }

  Future<void> deduct(double amount) async {
    await reload();
    state -= amount;
    if (state < 0) state = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_storageKey, state);
  }
}

final savingsBalanceProvider =
    StateNotifierProvider<SavingsBalanceNotifier, double>(
      (ref) => SavingsBalanceNotifier(),
    );
