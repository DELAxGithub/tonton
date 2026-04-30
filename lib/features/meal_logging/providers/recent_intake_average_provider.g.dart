// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_intake_average_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentIntakeAverageHash() =>
    r'd1c0aa71e97656670dbd1a54c039fe793d485f17';

/// 直近 [_windowDays] 日の摂取カロリー平均を返す（日単位で合算してから平均）。
/// 0 kcal の日は除外し、有効日数が [_minActiveDays] 未満なら null を返す。
/// null のときは呼び出し側で別の fallback（プロフィール由来 or デフォルト）を当てること。
///
/// Copied from [recentIntakeAverage].
@ProviderFor(recentIntakeAverage)
final recentIntakeAverageProvider = AutoDisposeProvider<double?>.internal(
  recentIntakeAverage,
  name: r'recentIntakeAverageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentIntakeAverageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentIntakeAverageRef = AutoDisposeProviderRef<double?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
