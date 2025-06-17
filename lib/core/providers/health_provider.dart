import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../../models/activity_summary.dart';
import '../../models/weight_record.dart';
import '../../services/health_service.dart';

class HealthProvider with ChangeNotifier {
  final HealthService _healthService = HealthService();

  bool _isLoading = false;
  bool _hasPermissions = false;
  String _statusMessage = '「データ取得」ボタンを押してください';

  ActivitySummary? _todayActivity;
  ActivitySummary? _yesterdayActivity;
  WeightRecord? _yesterdayWeight;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasPermissions => _hasPermissions;
  String get statusMessage => _statusMessage;
  ActivitySummary? get todayActivity => _todayActivity;
  ActivitySummary? get yesterdayActivity => _yesterdayActivity;
  WeightRecord? get yesterdayWeight => _yesterdayWeight;

  // Check if we have data
  bool get hasData =>
      _todayActivity != null ||
      _yesterdayActivity != null ||
      _yesterdayWeight != null;

  // Constructor with debug output
  HealthProvider() {
    developer.log('HealthProvider created', name: 'TonTon.HealthProvider');
  }

  // Initialize and request permissions
  Future<bool> requestPermissions() async {
    developer.log('Requesting permissions', name: 'TonTon.HealthProvider');
    _setLoading(true, 'HealthKitへのアクセス許可を確認中...');

    try {
      _hasPermissions = await _healthService.requestPermissions();
      developer.log(
        'Permissions result: $_hasPermissions',
        name: 'TonTon.HealthProvider',
      );

      if (_hasPermissions) {
        _setStatus('アクセス許可が得られました。データ取得ボタンを押してください。');
      } else {
        _setStatus('HealthKitへのアクセスが許可されませんでした。設定アプリから許可してください。');
      }

      return _hasPermissions;
    } catch (e, stack) {
      developer.log(
        'Error requesting permissions: $e',
        name: 'TonTon.HealthProvider.error',
        error: e,
        stackTrace: stack,
      );
      _setStatus('エラー: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch all health data
  Future<void> fetchAllData() async {
    developer.log(
      'fetchAllData called, isLoading: $_isLoading',
      name: 'TonTon.HealthProvider',
    );
    if (_isLoading) return;

    _setLoading(true, 'HealthKitからデータを取得中...');

    // First check permissions
    if (!_hasPermissions) {
      developer.log(
        'No permissions yet, requesting now',
        name: 'TonTon.HealthProvider',
      );
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        developer.log(
          'Permission request failed',
          name: 'TonTon.HealthProvider',
        );
        _setLoading(false);
        return;
      }
    }

    try {
      developer.log(
        'Fetching today activity summary',
        name: 'TonTon.HealthProvider',
      );
      // Get today's data
      _todayActivity = await _healthService.getTodayActivitySummary();
      developer.log(
        'Today activity summary fetched: ${_todayActivity != null}',
        name: 'TonTon.HealthProvider',
      );

      // Get yesterday's data
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);

      developer.log(
        'Fetching yesterday activity summary and weight',
        name: 'TonTon.HealthProvider',
      );
      _yesterdayActivity = await _healthService.getActivitySummary(yesterday);
      _yesterdayWeight = await _healthService.getLatestWeight(yesterday);

      developer.log('Data fetch complete', name: 'TonTon.HealthProvider');
      _setStatus('データを取得しました');
    } catch (e, stack) {
      developer.log(
        'Error fetching health data: $e',
        name: 'TonTon.HealthProvider.error',
        error: e,
        stackTrace: stack,
      );
      _setStatus('エラー: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading, [String? message]) {
    developer.log(
      'Setting loading: $loading${message != null ? ", message: $message" : ""}',
      name: 'TonTon.HealthProvider',
    );
    _isLoading = loading;
    if (message != null) {
      _statusMessage = message;
    }
    notifyListeners();
    developer.log(
      'notifyListeners called for loading change',
      name: 'TonTon.HealthProvider',
    );
  }

  void _setStatus(String message) {
    developer.log('Setting status: $message', name: 'TonTon.HealthProvider');
    _statusMessage = message;
    notifyListeners();
    developer.log(
      'notifyListeners called for status change',
      name: 'TonTon.HealthProvider',
    );
  }

  // Added getter for activitySummaries
  List<ActivitySummary> get activitySummaries {
    final result = <ActivitySummary>[];
    if (_todayActivity != null) {
      result.add(_todayActivity!);
    }
    if (_yesterdayActivity != null) {
      result.add(_yesterdayActivity!);
    }
    return result;
  }

  // Getter for active calories (workout calories)
  double get activeCaloriesForToday {
    return _todayActivity?.workoutCalories ?? 0.0;
  }

  // Getter for basal calories (estimated from total - active)
  double get basalCaloriesForToday {
    if (_todayActivity == null) return 0.0;

    // Calculate basal as total minus workout calories
    return _todayActivity!.totalCalories - _todayActivity!.workoutCalories;
  }

  // Added alias for fetchAllData to make the API more intuitive
  Future<void> fetchHealthData() {
    return fetchAllData();
  }

  @override
  String toString() {
    return 'HealthProvider(loading: $_isLoading, hasPermissions: $_hasPermissions, hasData: $hasData)';
  }
}
