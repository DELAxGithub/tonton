/// Possible scenarios for generating dummy calorie savings data.
enum DummyDataScenario {
  /// Consistent positive savings each day.
  steadyGrowth,

  /// Mixed positive and negative days.
  fluctuating,

  /// Gradually decreasing savings.
  declining,
}
