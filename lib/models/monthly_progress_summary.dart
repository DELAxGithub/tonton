
class MonthlyProgressSummary {
  /// Target monthly net calorie burn (negative value means deficit goal)
  final double targetMonthlyNetBurn;
  
  /// Current accumulated net calorie burn for the month
  final double currentMonthlyNetBurn;
  
  /// Number of days elapsed in the current month
  final int daysElapsedInMonth;
  
  /// Number of days remaining in the current month
  final int remainingDaysInMonth;
  
  /// Average daily net burn needed to reach the target
  double get averageDailyNetBurnNeeded {
    if (remainingDaysInMonth <= 0) return 0;
    return (targetMonthlyNetBurn - currentMonthlyNetBurn) / remainingDaysInMonth;
  }
  
  /// Completion percentage (0-100)
  double get completionPercentage {
    if (targetMonthlyNetBurn == 0) return 0;
    // When goal is already met, show 100%
    if (currentMonthlyNetBurn >= targetMonthlyNetBurn) return 100;
    // Otherwise show progress as percentage toward goal
    return (currentMonthlyNetBurn / targetMonthlyNetBurn * 100).clamp(0, 100);
  }
  
  /// Whether the current progress is on track to meet the target
  bool get isOnTrack {
    if (daysElapsedInMonth <= 0) return true;
    final expectedProgress = (daysElapsedInMonth / (daysElapsedInMonth + remainingDaysInMonth)) * targetMonthlyNetBurn;
    return currentMonthlyNetBurn >= expectedProgress;
  }

  const MonthlyProgressSummary({
    required this.targetMonthlyNetBurn,
    required this.currentMonthlyNetBurn,
    required this.daysElapsedInMonth,
    required this.remainingDaysInMonth,
  });

  @override
  String toString() {
    return 'MonthlyProgressSummary(target: $targetMonthlyNetBurn, current: $currentMonthlyNetBurn, '
        'daysElapsed: $daysElapsedInMonth, daysRemaining: $remainingDaysInMonth, '
        'percentComplete: ${completionPercentage.toStringAsFixed(1)}%)';
  }
}