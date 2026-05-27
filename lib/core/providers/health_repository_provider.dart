import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/health_data_repository.dart';
import '../../services/health_service.dart';

part 'health_repository_provider.g.dart';

/// Riverpod provider for the [HealthDataRepository] contract.
///
/// On iOS this returns a [HealthService] (HealthKit-backed); future Android
/// support will branch here to return `GoogleFitRepository`. See ADR-0003
/// (`docs/adr/0003-health-repository-pattern.md`).
///
/// Tests override this with `FakeHealthDataRepository`
/// (`test/services/fake_health_data_repository.dart`).
@riverpod
HealthDataRepository healthDataRepository(Ref ref) {
  return HealthService();
}
