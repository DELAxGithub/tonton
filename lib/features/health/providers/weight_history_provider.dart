import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/calorie_savings_record.dart';
import '../../../models/weight_record.dart';
import '../../../providers/providers.dart';
import '../services/weight_history_service.dart';

/// Provider for WeightHistoryService
final weightHistoryServiceProvider = Provider<WeightHistoryService>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  return WeightHistoryService(healthService);
});

/// Provider for weight records aligned with calorie savings records
final weightHistoryProvider = FutureProvider.family<
  List<WeightRecord?>,
  List<CalorieSavingsRecord>
>((ref, calorieSavingsRecords) async {
  if (calorieSavingsRecords.isEmpty) {
    return [];
  }
  
  final service = ref.watch(weightHistoryServiceProvider);
  
  // Get date range from calorie savings records
  final dates = calorieSavingsRecords.map((record) => record.date).toList();
  dates.sort();
  
  final startDate = dates.first.subtract(const Duration(days: 3)); // Add buffer for tolerance
  final endDate = dates.last.add(const Duration(days: 3)); // Add buffer for tolerance
  
  try {
    // Fetch weight records from HealthKit
    final weightRecords = await service.getWeightRecords(startDate, endDate);
    
    // Align weight records with calorie savings dates
    final targetDates = calorieSavingsRecords.map((record) => record.date).toList();
    final alignedRecords = service.alignWeightRecordsWithDates(weightRecords, targetDates);
    
    return alignedRecords;
  } catch (e) {
    // Log error but don't crash - return nulls for all dates
    // This maintains backward compatibility with existing UI
    return List.generate(calorieSavingsRecords.length, (_) => null);
  }
});

/// State notifier for managing weight history with caching
class WeightHistoryNotifier extends StateNotifier<AsyncValue<Map<DateTime, WeightRecord>>> {
  final WeightHistoryService _service;
  final Map<String, List<WeightRecord>> _cache = {};
  
  WeightHistoryNotifier(this._service) : super(const AsyncValue.data({}));
  
  Future<void> loadWeightRecordsForRange(DateTime startDate, DateTime endDate) async {
    final cacheKey = '${startDate.toIso8601String()}_${endDate.toIso8601String()}';
    
    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cachedRecords = _cache[cacheKey]!;
      state = AsyncValue.data(_convertToMap(cachedRecords));
      return;
    }
    
    // Load data
    state = const AsyncValue.loading();
    
    try {
      final records = await _service.getWeightRecords(startDate, endDate);
      _cache[cacheKey] = records;
      state = AsyncValue.data(_convertToMap(records));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Map<DateTime, WeightRecord> _convertToMap(List<WeightRecord> records) {
    final map = <DateTime, WeightRecord>{};
    for (final record in records) {
      final dateOnly = DateTime(record.date.year, record.date.month, record.date.day);
      map[dateOnly] = record;
    }
    return map;
  }
  
  WeightRecord? getWeightForDate(DateTime date) {
    return state.maybeWhen(
      data: (weightMap) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        return weightMap[dateOnly];
      },
      orElse: () => null,
    );
  }
}

/// Provider for the cached weight history notifier
final weightHistoryNotifierProvider = StateNotifierProvider<WeightHistoryNotifier, AsyncValue<Map<DateTime, WeightRecord>>>((ref) {
  final service = ref.watch(weightHistoryServiceProvider);
  return WeightHistoryNotifier(service);
});