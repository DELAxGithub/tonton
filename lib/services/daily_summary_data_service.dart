import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer' as developer;

import '../models/daily_summary.dart';

class DailySummaryDataService {
  static const String _boxName = 'tonton_daily_summaries';
  Box<DailySummary>? _box;

  bool get isInitialized => _box?.isOpen ?? false;

  Future<void> init() async {
    if (isInitialized) {
      developer.log('DailySummaryDataService already initialized.', name: 'TonTon.DailySummaryDataService');
      return;
    }
    developer.log('Initializing DailySummaryDataService...', name: 'TonTon.DailySummaryDataService');
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<DailySummary>(_boxName);
    } else {
      _box = await Hive.openBox<DailySummary>(_boxName);
    }
    developer.log('DailySummaryDataService initialized. Items: ${_box?.length}', name: 'TonTon.DailySummaryDataService');
  }

  Future<void> saveSummary(DailySummary summary) async {
    if (!isInitialized) {
      await init();
    }
    final key = summary.date.toIso8601String();
    await _box!.put(key, summary);
    await _box!.flush();
  }

  DailySummary? getSummary(DateTime date) {
    if (!isInitialized) return null;
    final key = DateTime(date.year, date.month, date.day).toIso8601String();
    return _box!.get(key);
  }

  List<DailySummary> getAllSummaries() {
    if (!isInitialized) return [];
    return _box!.values.toList();
  }
}

