// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_records_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todaysMealRecordsHash() => r'd71862c67ce261201e8e8e36476d4edbde375942';

/// Convenience provider for getting records for today
///
/// Copied from [todaysMealRecords].
@ProviderFor(todaysMealRecords)
final todaysMealRecordsProvider =
    AutoDisposeProvider<List<MealRecord>>.internal(
  todaysMealRecords,
  name: r'todaysMealRecordsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todaysMealRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodaysMealRecordsRef = AutoDisposeProviderRef<List<MealRecord>>;
String _$todaysTotalCaloriesHash() =>
    r'b05adb788ab0cc7aa4a0909e5bb807c08924f870';

/// Provider for getting total calories for today
///
/// Copied from [todaysTotalCalories].
@ProviderFor(todaysTotalCalories)
final todaysTotalCaloriesProvider = AutoDisposeProvider<double>.internal(
  todaysTotalCalories,
  name: r'todaysTotalCaloriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todaysTotalCaloriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodaysTotalCaloriesRef = AutoDisposeProviderRef<double>;
String _$mealRecordHash() => r'b3880493539cf94a1f78f95561f351cf72c59c01';

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

/// Provider for accessing a specific meal record by ID
///
/// Copied from [mealRecord].
@ProviderFor(mealRecord)
const mealRecordProvider = MealRecordFamily();

/// Provider for accessing a specific meal record by ID
///
/// Copied from [mealRecord].
class MealRecordFamily extends Family<MealRecord?> {
  /// Provider for accessing a specific meal record by ID
  ///
  /// Copied from [mealRecord].
  const MealRecordFamily();

  /// Provider for accessing a specific meal record by ID
  ///
  /// Copied from [mealRecord].
  MealRecordProvider call(
    String id,
  ) {
    return MealRecordProvider(
      id,
    );
  }

  @override
  MealRecordProvider getProviderOverride(
    covariant MealRecordProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'mealRecordProvider';
}

/// Provider for accessing a specific meal record by ID
///
/// Copied from [mealRecord].
class MealRecordProvider extends AutoDisposeProvider<MealRecord?> {
  /// Provider for accessing a specific meal record by ID
  ///
  /// Copied from [mealRecord].
  MealRecordProvider(
    String id,
  ) : this._internal(
          (ref) => mealRecord(
            ref as MealRecordRef,
            id,
          ),
          from: mealRecordProvider,
          name: r'mealRecordProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mealRecordHash,
          dependencies: MealRecordFamily._dependencies,
          allTransitiveDependencies:
              MealRecordFamily._allTransitiveDependencies,
          id: id,
        );

  MealRecordProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    MealRecord? Function(MealRecordRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MealRecordProvider._internal(
        (ref) => create(ref as MealRecordRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<MealRecord?> createElement() {
    return _MealRecordProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MealRecordProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MealRecordRef on AutoDisposeProviderRef<MealRecord?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _MealRecordProviderElement extends AutoDisposeProviderElement<MealRecord?>
    with MealRecordRef {
  _MealRecordProviderElement(super.provider);

  @override
  String get id => (origin as MealRecordProvider).id;
}

String _$mealRecordsHash() => r'e350bb25b97fe5854f46cb80bd83858264dced86';

/// Provider for managing meal records state
///
/// Copied from [MealRecords].
@ProviderFor(MealRecords)
final mealRecordsProvider =
    AutoDisposeAsyncNotifierProvider<MealRecords, MealRecordsState>.internal(
  MealRecords.new,
  name: r'mealRecordsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mealRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MealRecords = AutoDisposeAsyncNotifier<MealRecordsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
