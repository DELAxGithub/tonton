import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileNotifier extends StateNotifier<String?> {
  UserProfileNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('user_name');
  }

  Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    state = name;

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'name': name}),
      );
    }
  }
}

final userNameProvider =
    StateNotifierProvider<UserProfileNotifier, String?>(
        (ref) => UserProfileNotifier());
