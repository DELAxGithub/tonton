import 'package:health/health.dart';
import 'dart:developer' as developer;
import '../models/activity_summary.dart';
import '../models/weight_record.dart';
import '../utils/format_activity_type_name.dart';

class HealthService {
  final Health _health = Health();

  static final _types = [
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
  ];

  final _permissions = _types.map((e) => HealthDataAccess.READ).toList();

  Future<bool> requestPermissions() async {
    developer.log(
      'Requesting HealthKit permissions',
      name: 'TonTon.HealthService',
    );
    try {
      final result = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      developer.log(
        'HealthKit permission result: $result',
        name: 'TonTon.HealthService',
      );
      return result;
    } catch (e, stack) {
      developer.log(
        'Permission request error: $e',
        name: 'TonTon.HealthService.error',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  Future<ActivitySummary> getTodayActivitySummary() async {
    developer.log(
      'Getting today activity summary',
      name: 'TonTon.HealthService',
    );
    final now = DateTime.now();
    return getActivitySummary(DateTime(now.year, now.month, now.day));
  }

  Future<ActivitySummary> getActivitySummary(DateTime date) async {
    developer.log(
      'Getting activity summary for date: $date',
      name: 'TonTon.HealthService',
    );

    final startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endTime = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    developer.log(
      'Time range: $startTime to $endTime',
      name: 'TonTon.HealthService',
    );

    try {
      // Fetch all 4 HealthKit data types in parallel
      developer.log('Fetching HealthKit data in parallel', name: 'TonTon.HealthService');
      final results = await Future.wait([
        _health.getHealthDataFromTypes(
          startTime: startTime, endTime: endTime,
          types: [HealthDataType.WORKOUT],
        ),
        _health.getHealthDataFromTypes(
          startTime: startTime, endTime: endTime,
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        ),
        _health.getHealthDataFromTypes(
          startTime: startTime, endTime: endTime,
          types: [HealthDataType.BASAL_ENERGY_BURNED],
        ),
        _health.getHealthDataFromTypes(
          startTime: startTime, endTime: endTime,
          types: [HealthDataType.BODY_FAT_PERCENTAGE],
        ),
      ]);

      final workoutsData = results[0];
      final activeEnergyData = results[1];
      final basalEnergyData = results[2];
      final bodyFatData = results[3];

      developer.log(
        'Fetched ${workoutsData.length} workouts, ${activeEnergyData.length} active, ${basalEnergyData.length} basal, ${bodyFatData.length} bodyFat',
        name: 'TonTon.HealthService',
      );

      // Extract workout types and calories
      final workoutTypes = <String>[];
      double totalWorkoutCalories = 0;

      for (var workout in workoutsData) {
        HealthWorkoutActivityType? activityType;
        double? energyBurned;

        final value = workout.value;
        if (value is WorkoutHealthValue) {
          activityType = value.workoutActivityType;
          energyBurned = value.totalEnergyBurned?.toDouble();
        }

        if (activityType != null) {
          workoutTypes.add(formatActivityTypeName(activityType.name));
        }

        if (energyBurned != null) {
          totalWorkoutCalories += energyBurned;
        }
      }

      // Calculate total energy
      double totalActiveEnergy = activeEnergyData.fold(0, (prev, e) {
        final val = e.value;
        return prev +
            (val is NumericHealthValue ? val.numericValue.toDouble() : 0.0);
      });

      double totalBasalEnergy = basalEnergyData.fold(0, (prev, e) {
        final val = e.value;
        return prev +
            (val is NumericHealthValue ? val.numericValue.toDouble() : 0.0);
      });

      double? bodyFatPercentage;
      if (bodyFatData.isNotEmpty) {
        bodyFatData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
        final val = bodyFatData.first.value;
        if (val is NumericHealthValue) {
          bodyFatPercentage = val.numericValue.toDouble();
        }
      }

      final summary = ActivitySummary(
        workoutTypes: workoutTypes.toSet().toList(), // Remove duplicates
        workoutCalories: totalWorkoutCalories,
        totalCalories: totalActiveEnergy + totalBasalEnergy,
        bodyFatPercentage: bodyFatPercentage,
      );

      developer.log(
        'Built activity summary: ${summary.toString()}',
        name: 'TonTon.HealthService',
      );
      return summary;
    } catch (e, stack) {
      developer.log(
        'Error in getActivitySummary: $e',
        name: 'TonTon.HealthService.error',
        error: e,
        stackTrace: stack,
      );
      // Return empty summary rather than crashing
      return ActivitySummary(
        workoutTypes: [],
        workoutCalories: 0,
        totalCalories: 0,
      );
    }
  }

  Future<WeightRecord?> getLatestWeight(DateTime date) async {
    developer.log(
      'Getting latest weight for date: $date',
      name: 'TonTon.HealthService',
    );

    try {
      final startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endTime = DateTime(
        date.year,
        date.month,
        date.day,
        23,
        59,
        59,
        999,
      );

      // Fetch weight and body fat in parallel
      developer.log('Fetching weight & body fat in parallel', name: 'TonTon.HealthService');
      final results = await Future.wait([
        _health.getHealthDataFromTypes(
          startTime: startTime, endTime: endTime,
          types: [HealthDataType.WEIGHT],
        ),
        _health.getHealthDataFromTypes(
          startTime: startTime, endTime: endTime,
          types: [HealthDataType.BODY_FAT_PERCENTAGE],
        ),
      ]);

      final weightData = results[0];
      final bodyFatData = results[1];

      developer.log(
        'Fetched ${weightData.length} weight, ${bodyFatData.length} bodyFat records',
        name: 'TonTon.HealthService',
      );

      if (weightData.isEmpty) {
        developer.log('No weight data available', name: 'TonTon.HealthService');
        return null;
      }

      // Sort by dateFrom (newest first)
      weightData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      final latestWeightData = weightData.first;
      final weightValue = latestWeightData.value;

      if (weightValue is! NumericHealthValue) {
        developer.log(
          'Weight data is not numeric',
          name: 'TonTon.HealthService',
        );
        return null;
      }

      double weightInKg = weightValue.numericValue.toDouble();

      double? bodyFatPercentage;
      if (bodyFatData.isNotEmpty) {
        bodyFatData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
        final val = bodyFatData.first.value;
        if (val is NumericHealthValue) {
          bodyFatPercentage = val.numericValue.toDouble();
        }
      }

      double? bodyFatMass;
      if (bodyFatPercentage != null) {
        bodyFatMass = weightInKg * bodyFatPercentage;
      }

      final record = WeightRecord(
        weight: weightInKg,
        date: latestWeightData.dateFrom,
        bodyFatPercentage: bodyFatPercentage,
        bodyFatMass: bodyFatMass,
      );

      developer.log(
        'Built weight record: ${record.toString()}',
        name: 'TonTon.HealthService',
      );
      return record;
    } catch (e, stack) {
      developer.log(
        'Error in getLatestWeight: $e',
        name: 'TonTon.HealthService.error',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }
}
