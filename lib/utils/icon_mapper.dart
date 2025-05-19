import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../enums/meal_time_type.dart';

/// Platform-aware icon mapper
/// Returns appropriate icons for each platform to maintain native look & feel
class TontonIcons {
  /// Check if the platform is iOS
  static final bool _isIOS = defaultTargetPlatform == TargetPlatform.iOS;

  /// Returns an icon representing the [MealTimeType].
  static IconData mealTimeIcon(MealTimeType type) {
    switch (type) {
      case MealTimeType.breakfast:
        return _isIOS ? CupertinoIcons.sunrise : Icons.free_breakfast;
      case MealTimeType.lunch:
        return _isIOS ? CupertinoIcons.sun_max : Icons.lunch_dining;
      case MealTimeType.dinner:
        return _isIOS ? CupertinoIcons.moon : Icons.dinner_dining;
      case MealTimeType.snack:
        return _isIOS ? CupertinoIcons.bag : Icons.fastfood;
    }
  }

  /// Icon representing calories/energy
  static IconData get energy => 
      _isIOS ? CupertinoIcons.flame : Icons.local_fire_department;
  
  /// Icon for the home tab
  static IconData get home => 
      _isIOS ? CupertinoIcons.house : Icons.home;
  
  /// Icon for the activity tab
  static IconData get activity => 
      _isIOS ? CupertinoIcons.waveform_path : Icons.fitness_center;

  /// Icon for the food/meal tab
  static IconData get food => 
      _isIOS ? CupertinoIcons.cart : Icons.restaurant;
  
  /// Icon for the analytics/insights tab
  static IconData get insights => 
      _isIOS ? CupertinoIcons.graph_square : Icons.insights;
  
  /// Icon for the settings tab
  static IconData get settings => 
      _isIOS ? CupertinoIcons.settings : Icons.settings;

  /// Icon for adding items
  static IconData get add => 
      _isIOS ? CupertinoIcons.add : Icons.add;
  
  /// Icon for AI features
  static IconData get ai => 
      _isIOS ? CupertinoIcons.lightbulb : Icons.lightbulb_outline;
  
  /// Icon for profile
  static IconData get profile => 
      _isIOS ? CupertinoIcons.person : Icons.person;
  
  /// Icon for trends or statistics
  static IconData get trend => 
      _isIOS ? CupertinoIcons.chart_bar : Icons.trending_up;
  
  /// Icon for weight
  static IconData get weight => 
      _isIOS ? CupertinoIcons.arrow_down_circle : Icons.monitor_weight;
  
  /// Icon for calendar
  static IconData get calendar => 
      _isIOS ? CupertinoIcons.calendar : Icons.calendar_today;
  
  /// Icon for progress
  static IconData get progress => 
      _isIOS ? CupertinoIcons.chart_pie : Icons.pie_chart;
  
  /// Icon for information
  static IconData get info => 
      _isIOS ? CupertinoIcons.info : Icons.info;
}

/// Icon representing calories/energy burn.
/// Legacy function for backward compatibility
@Deprecated('Use TontonIcons.energy instead')
IconData energyIcon() {
  return TontonIcons.energy;
}

/// Returns an icon representing the [MealTimeType].
/// Legacy function for backward compatibility
@Deprecated('Use TontonIcons.mealTimeIcon instead')
IconData mealTimeIcon(MealTimeType type) {
  return TontonIcons.mealTimeIcon(type);
}