import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calorie_savings_record.dart';
import '../models/dummy_data_scenario.dart';
import '../services/calorie_savings_service.dart';

/// Notifier for managing the selected dummy data scenario.
class ScenarioNotifier extends StateNotifier<DummyDataScenario> {
  ScenarioNotifier() : super(DummyDataScenario.steadyGrowth);

  void setScenario(DummyDataScenario scenario) => state = scenario;
}

final selectedScenarioProvider =
    StateNotifierProvider<ScenarioNotifier, DummyDataScenario>(
        (ref) => ScenarioNotifier());

// Provider for monthly target
final monthlySavingsTargetProvider = Provider<double>((ref) {
  return 14400.0; // Monthly target in kcal
});

/// Notifier for editing the monthly calorie goal in the demo screen.
class MonthlyCalorieGoalNotifier extends StateNotifier<double> {
  MonthlyCalorieGoalNotifier() : super(14400.0);

  void setGoal(double goal) => state = goal;
}

final monthlyCalorieGoalProvider =
    StateNotifierProvider<MonthlyCalorieGoalNotifier, double>(
        (ref) => MonthlyCalorieGoalNotifier());

// Provider for calorie savings data
final calorieSavingsServiceProvider =
    Provider<CalorieSavingsService>((ref) => CalorieSavingsService());

final calorieSavingsDataProvider = Provider<List<CalorieSavingsRecord>>((ref) {
  final scenario = ref.watch(selectedScenarioProvider);
  final service = ref.watch(calorieSavingsServiceProvider);
  return service.generateData(scenario);
});
