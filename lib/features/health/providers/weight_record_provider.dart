import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/weight_record.dart';

class LatestWeightRecordNotifier extends StateNotifier<WeightRecord?> {
  LatestWeightRecordNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('latest_weight_record');
    if (jsonStr != null) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      state = WeightRecord(
        weight: (map['weight'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        bodyFatPercentage: (map['bodyFatPercentage'] as num?)?.toDouble(),
        bodyFatMass: (map['bodyFatMass'] as num?)?.toDouble(),
      );
    }
  }

  Future<void> setRecord(WeightRecord record) async {
    state = record;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'latest_weight_record',
      jsonEncode({
        'weight': record.weight,
        'date': record.date.toIso8601String(),
        'bodyFatPercentage': record.bodyFatPercentage,
        'bodyFatMass': record.bodyFatMass,
      }),
    );
  }
}

final latestWeightRecordProvider =
    StateNotifierProvider<LatestWeightRecordNotifier, WeightRecord?>(
      (ref) => LatestWeightRecordNotifier(),
    );
