import 'package:shared_preferences/shared_preferences.dart';

class UserWeightRepository {
  static const String _weightKey = 'user_weight_kg';

  Future<double?> getWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_weightKey);
  }

  Future<void> setWeight(double weight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_weightKey, weight);
  }
}
