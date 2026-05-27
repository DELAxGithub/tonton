// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$healthDataRepositoryHash() =>
    r'c62a4357ff7ef411a2b8a5074465ee3d6f90cea9';

/// Riverpod provider for the [HealthDataRepository] contract.
///
/// On iOS this returns a [HealthService] (HealthKit-backed); future Android
/// support will branch here to return `GoogleFitRepository`. See ADR-0003
/// (`docs/adr/0003-health-repository-pattern.md`).
///
/// Tests override this with `FakeHealthDataRepository`
/// (`test/services/fake_health_data_repository.dart`).
///
/// Copied from [healthDataRepository].
@ProviderFor(healthDataRepository)
final healthDataRepositoryProvider =
    AutoDisposeProvider<HealthDataRepository>.internal(
  healthDataRepository,
  name: r'healthDataRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$healthDataRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HealthDataRepositoryRef = AutoDisposeProviderRef<HealthDataRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
