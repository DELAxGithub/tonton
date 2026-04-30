// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ideal_weight_trajectory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$idealWeightTrajectoryHash() =>
    r'351b9e6c9a1aaf325bcffb96bf933fa45cfd2c82';

/// UserGoals.startingBodyWeight + targetWeeklyPercentLoss から
/// startingBodyWeightDate 〜 当月末日までの理想体重曲線を返す。
///
/// 計算式: ideal(d) = start × (1 - pace × elapsedWeeks)
///   - pace は週あたりの減量割合 (例: 0.007 = 0.7%/週)
///   - elapsedWeeks は startingBodyWeightDate からの経過週数 (連続値)
///
/// startingBodyWeight が未設定 (cold start / プロフィール未完) なら
/// 空リストを返す。呼び出し側で "未スナップ" と判定して UI を分岐する。
///
/// Copied from [idealWeightTrajectory].
@ProviderFor(idealWeightTrajectory)
final idealWeightTrajectoryProvider =
    AutoDisposeProvider<List<IdealWeightPoint>>.internal(
  idealWeightTrajectory,
  name: r'idealWeightTrajectoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$idealWeightTrajectoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IdealWeightTrajectoryRef
    = AutoDisposeProviderRef<List<IdealWeightPoint>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
