import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/user_profile.dart';

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile()) {
    _load();
  }

  static const String _keyPrefix = 'user_profile_';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final completed =
        prefs.getBool('${_keyPrefix}onboarding_completed') ?? false;

    state = UserProfile(
      displayName:
          prefs.getString('${_keyPrefix}display_name') ??
          prefs.getString('user_name'),
      weight: prefs.getDouble('${_keyPrefix}weight'),
      gender: prefs.getString('${_keyPrefix}gender'),
      ageGroup: prefs.getString('${_keyPrefix}age_group'),
      onboardingCompleted: completed,
    );
  }

  Future<void> updateDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_keyPrefix}display_name', name);
    state = state.copyWith(displayName: name);

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'name': name}),
        );
      } catch (e) {
        // Silently handle sync errors
      }
    }
  }

  Future<void> updateWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${_keyPrefix}weight', weight);
    state = state.copyWith(weight: weight);
  }

  Future<void> updateGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_keyPrefix}gender', gender);
    state = state.copyWith(gender: gender);
  }

  Future<void> updateAgeGroup(String ageGroup) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_keyPrefix}age_group', ageGroup);
    state = state.copyWith(ageGroup: ageGroup);
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    // Update state first for immediate UI update
    state = state.copyWith(onboardingCompleted: true);

    // Persist both keys to ensure synchronization
    await prefs.setBool('${_keyPrefix}onboarding_completed', true);
    await prefs.setBool(
      'onboardingCompleted',
      true,
    ); // Also set the OnboardingCompletion key
  }

  // Legacy support for old userNameProvider
  Future<void> setName(String name) async {
    await updateDisplayName(name);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
      (ref) => UserProfileNotifier(),
    );

// Legacy provider for backward compatibility
final userNameProvider = Provider<String?>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.displayName ?? 'ゲスト';
});
