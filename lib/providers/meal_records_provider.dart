import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meal_record.dart';
import '../enums/meal_time_type.dart';
import '../services/meal_data_service.dart'; // Added
import 'providers.dart'; // Added to access mealDataServiceProvider

part 'meal_records_provider.g.dart';

/// A state class to hold the list of meal records and loading state
class MealRecordsState {
  final List<MealRecord> records;
  final bool isLoading;
  final String? error;

  const MealRecordsState({
    this.records = const [],
    this.isLoading = false,
    this.error,
  });

  MealRecordsState copyWith({
    List<MealRecord>? records,
    bool? isLoading,
    String? error,
  }) {
    return MealRecordsState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for managing meal records state
@riverpod
class MealRecords extends _$MealRecords {
  MealDataService get _mealDataService => ref.read(mealDataServiceProvider);

  @override
  Future<MealRecordsState> build() async { // Modified to be async
    // Ensure MealDataService is initialized before trying to use it.
    // This assumes mealDataServiceProvider gives an instance that might not be initialized.
    // A better pattern might be a FutureProvider for mealDataService if its init is async.
    if (!_mealDataService.isInitialized) {
      await _mealDataService.init(); // Call init if not already done.
    }
    final records = await _mealDataService.getAllMealRecords();
    return MealRecordsState(records: records, isLoading: false);
  }

  /// Adds a new meal record to the state and persists it
  Future<void> addMealRecord(MealRecord record) async { // Modified to be async
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));
    try {
      await _mealDataService.saveMealRecord(record);
      final newRecords = List<MealRecord>.from(state.value!.records)..add(record);
      state = AsyncValue.data(
        MealRecordsState(records: newRecords, isLoading: false),
      );
      ref.invalidateSelf();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Updates an existing meal record in the state and persists it
  Future<void> updateMealRecord(MealRecord record) async { // Modified to be async
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));
    try {
      await _mealDataService.saveMealRecord(record); // saveMealRecord handles both create and update
      final updatedRecords = await _mealDataService.getAllMealRecords();
      state = AsyncValue.data(MealRecordsState(records: updatedRecords, isLoading: false));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Deletes a meal record by its ID from the state and persists the change
  Future<void> deleteMealRecord(String id) async { // Modified to be async
    state = AsyncValue.data(state.value!.copyWith(isLoading: true));
    try {
      await _mealDataService.deleteMealRecord(id);
      final updatedRecords = await _mealDataService.getAllMealRecords();
      state = AsyncValue.data(MealRecordsState(records: updatedRecords, isLoading: false));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // The following methods operate on the current state, which is now AsyncValue<MealRecordsState>
  // They might need adjustment if the consumer expects direct List<MealRecord> or double.
  // For simplicity, we'll assume consumers will handle the AsyncValue state.
  // Or, these could be refactored into new providers that depend on mealRecordsProvider.

  /// Gets all meal records for a specific date from the current state
  List<MealRecord> getMealRecordsForDate(DateTime date) {
    if (state.hasValue) {
      return state.value!.records.where((record) {
        final consumed = record.consumedAt.toLocal();
        return consumed.year == date.year &&
            consumed.month == date.month &&
            consumed.day == date.day;
      }).toList();
    }
    return [];
  }

  /// Gets all meal records for a specific date and meal time type from the current state
  List<MealRecord> getMealRecordsForDateAndType(
    DateTime date, 
    MealTimeType mealTimeType,
  ) {
    return getMealRecordsForDate(date)
      .where((record) => record.mealTimeType == mealTimeType)
      .toList();
  }

  /// Gets the total calories for a specific date from the current state
  double getTotalCaloriesForDate(DateTime date) {
    // This is one of the duplicated methods. The one above is correct for AsyncValue.
    // Keeping the one that handles AsyncValue state.
    if (state.hasValue) {
       return getMealRecordsForDate(date) // This now refers to the method that handles AsyncValue
         .fold(0, (sum, record) => sum + record.calories);
    }
    return 0.0;
  }
}

/// Convenience provider for getting records for today
@riverpod
List<MealRecord> todaysMealRecords(Ref ref) {
  // Watch the async state of mealRecordsProvider
  final mealRecordsAsyncValue = ref.watch(mealRecordsProvider);
  
  // Handle loading, error, and data states
  return mealRecordsAsyncValue.when(
    data: (mealRecordsState) {
      final today = DateTime.now();
      return mealRecordsState.records.where((record) {
        final recordDate = record.consumedAt;
        return recordDate.year == today.year &&
               recordDate.month == today.month &&
               recordDate.day == today.day;
      }).toList();
    },
    loading: () => [], // Return empty list while loading
    error: (error, stack) => [], // Return empty list on error, or handle error differently
  );
}

/// Provider for getting total calories for today
@riverpod
double todaysTotalCalories(Ref ref) {
  // This provider depends on todaysMealRecordsProvider, which now handles async state.
  final todaysRecords = ref.watch(todaysMealRecordsProvider); // This will be List<MealRecord>
  return todaysRecords.fold(0, (sum, record) => sum + record.calories);
}

/// Provider for accessing a specific meal record by ID
@riverpod
MealRecord? mealRecord(Ref ref, String id) {
  final mealRecordsAsyncValue = ref.watch(mealRecordsProvider);
  
  return mealRecordsAsyncValue.when(
    data: (mealRecordsState) {
      try {
        return mealRecordsState.records.firstWhere((record) => record.id == id);
      } catch (e) {
        return null; // Not found
      }
    },
    loading: () => null,
    error: (error, stack) => null,
  );
}
