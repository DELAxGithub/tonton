import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavingsBalanceNotifier extends StateNotifier<double> {
  SavingsBalanceNotifier() : super(0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble('calorieSavings') ?? 0;
  }

  Future<void> add(double amount) async {
    state += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('calorieSavings', state);
  }

  Future<void> deduct(double amount) async {
    state -= amount;
    if (state < 0) state = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('calorieSavings', state);
  }
}

final savingsBalanceProvider =
    StateNotifierProvider<SavingsBalanceNotifier, double>(
        (ref) => SavingsBalanceNotifier());
