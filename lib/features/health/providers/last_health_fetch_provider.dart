import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastHealthFetchNotifier extends StateNotifier<DateTime?> {
  LastHealthFetchNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString('last_health_fetch');
    if (iso != null) {
      state = DateTime.tryParse(iso);
    }
  }

  Future<void> setTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_health_fetch', time.toIso8601String());
    state = time;
  }
}

final lastHealthFetchProvider =
    StateNotifierProvider<LastHealthFetchNotifier, DateTime?>(
        (ref) => LastHealthFetchNotifier());
