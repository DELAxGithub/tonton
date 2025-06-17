class CalorieSavingsRecord {
  final DateTime date;
  final int dayOfMonth; // Day number (1-31)
  final double caloriesConsumed;
  final double caloriesBurned;
  final double dailyBalance; // Daily difference (burned - consumed)
  final double cumulativeSavings; // Running total of savings

  CalorieSavingsRecord({
    required this.date,
    required this.caloriesConsumed,
    required this.caloriesBurned,
    required this.dailyBalance,
    required this.cumulativeSavings,
  }) : dayOfMonth = date.day;

  // Constructor for creating records from raw data
  factory CalorieSavingsRecord.fromRaw({
    required DateTime date,
    required double caloriesConsumed,
    required double caloriesBurned,
    double? previousCumulativeSavings,
  }) {
    final dailyBalance = caloriesBurned - caloriesConsumed;
    final cumulativeSavings = (previousCumulativeSavings ?? 0) + dailyBalance;

    return CalorieSavingsRecord(
      date: date,
      caloriesConsumed: caloriesConsumed,
      caloriesBurned: caloriesBurned,
      dailyBalance: dailyBalance,
      cumulativeSavings: cumulativeSavings,
    );
  }
}
