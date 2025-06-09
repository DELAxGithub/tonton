import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:tonton/theme/app_theme.dart';
import 'package:tonton/theme/colors.dart';

// Import use cases
import 'use_cases/atoms/tonton_button_use_cases.dart';
import 'use_cases/atoms/tonton_card_use_cases.dart';
import 'use_cases/atoms/tonton_text_field_use_cases.dart';
import 'use_cases/molecules/pfc_bar_display_use_cases.dart';
import 'use_cases/molecules/calorie_display_use_cases.dart';
import 'use_cases/organisms/hero_piggy_bank_use_cases.dart';
import 'use_cases/organisms/daily_summary_section_use_cases.dart';
import 'use_cases/themes/color_showcase.dart';
import 'use_cases/themes/typography_showcase.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      appBuilder: (context, child) {
        return MaterialApp(
          title: 'TonTon Widgetbook',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: child,
        );
      },
      directories: [
        WidgetbookCategory(
          name: 'Design System',
          children: [
            WidgetbookFolder(
              name: 'Themes',
              children: [
                colorShowcaseUseCase,
                typographyShowcaseUseCase,
              ],
            ),
            WidgetbookFolder(
              name: 'Atoms',
              children: [
                tontonButtonUseCases,
                tontonCardUseCases,
                tontonTextFieldUseCases,
              ],
            ),
            WidgetbookFolder(
              name: 'Molecules',
              children: [
                pfcBarDisplayUseCases,
                calorieDisplayUseCases,
              ],
            ),
            WidgetbookFolder(
              name: 'Organisms',
              children: [
                heroPiggyBankUseCases,
                dailySummarySectionUseCases,
              ],
            ),
          ],
        ),
      ],
      addons: [
        DeviceFrameAddon(
          devices: [
            Devices.ios.iPhoneSE,
            Devices.ios.iPhone12,
            Devices.ios.iPhone13,
            Devices.ios.iPhone14Plus,
            Devices.ios.iPadPro11Inches,
          ],
          initialDevice: Devices.ios.iPhone13,
        ),
        ThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: AppTheme.lightTheme(),
            ),
            WidgetbookTheme(
              name: 'Dark',
              data: AppTheme.darkTheme(),
            ),
          ],
          themeBuilder: (context, theme, child) {
            return Theme(
              data: theme,
              child: child,
            );
          },
        ),
        TextScaleAddon(
          min: 0.8,
          max: 1.5,
          initialScale: 1.0,
        ),
        LocalizationAddon(
          locales: [
            const Locale('en', 'US'),
            const Locale('ja', 'JP'),
          ],
          localizationsDelegates: const [
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
        ),
        InspectorAddon(),
        GridAddon(),
      ],
    );
  }
}