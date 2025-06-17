import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../enums/meal_time_type.dart';

/// Platform-aware icon mapper
/// Returns appropriate icons for each platform to maintain native look & feel
class TontonIcons {
  /// Check if the platform is iOS
  static final bool _isIOS = defaultTargetPlatform == TargetPlatform.iOS;

  /// Font family name for custom icons
  static const String _fontFamily = 'TontonIcons';

  // Temporary fallback to system icons to fix build issue
  static const IconData _iconArrow = Icons.arrow_forward;
  static const IconData _iconBicycle = Icons.directions_bike;
  static const IconData _iconCamera = Icons.camera_alt;
  static const IconData _iconCoin = Icons.monetization_on;
  static const IconData _iconGraph = Icons.show_chart;
  static const IconData _iconPigface = Icons.face;
  static const IconData _iconPiggybank = Icons.account_balance;
  static const IconData _iconPresent = Icons.card_giftcard;
  static const IconData _iconRestaurant = Icons.restaurant;
  static const IconData _iconScale = Icons.monitor_weight;
  static const IconData _iconWorkout = Icons.fitness_center;

  // Public accessors for custom icons
  static IconData get arrow => _iconArrow;
  static IconData get bicycle => _iconBicycle;
  static IconData get camera => _iconCamera;
  static IconData get coin => _iconCoin;
  static IconData get graph => _iconGraph;
  static IconData get pigface => _iconPigface;
  static IconData get piggybank => _iconPiggybank;
  static IconData get present => _iconPresent;
  static IconData get restaurantIcon => _iconRestaurant;
  static IconData get scale => _iconScale;
  static IconData get workout => _iconWorkout;

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
      _isIOS ? CupertinoIcons.waveform_path : _iconWorkout;

  /// Icon for the food/meal tab
  static IconData get food =>
      _isIOS ? CupertinoIcons.cart : _iconRestaurant;
  
  /// Icon for the analytics/insights tab
  static IconData get insights =>
      _isIOS ? CupertinoIcons.graph_square : _iconGraph;
  
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
      _isIOS ? CupertinoIcons.arrow_down_circle : _iconScale;
  
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