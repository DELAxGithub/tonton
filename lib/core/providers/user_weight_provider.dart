import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/user_weight_repository.dart';

final userWeightRepositoryProvider = Provider<UserWeightRepository>((ref) {
  return UserWeightRepository();
});

class UserWeightNotifier extends StateNotifier<double?> {
  UserWeightNotifier(this._repository) : super(null) {
    _load();
  }

  final UserWeightRepository _repository;

  Future<void> _load() async {
    state = await _repository.getWeight() ?? 60.0;
  }

  Future<void> setWeight(double weight) async {
    await _repository.setWeight(weight);
    state = weight;
  }
}

final userWeightProvider =
    StateNotifierProvider<UserWeightNotifier, double?>((ref) {
  return UserWeightNotifier(ref.read(userWeightRepositoryProvider));
});
