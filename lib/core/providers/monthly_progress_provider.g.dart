// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$healthServiceHash() => r'98289cee4406da156329508b9bf2f4bbee2d0cca';

/// See also [healthService].
@ProviderFor(healthService)
final healthServiceProvider = AutoDisposeProvider<HealthService>.internal(
  healthService,
  name: r'healthServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$healthServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HealthServiceRef = AutoDisposeProviderRef<HealthService>;
String _$userSettingsRepositoryHash() =>
    r'424cb5921e77c54f5273ee3b165ec3a761d77ca7';

/// See also [userSettingsRepository].
@ProviderFor(userSettingsRepository)
final userSettingsRepositoryProvider =
    AutoDisposeProvider<UserSettingsRepository>.internal(
  userSettingsRepository,
  name: r'userSettingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userSettingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserSettingsRepositoryRef
    = AutoDisposeProviderRef<UserSettingsRepository>;
String _$calorieCalculationServiceHash() =>
    r'a018d85ef762deda669aadae0194476c1c2ccb20';

/// See also [calorieCalculationService].
@ProviderFor(calorieCalculationService)
final calorieCalculationServiceProvider =
    AutoDisposeProvider<CalorieCalculationService>.internal(
  calorieCalculationService,
  name: r'calorieCalculationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calorieCalculationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalorieCalculationServiceRef
    = AutoDisposeProviderRef<CalorieCalculationService>;
String _$monthlyTargetHash() => r'b9917e474cf6fa58f02216a90d891d01a61bf4a2';

/// See also [monthlyTarget].
@ProviderFor(monthlyTarget)
final monthlyTargetProvider = AutoDisposeFutureProvider<double>.internal(
  monthlyTarget,
  name: r'monthlyTargetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyTargetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyTargetRef = AutoDisposeFutureProviderRef<double>;
String _$dailyCalorieSummaryHash() =>
    r'107eb43a7ffb75b74c8d10c7f0a7a1dd6d1ab7c8';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [dailyCalorieSummary].
@ProviderFor(dailyCalorieSummary)
const dailyCalorieSummaryProvider = DailyCalorieSummaryFamily();

/// See also [dailyCalorieSummary].
class DailyCalorieSummaryFamily
    extends Family<AsyncValue<DailyCalorieSummary>> {
  /// See also [dailyCalorieSummary].
  const DailyCalorieSummaryFamily();

  /// See also [dailyCalorieSummary].
  DailyCalorieSummaryProvider call(
    DateTime date,
  ) {
    return DailyCalorieSummaryProvider(
      date,
    );
  }

  @override
  DailyCalorieSummaryProvider getProviderOverride(
    covariant DailyCalorieSummaryProvider provider,
  ) {
    return call(
      provider.date,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dailyCalorieSummaryProvider';
}

/// See also [dailyCalorieSummary].
class DailyCalorieSummaryProvider
    extends AutoDisposeFutureProvider<DailyCalorieSummary> {
  /// See also [dailyCalorieSummary].
  DailyCalorieSummaryProvider(
    DateTime date,
  ) : this._internal(
          (ref) => dailyCalorieSummary(
            ref as DailyCalorieSummaryRef,
            date,
          ),
          from: dailyCalorieSummaryProvider,
          name: r'dailyCalorieSummaryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailyCalorieSummaryHash,
          dependencies: DailyCalorieSummaryFamily._dependencies,
          allTransitiveDependencies:
              DailyCalorieSummaryFamily._allTransitiveDependencies,
          date: date,
        );

  DailyCalorieSummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<DailyCalorieSummary> Function(DailyCalorieSummaryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailyCalorieSummaryProvider._internal(
        (ref) => create(ref as DailyCalorieSummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DailyCalorieSummary> createElement() {
    return _DailyCalorieSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyCalorieSummaryProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DailyCalorieSummaryRef
    on AutoDisposeFutureProviderRef<DailyCalorieSummary> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _DailyCalorieSummaryProviderElement
    extends AutoDisposeFutureProviderElement<DailyCalorieSummary>
    with DailyCalorieSummaryRef {
  _DailyCalorieSummaryProviderElement(super.provider);

  @override
  DateTime get date => (origin as DailyCalorieSummaryProvider).date;
}

String _$todayCalorieSummaryHash() =>
    r'd9606aacf7192877c3c5d661dd968058ed4734ec';

/// See also [todayCalorieSummary].
@ProviderFor(todayCalorieSummary)
final todayCalorieSummaryProvider =
    AutoDisposeFutureProvider<DailyCalorieSummary>.internal(
  todayCalorieSummary,
  name: r'todayCalorieSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayCalorieSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayCalorieSummaryRef
    = AutoDisposeFutureProviderRef<DailyCalorieSummary>;
String _$monthlyProgressSummaryHash() =>
    r'89aaeec71e2ce7356be5868b60fd81dec0b9e0d9';

/// See also [monthlyProgressSummary].
@ProviderFor(monthlyProgressSummary)
final monthlyProgressSummaryProvider =
    AutoDisposeFutureProvider<MonthlyProgressSummary>.internal(
  monthlyProgressSummary,
  name: r'monthlyProgressSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyProgressSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyProgressSummaryRef
    = AutoDisposeFutureProviderRef<MonthlyProgressSummary>;
String _$monthlyTargetNotifierHash() =>
    r'50120c7401b8b9e2fa833db1778300290f7b8af1';

/// See also [MonthlyTargetNotifier].
@ProviderFor(MonthlyTargetNotifier)
final monthlyTargetNotifierProvider =
    AutoDisposeAsyncNotifierProvider<MonthlyTargetNotifier, double>.internal(
  MonthlyTargetNotifier.new,
  name: r'monthlyTargetNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyTargetNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MonthlyTargetNotifier = AutoDisposeAsyncNotifier<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
