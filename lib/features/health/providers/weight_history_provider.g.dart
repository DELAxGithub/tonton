// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weightHistoryHash() => r'a2508b332d41c1a390c98071af3222b828e6fe19';

/// HealthKit から onboardingStartDate 〜 今日の体重履歴を取得し、
/// 同日複数測定はその日の最新 1 件に丸めて日付昇順で返す。
/// startDate が未設定なら空リストを返す（理想ペースも引けないため）。
///
/// Copied from [weightHistory].
@ProviderFor(weightHistory)
final weightHistoryProvider =
    AutoDisposeFutureProvider<List<WeightRecord>>.internal(
  weightHistory,
  name: r'weightHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weightHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WeightHistoryRef = AutoDisposeFutureProviderRef<List<WeightRecord>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
