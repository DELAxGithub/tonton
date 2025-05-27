// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TonTon Health Pro';

  @override
  String get hello => 'Hello';

  @override
  String get tabActivity => 'Activity';

  @override
  String get tabMeals => 'Meals';

  @override
  String get tabHome => 'Home';

  @override
  String get tabInsights => 'Insights';

  @override
  String get tabRecord => 'Record';

  @override
  String get tabHistory => 'History';

  @override
  String get tabSettings => 'Settings';

  @override
  String get todaysCalories => 'Today\'s Calories';

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get activitySummary => 'Activity Summary';

  @override
  String get todaysMeals => 'Today\'s Meals';

  @override
  String get lastSevenDays => 'Last 7 Days';

  @override
  String get monthlyGoal => 'Monthly Goal';

  @override
  String get targetCalories => 'Target Calories';

  @override
  String get consumed => 'Consumed';

  @override
  String get burned => 'Burned';

  @override
  String get balance => 'Balance';

  @override
  String get noMealsRecorded => 'No meals recorded today';

  @override
  String get tapAddMeal => 'Tap the + button to add your meals';

  @override
  String get calorieSavingsGraph => 'Calorie Savings';

  @override
  String get aiAdviceRequest => 'Get AI meal advice';

  @override
  String get aiAdviceShort => 'AI Suggest';

  @override
  String get aiAdviceDisabled => 'AI advice requires at least two meals';

  @override
  String aiAdviceError(Object error) {
    return 'Failed to fetch AI advice: $error';
  }

  @override
  String get addMeal => 'Add Meal';

  @override
  String get debugPanel => 'Debug Panel';

  @override
  String get testProvider => 'Test Provider';
}
