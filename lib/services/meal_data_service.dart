import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer' as developer;

import '../models/meal_record.dart';

/// Shared instance of [MealDataService] for the whole app.
final mealDataService = MealDataService();

class MealDataService {
  static const String _boxName = 'tonton_meal_records'; // Must match the box opened in main.dart
  Box<MealRecord>? _mealRecordsBox;

  bool get isInitialized => _mealRecordsBox?.isOpen ?? false;

  Future<void> init() async {
    if (isInitialized) {
      developer.log('MealDataService already initialized.', name: 'TonTon.MealDataService');
      return;
    }
    developer.log('Initializing MealDataService...', name: 'TonTon.MealDataService');
    
    if (Hive.isBoxOpen(_boxName)) {
      _mealRecordsBox = Hive.box<MealRecord>(_boxName);
      developer.log('MealDataService: Box "$_boxName" reference obtained. Items: ${_mealRecordsBox?.length}', name: 'TonTon.MealDataService');
    } else {
      developer.log('MealDataService: Box "$_boxName" is not open. This should have been opened in main.dart. Attempting to open...', name: 'TonTon.MealDataService', level: 900);
      try {
        _mealRecordsBox = await Hive.openBox<MealRecord>(_boxName);
        developer.log('MealDataService: Box "$_boxName" opened. Items: ${_mealRecordsBox?.length}', name: 'TonTon.MealDataService');
      } catch (e, stack) {
        developer.log('MealDataService: Failed to open box "$_boxName" in service init', error: e, stackTrace: stack, name: 'TonTon.MealDataService', level: 1000);
        rethrow;
      }
    }
    if (!isInitialized) {
       developer.log('MealDataService: Initialization failed, box "$_boxName" is not open.', name: 'TonTon.MealDataService', level: 1000);
    } else {
       developer.log('MealDataService initialized successfully.', name: 'TonTon.MealDataService');
    }
  }

  Future<void> saveMealRecord(MealRecord record) async {
    if (!isInitialized) {
      developer.log('MealDataService not initialized, cannot save record.', name: 'TonTon.MealDataService', level: 900);
      throw StateError('MealDataService: Box not initialized. Cannot save.');
    }
    developer.log('MealDataService: Saving meal record with id: ${record.id}', name: 'TonTon.MealDataService');
    await _mealRecordsBox!.put(record.id, record);
    await _mealRecordsBox!.flush(); // Ensure data is written to disk
    developer.log('MealDataService: Meal record saved and flushed. ID: ${record.id}', name: 'TonTon.MealDataService');
  }

  Future<MealRecord?> getMealRecordById(String id) async {
    if (!isInitialized) {
      developer.log('MealDataService not initialized, cannot get record by id.', name: 'TonTon.MealDataService', level: 900);
      return null;
    }
    developer.log('MealDataService: Getting meal record by id: $id', name: 'TonTon.MealDataService');
    return _mealRecordsBox!.get(id);
  }

  Future<List<MealRecord>> getAllMealRecords() async {
    if (!isInitialized) {
      developer.log('MealDataService not initialized, cannot get all records.', name: 'TonTon.MealDataService', level: 900);
      return [];
    }
    developer.log('MealDataService: Getting all meal records. Count: ${_mealRecordsBox!.values.length}', name: 'TonTon.MealDataService');
    return _mealRecordsBox!.values.toList();
  }

  Future<void> deleteMealRecord(String id) async {
    if (!isInitialized) {
      developer.log('MealDataService not initialized, cannot delete record.', name: 'TonTon.MealDataService', level: 900);
      throw StateError('MealDataService: Box not initialized. Cannot delete.');
    }
    developer.log('MealDataService: Deleting meal record with id: $id', name: 'TonTon.MealDataService');
    await _mealRecordsBox!.delete(id);
    await _mealRecordsBox!.flush(); // Ensure data is written to disk
    developer.log('MealDataService: Meal record deleted and flushed. ID: $id', name: 'TonTon.MealDataService');
  }

  Future<void> clearAllData() async {
    if (!isInitialized) {
      developer.log('MealDataService not initialized, cannot clear all data.', name: 'TonTon.MealDataService', level: 900);
      throw StateError('MealDataService: Box not initialized. Cannot clear.');
    }
    developer.log('MealDataService: Clearing all meal records. Count: ${_mealRecordsBox!.values.length}', name: 'TonTon.MealDataService');
    await _mealRecordsBox!.clear();
    await _mealRecordsBox!.flush(); // Ensure data is written to disk
    developer.log('MealDataService: All meal records cleared and flushed.', name: 'TonTon.MealDataService');
  }

  Future<void> close() async {
    // Box closing is generally handled by Hive's lifecycle or a central manager.
    developer.log('MealDataService: Close called. Box management is typically global.', name: 'TonTon.MealDataService');
  }
}
