import '../models/activity_summary.dart';
import '../models/weight_record.dart';

/// Abstract contract for health-data sources (HealthKit on iOS, eventually
/// Google Fit on Android, fakes in tests).
///
/// Concrete implementations:
/// - `HealthService` — HealthKit-backed, used in production on iOS.
/// - `FakeHealthDataRepository` (test/services/) — deterministic fake for unit
///   tests.
///
/// The Android Google Fit implementation will be added under ADR-0003 Phase 3
/// (see `docs/adr/0003-health-repository-pattern.md`).
abstract class HealthDataRepository {
  /// Asks the underlying platform for read permission to the health types this
  /// app uses (workouts, active/basal energy, weight, body fat). Returns `true`
  /// when permission is granted, `false` otherwise (or on error).
  Future<bool> requestPermissions();

  /// Activity summary for the current calendar day in the device's local
  /// time zone. Combines workouts and active calorie expenditure into
  /// [ActivitySummary].
  Future<ActivitySummary> getTodayActivitySummary();

  /// Activity summary for a specific calendar day, evaluated in the device's
  /// local time zone. The repository takes only the y/m/d components of
  /// [date]; the time-of-day portion is ignored.
  Future<ActivitySummary> getActivitySummary(DateTime date);

  /// Latest [WeightRecord] from the given [date]'s calendar day (latest by
  /// `dateFrom`). Returns `null` for both "no weight record exists for that
  /// day" and "the underlying health-data source returned an error or
  /// non-numeric value". Callers that need to distinguish these cases should
  /// check [requestPermissions] beforehand.
  Future<WeightRecord?> getLatestWeight(DateTime date);

  /// Every weight measurement between [start] (inclusive) and [end] (inclusive),
  /// ordered ascending by date. Multiple measurements on the same day are
  /// returned individually; deduplication is the caller's responsibility.
  Future<List<WeightRecord>> getWeightHistory(DateTime start, DateTime end);
}
