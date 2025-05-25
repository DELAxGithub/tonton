import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

/// Simple localization class that loads messages from ARB files at runtime.
class AppLocalizations {
  AppLocalizations(this.locale);

  /// The locale that was selected.
  final Locale locale;

  /// The delegate that allows Flutter to load the localizations.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Supported locales for the app.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ja'),
  ];

  /// Helper method to keep the code terse.
  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (instance == null) {
      throw FlutterError(
        'AppLocalizations.of() called with a context that does not contain an AppLocalizations instance.',
      );
    }
    return instance;
  }

  late Map<String, String> _localizedStrings;

  /// Load the ARB file for the current locale.
  Future<bool> load() async {
    final jsonString =
        await rootBundle.loadString('lib/l10n/app_${locale.languageCode}.arb');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String? _getString(String key) => _localizedStrings[key];

  /// Exposed getters for each localized string.
  String get appTitle => _getString('appTitle') ?? '';
  String get hello => _getString('hello') ?? '';
  String get tabActivity => _getString('tabActivity') ?? '';
  String get tabMeals => _getString('tabMeals') ?? '';
  String get tabHome => _getString('tabHome') ?? '';
  String get tabInsights => _getString('tabInsights') ?? '';
  String get tabRecord => _getString('tabRecord') ?? '';
  String get todaysMeals => _getString('todaysMeals') ?? '';
  String get todaysCalories => _getString('todaysCalories') ?? '';
  String get consumed => _getString('consumed') ?? '';
  String get burned => _getString('burned') ?? '';
  String get balance => _getString('balance') ?? '';
  String get yourProgress => _getString('yourProgress') ?? '';
  String get monthlyGoal => _getString('monthlyGoal') ?? '';
  String get noMealsRecorded => _getString('noMealsRecorded') ?? '';
  String get tapAddMeal => _getString('tapAddMeal') ?? '';
  String get calorieSavingsGraph => _getString('calorieSavingsGraph') ?? '';
  String get aiAdviceRequest => _getString('aiAdviceRequest') ?? '';
  String get aiAdviceShort => _getString('aiAdviceShort') ?? '';
  String get aiAdviceDisabled => _getString('aiAdviceDisabled') ?? '';
  String get addMeal => _getString('addMeal') ?? '';
  String get debugPanel => _getString('debugPanel') ?? '';
  String get testProvider => _getString('testProvider') ?? '';
  String aiAdviceError(String error) =>
      (_getString('aiAdviceError') ?? '').replaceFirst('{error}', error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ja'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}