class ActivitySummary {
  final List<String> workoutTypes;
  final double workoutCalories;
  final double totalCalories;
  final double? bodyFatPercentage;

  ActivitySummary({
    required this.workoutTypes,
    required this.workoutCalories,
    required this.totalCalories,
    this.bodyFatPercentage,
  });

  bool get hasWorkouts => workoutTypes.isNotEmpty;

  @override
  String toString() {
    return 'ActivitySummary(workoutTypes: $workoutTypes, workoutCalories: $workoutCalories, totalCalories: $totalCalories, bodyFatPercentage: $bodyFatPercentage)';
  }
}
