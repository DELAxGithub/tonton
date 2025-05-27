// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'トントン ヘルス';

  @override
  String get hello => 'こんにちは';

  @override
  String get tabActivity => 'アクティビティ';

  @override
  String get tabMeals => '食事';

  @override
  String get tabHome => 'ホーム';

  @override
  String get tabInsights => '分析';

  @override
  String get tabRecord => '記録';

  @override
  String get tabHistory => '履歴';

  @override
  String get tabSettings => '設定';

  @override
  String get todaysCalories => '今日のカロリー';

  @override
  String get yourProgress => 'あなたの進捗';

  @override
  String get activitySummary => 'アクティビティ概要';

  @override
  String get todaysMeals => '今日の食事';

  @override
  String get lastSevenDays => '過去7日間';

  @override
  String get monthlyGoal => '月間目標';

  @override
  String get targetCalories => '目標カロリー';

  @override
  String get consumed => '摂取';

  @override
  String get burned => '消費';

  @override
  String get balance => '収支';

  @override
  String get noMealsRecorded => '今日の食事記録はありません';

  @override
  String get tapAddMeal => '「+」ボタンから食事を追加してください';

  @override
  String get calorieSavingsGraph => 'カロリー貯金';

  @override
  String get aiAdviceRequest => 'AIに最後の食事の提案を求める';

  @override
  String get aiAdviceShort => 'AI提案';

  @override
  String get aiAdviceDisabled => 'AIアドバイスは2食以上記録すると利用できます。';

  @override
  String aiAdviceError(Object error) {
    return 'AIアドバイスの取得に失敗しました: $error';
  }

  @override
  String get addMeal => '食事を追加';

  @override
  String get debugPanel => 'デバッグパネル';

  @override
  String get testProvider => 'プロバイダーをテスト';
}
