import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../../../models/meal_record.dart';
import '../../../models/pfc_breakdown.dart';
import '../../../models/ai_advice_request.dart';
import '../../../models/ai_advice_response.dart';
import '../../../services/ai_advice_service.dart';
import '../../progress/providers/auto_pfc_provider.dart';
import '../../profile/providers/user_profile_provider.dart';
import 'meal_records_provider.dart';
import '../../../providers/providers.dart';
import '../../../core/providers/realtime_calories_provider.dart';

final aiAdviceServiceProvider = Provider<AiAdviceService>((ref) {
  final client = Supabase.instance.client;
  return AiAdviceService(client);
});

class AiAdviceNotifier extends StateNotifier<AsyncValue<AiAdviceResponse?>> {
  final AiAdviceService _service;
  final Ref _ref;

  AiAdviceNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> fetchAdvice(List<MealRecord> meals, String languageCode) async {
    state = const AsyncValue.loading();
    try {
      // 自動計算されたPFC目標を取得
      final autoPfc = _ref.read(autoPfcTargetProvider);
      final dailyTarget = _ref.read(dailyCalorieTargetProvider);
      
      // デフォルト値または自動計算値を使用
      final targetCalories = dailyTarget.toDouble();
      final targetPfcRatio = autoPfc != null
          ? PfcRatio(
              protein: autoPfc.protein / (autoPfc.protein + autoPfc.fat + autoPfc.carbohydrate),
              fat: autoPfc.fat / (autoPfc.protein + autoPfc.fat + autoPfc.carbohydrate),
              carbohydrate: autoPfc.carbohydrate / (autoPfc.protein + autoPfc.fat + autoPfc.carbohydrate),
            )
          : PfcRatio(
              protein: 0.3,
              fat: 0.2,
              carbohydrate: 0.5,
            );

      double consumedProtein = 0;
      double consumedFat = 0;
      double consumedCarbs = 0;
      double consumedCalories = 0;

      for (final meal in meals) {
        consumedProtein += meal.protein;
        consumedFat += meal.fat;
        consumedCarbs += meal.carbs;
        consumedCalories += meal.calories;
      }

      final consumedMealsPfc = PfcBreakdown(
        protein: consumedProtein,
        fat: consumedFat,
        carbohydrate: consumedCarbs,
        calories: consumedCalories,
      );

      // アクティビティカロリーを取得
      double activeCalories = 0;
      final summaryAsync = _ref.read(realtimeDailySummaryProvider);
      activeCalories = summaryAsync.maybeWhen(
        data: (summary) => summary.caloriesBurned,
        orElse: () => 0.0,
      );

      // 週間トレンドとユーザープロフィールを取得
      final weeklyTrend = _ref.read(weeklyAchievementTrendProvider);
      final userProfile = _ref.read(userProfileProvider);
      
      final request = AiAdviceRequest(
        targetCalories: targetCalories,
        targetPfcRatio: targetPfcRatio,
        consumedMealsPfc: consumedMealsPfc,
        activeCalories: activeCalories,
        lang: languageCode,
      );

      // 拡張版のアドバイス生成を使用
      final response = await _service.generateMealAdvice(
        request: request,
        userProfile: userProfile,
        weeklyTrend: weeklyTrend,
        currentTime: DateTime.now(),
      );
      state = AsyncValue.data(response);
    } catch (e) {
      // エラー時の暫定対応：ダミーデータを返す
      developer.log('AI Advice Error: $e', name: 'TonTon.AiAdviceNotifier', error: e);
      state = AsyncValue.data(AiAdviceResponse(
        adviceMessage: languageCode == 'ja' 
          ? '申し訳ございません。アドバイスの取得中にエラーが発生しました。栄養バランスを考慮した食事を心がけましょう。'
          : 'Sorry, an error occurred while fetching advice. Please try to maintain a balanced diet.',
        suggestions: languageCode == 'ja' 
          ? ['野菜を多めに摂取しましょう', 'タンパク質を意識して摂りましょう', '水分補給を忘れずに']
          : ['Include more vegetables', 'Focus on protein intake', 'Stay hydrated'],
        warning: null,
      ));
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final aiAdviceProvider =
    StateNotifierProvider<AiAdviceNotifier, AsyncValue<AiAdviceResponse?>>((
      ref,
    ) {
      final service = ref.watch(aiAdviceServiceProvider);
      return AiAdviceNotifier(service, ref);
    });

/// 過去7日間の達成率トレンドを計算するProvider
final weeklyAchievementTrendProvider = Provider<Map<String, dynamic>>((ref) {
  final mealsAsync = ref.watch(mealRecordsProvider);
  final autoPfc = ref.watch(autoPfcTargetProvider);
  final dailyTarget = ref.watch(dailyCalorieTargetProvider);
  
  // データがまだロード中またはエラーの場合
  final List<MealRecord> meals = mealsAsync.maybeWhen(
    data: (data) => data.records,
    orElse: () => <MealRecord>[],
  );
  
  if (autoPfc == null) {
    return {
      'hasData': false,
      'averageCalorieAchievement': 0,
      'averageProteinAchievement': 0,
      'averageFatAchievement': 0,
      'averageCarbsAchievement': 0,
      'trend': 'stable',
    };
  }
  
  // 過去7日間の日付リストを作成
  final now = DateTime.now();
  final dates = List.generate(7, (i) => DateTime(now.year, now.month, now.day - i));
  
  // 各日の達成率を計算
  final dailyAchievements = <Map<String, double>>[];
  
  for (final date in dates) {
    final dayMeals = meals.where((meal) {
      final mealDate = meal.consumedAt;
      return mealDate.year == date.year &&
             mealDate.month == date.month &&
             mealDate.day == date.day;
    }).toList();
    
    if (dayMeals.isNotEmpty) {
      final protein = dayMeals.fold<double>(0, (sum, m) => sum + m.protein);
      final fat = dayMeals.fold<double>(0, (sum, m) => sum + m.fat);
      final carbs = dayMeals.fold<double>(0, (sum, m) => sum + m.carbs);
      final calories = dayMeals.fold<double>(0, (sum, m) => sum + m.calories);
      
      dailyAchievements.add({
        'calories': calories / dailyTarget * 100,
        'protein': protein / autoPfc.protein * 100,
        'fat': fat / autoPfc.fat * 100,
        'carbs': carbs / autoPfc.carbohydrate * 100,
      });
    }
  }
  
  if (dailyAchievements.isEmpty) {
    return {
      'hasData': false,
      'averageCalorieAchievement': 0,
      'averageProteinAchievement': 0,
      'averageFatAchievement': 0,
      'averageCarbsAchievement': 0,
      'trend': 'stable',
    };
  }
  
  // 平均達成率を計算
  final avgCalories = dailyAchievements.map((d) => d['calories']!).reduce((a, b) => a + b) / dailyAchievements.length;
  final avgProtein = dailyAchievements.map((d) => d['protein']!).reduce((a, b) => a + b) / dailyAchievements.length;
  final avgFat = dailyAchievements.map((d) => d['fat']!).reduce((a, b) => a + b) / dailyAchievements.length;
  final avgCarbs = dailyAchievements.map((d) => d['carbs']!).reduce((a, b) => a + b) / dailyAchievements.length;
  
  // トレンドを判定（最初の3日と最後の3日を比較）
  String trend = 'stable';
  if (dailyAchievements.length >= 6) {
    final firstHalf = dailyAchievements.take(3).map((d) => d['calories']!).reduce((a, b) => a + b) / 3;
    final secondHalf = dailyAchievements.skip(dailyAchievements.length - 3).map((d) => d['calories']!).reduce((a, b) => a + b) / 3;
    
    if (secondHalf > firstHalf * 1.1) {
      trend = 'improving';
    } else if (secondHalf < firstHalf * 0.9) {
      trend = 'declining';
    }
  }
  
  return {
    'hasData': true,
    'averageCalorieAchievement': avgCalories.round(),
    'averageProteinAchievement': avgProtein.round(),
    'averageFatAchievement': avgFat.round(),
    'averageCarbsAchievement': avgCarbs.round(),
    'trend': trend,
    'daysWithData': dailyAchievements.length,
  };
});
