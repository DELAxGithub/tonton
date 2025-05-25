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
    developer.log('Requesting HealthKit permissions', name: 'TonTon.HealthService');
    try {
      final result = await _health.requestAuthorization(_types, permissions: _permissions);
      developer.log('HealthKit permission result: $result', name: 'TonTon.HealthService');
      return result;
    } catch (e, stack) {
      developer.log('Permission request error: $e', name: 'TonTon.HealthService.error', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<ActivitySummary> getTodayActivitySummary() async {
    developer.log('Getting today activity summary', name: 'TonTon.HealthService');
    final now = DateTime.now();
    return getActivitySummary(
      DateTime(now.year, now.month, now.day),
    );
  }

  Future<ActivitySummary> getActivitySummary(DateTime date) async {
    developer.log('Getting activity summary for date: $date', name: 'TonTon.HealthService');
    
    final startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endTime = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    developer.log('Time range: $startTime to $endTime', name: 'TonTon.HealthService');

    try {
      // Get workout data
      developer.log('Fetching workout data', name: 'TonTon.HealthService');
      final workoutsData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.WORKOUT],
      );
      developer.log('Fetched ${workoutsData.length} workout records', name: 'TonTon.HealthService');

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

      // Get active and basal energy data
      developer.log('Fetching energy data', name: 'TonTon.HealthService');
      final activeEnergyData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      developer.log('Fetched ${activeEnergyData.length} active energy records', name: 'TonTon.HealthService');

      final basalEnergyData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.BASAL_ENERGY_BURNED],
      );
      developer.log('Fetched ${basalEnergyData.length} basal energy records', name: 'TonTon.HealthService');

      // Calculate total energy
      double totalActiveEnergy = activeEnergyData.fold(0, (prev, e) {
        final val = e.value;
        return prev + (val is NumericHealthValue ? val.numericValue.toDouble() : 0.0);
      });

      double totalBasalEnergy = basalEnergyData.fold(0, (prev, e) {
        final val = e.value;
        return prev + (val is NumericHealthValue ? val.numericValue.toDouble() : 0.0);
      });

      // Get body fat percentage
      developer.log('Fetching body fat data', name: 'TonTon.HealthService');
      final bodyFatData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.BODY_FAT_PERCENTAGE],
      );
      developer.log('Fetched ${bodyFatData.length} body fat records', name: 'TonTon.HealthService');

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
      
      developer.log('Built activity summary: ${summary.toString()}', name: 'TonTon.HealthService');
      return summary;
    } catch (e, stack) {
      developer.log('Error in getActivitySummary: $e', name: 'TonTon.HealthService.error', error: e, stackTrace: stack);
      // Return empty summary rather than crashing
      return ActivitySummary(
        workoutTypes: [],
        workoutCalories: 0,
        totalCalories: 0,
      );
    }
  }

  Future<WeightRecord?> getLatestWeight(DateTime date) async {
    developer.log('Getting latest weight for date: $date', name: 'TonTon.HealthService');
    
    try {
      final startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final endTime = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

      // Get weight data
      developer.log('Fetching weight data', name: 'TonTon.HealthService');
      final weightData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.WEIGHT],
      );
      developer.log('Fetched ${weightData.length} weight records', name: 'TonTon.HealthService');

      if (weightData.isEmpty) {
        developer.log('No weight data available', name: 'TonTon.HealthService');
        return null;
      }

      // Sort by dateFrom (newest first)
      weightData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      final latestWeightData = weightData.first;
      final weightValue = latestWeightData.value;
      
      if (weightValue is! NumericHealthValue) {
        developer.log('Weight data is not numeric', name: 'TonTon.HealthService');
        return null;
      }

      double weightInKg = weightValue.numericValue.toDouble();

      // Get body fat percentage
      developer.log('Fetching body fat data', name: 'TonTon.HealthService');
      final bodyFatData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.BODY_FAT_PERCENTAGE],
      );
      developer.log('Fetched ${bodyFatData.length} body fat records', name: 'TonTon.HealthService');

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
      
      developer.log('Built weight record: ${record.toString()}', name: 'TonTon.HealthService');
      return record;
    } catch (e, stack) {
      developer.log('Error in getLatestWeight: $e', name: 'TonTon.HealthService.error', error: e, stackTrace: stack);
      return null;
    }
  }
}