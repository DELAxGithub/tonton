import 'package:health/health.dart';
import '../../../models/weight_record.dart';
import '../../../services/health_service.dart';
import '../exceptions/weight_data_exception.dart';

class WeightHistoryService {
  final HealthService _healthService;
  
  WeightHistoryService(this._healthService);
  
  /// Get weight records for the specified date range
  Future<List<WeightRecord>> getWeightRecords(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Get weight data from HealthKit
      final healthData = await _healthService.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: startDate,
        endTime: endDate,
      );
      
      // Convert HealthDataPoint to WeightRecord
      final weightRecords = <WeightRecord>[];
      
      for (final data in healthData) {
        if (data.value is NumericHealthValue) {
          final numericValue = data.value as NumericHealthValue;
          final weight = numericValue.numericValue.toDouble();
          
          // Skip invalid weight values
          if (weight > 0 && weight < 500) { // Reasonable weight range in kg
            weightRecords.add(WeightRecord(
              weight: weight,
              date: data.dateFrom,
            ));
          }
        }
      }
      
      // Sort by date (newest first)
      weightRecords.sort((a, b) => b.date.compareTo(a.date));
      
      return weightRecords;
    } catch (e) {
      // Proper error handling with specific exception types
      if (e.toString().contains('permission')) {
        throw WeightDataException.permissionDenied();
      } else if (e.toString().contains('no data')) {
        throw WeightDataException.dataUnavailable();
      } else {
        throw WeightDataException.unknown(e);
      }
    }
  }
  
  /// Find the weight record for a specific date or the nearest one within tolerance
  WeightRecord? findWeightForDate(
    List<WeightRecord> records,
    DateTime targetDate, {
    int toleranceDays = 3,
  }) {
    if (records.isEmpty) return null;
    
    // First, try to find exact date match (ignoring time)
    final targetDateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
    
    final exactMatch = records.firstWhere(
      (record) {
        final recordDateOnly = DateTime(record.date.year, record.date.month, record.date.day);
        return recordDateOnly == targetDateOnly;
      },
      orElse: () => WeightRecord(weight: -1, date: DateTime(1900)), // Sentinel value
    );
    
    if (exactMatch.weight > 0) return exactMatch;
    
    // If no exact match, find the nearest within tolerance
    WeightRecord? nearestRecord;
    int minDaysDifference = toleranceDays + 1;
    
    for (final record in records) {
      final recordDateOnly = DateTime(record.date.year, record.date.month, record.date.day);
      final daysDifference = targetDateOnly.difference(recordDateOnly).inDays.abs();
      
      if (daysDifference <= toleranceDays && daysDifference < minDaysDifference) {
        nearestRecord = record;
        minDaysDifference = daysDifference;
      }
    }
    
    return nearestRecord;
  }
  
  /// Align weight records with calorie savings records by date
  List<WeightRecord?> alignWeightRecordsWithDates(
    List<WeightRecord> weightRecords,
    List<DateTime> targetDates,
  ) {
    final alignedRecords = <WeightRecord?>[];
    
    for (final targetDate in targetDates) {
      final weightForDate = findWeightForDate(weightRecords, targetDate);
      alignedRecords.add(weightForDate);
    }
    
    return alignedRecords;
  }
}