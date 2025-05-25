import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/meal_record.dart';
import 'enums/meal_time_type.dart';
import 'providers/health_provider.dart';
import 'routes/router.dart'; // Import router configuration
import 'services/onboarding_service.dart';
import 'providers/onboarding_providers.dart';
import 'providers/onboarding_start_date_provider.dart';
import 'theme/app_theme.dart'; // Import application theme
import 'l10n/app_localizations.dart';

// Function to initialize Hive
Future<void> _initHive() async {
  developer.log('Initializing Hive for Tonton main app...', name: 'TonTon.HiveInit');
  try {
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    developer.log('Hive initialized at: ${appDocumentDir.path}', name: 'TonTon.HiveInit');

    // Register adapters
    if (!Hive.isAdapterRegistered(1)) { // MealTimeTypeAdapter
      Hive.registerAdapter(MealTimeTypeAdapter());
      developer.log('MealTimeTypeAdapter registered.', name: 'TonTon.HiveInit');
    }
    if (!Hive.isAdapterRegistered(2)) { // MealRecordAdapter
      Hive.registerAdapter(MealRecordAdapter());
      developer.log('MealRecordAdapter registered.', name: 'TonTon.HiveInit');
    }

    // Open boxes
    // Using a distinct box name for the main app to avoid conflict with health_poc_app if it shares storage
    await Hive.openBox<MealRecord>('tonton_meal_records'); 
    developer.log('Box "tonton_meal_records" opened.', name: 'TonTon.HiveInit');

    // Initialize MealDataService after Hive is ready
    // This assumes MealDataService is a singleton or can be globally accessed/initialized.
    // If using Riverpod, the provider for MealDataService will handle its creation,
    // and its init method will be called when first read if designed that way (as in MealRecords provider).
    // For explicit early initialization:
    // final mealDataService = MealDataService(); // Or however it's accessed/created
    // await mealDataService.init();
    // developer.log('MealDataService initialized after Hive.', name: 'TonTon.HiveInit');
    // Note: The current MealRecords provider already calls mealDataService.init() if not initialized.
    // So, explicit call here might be redundant if MealDataService is only used via that provider.
    // However, if other parts of the app might access MealDataService directly, initializing it here is safer.
    // For now, we'll rely on the provider's init call.

  } catch (e, stack) {
    developer.log('Error initializing Hive: $e', name: 'TonTon.HiveInit.Error', error: e, stackTrace: stack);
    // Depending on the app's requirements, you might want to rethrow or handle this error.
  }
}

void main() async { // Modified to be async
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    developer.log('.env file loaded successfully', name: 'TonTon.EnvLoad');
  } catch (e) {
    developer.log('Could not load .env file. Using compile-time variables if available. Error: $e', 
      name: 'TonTon.EnvLoad.Error');
    // エラーが発生しても継続できるように、デフォルト値を設定
    dotenv.testLoad(fileInput: '''
      SUPABASE_URL=default_url
      SUPABASE_ANON_KEY=default_key
    ''');
  }

  // Initialize Supabase using environment variables
  try {
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
                      Platform.environment['SUPABASE_URL'] ??
                      const String.fromEnvironment('SUPABASE_URL');
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
                          Platform.environment['SUPABASE_ANON_KEY'] ??
                          const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Supabase URL or Anon Key is missing. Ensure .env file is set up or variables are passed via --dart-define.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    developer.log('Supabase initialized successfully with URL: $supabaseUrl', name: 'TonTon.SupabaseInit');
  } catch (e, stack) {
    developer.log('Error initializing Supabase: $e', name: 'TonTon.SupabaseInit.Error', error: e, stackTrace: stack);
    rethrow;
  }
  
  await _initHive(); // Added Hive initialization call
  developer.log('TonTon App starting after initialization...', name: 'TonTon.main');
  final startDateNotifier = OnboardingStartDateNotifier();
  final onboardingService = OnboardingService(startDateNotifier);
  await onboardingService.ensureInitialized();
  final firstLaunch = await onboardingService.getFirstLaunch();

  runApp(
    ProviderScope(
      overrides: [
        onboardingStartDateProvider.overrideWith((ref) => startDateNotifier),
        firstLaunchTimestampProvider.overrideWith(
          (ref) async => firstLaunch,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building MyApp widget', name: 'TonTon.MyApp.build');
    
    // Get the router instance from the provider
    final router = ref.watch(routerProvider);

    // Provide HealthProvider using the legacy provider package
    // This will eventually be migrated to Riverpod
    return provider_pkg.ChangeNotifierProvider<HealthProvider>(
      create: (context) {
        developer.log('Creating HealthProvider', name: 'TonTon.Provider.create');
        return HealthProvider();
      },
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        locale: const Locale('ja'),
        debugShowCheckedModeBanner: true,
        theme: TontonTheme.light,
        // darkTheme: TontonTheme.dark,
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // Use go_router for routing
        routerConfig: router,
      ),
    );
  }
}

// _MyAppState and its lifecycle methods (initState, dispose, didChangeAppLifecycleState, _flushAllBoxes, _ensureBoxesOpen)
// are removed because MyApp is now a ConsumerWidget.
// If app lifecycle observation is still needed, it can be handled differently,
// perhaps by a dedicated Riverpod provider that uses WidgetsBindingObserver.
// For now, focusing on the auth flow.
