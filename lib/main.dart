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
import 'models/daily_summary.dart';
import 'enums/meal_time_type.dart';
import 'providers/providers.dart';
import 'routes/router.dart'; // Import router configuration
import 'services/onboarding_service.dart';
import 'features/onboarding/providers/onboarding_providers.dart';
import 'services/daily_summary_data_service.dart';
import 'services/meal_data_service.dart';
import 'services/health_service.dart';
import 'theme/app_theme.dart'; // Import application theme
import 'l10n/app_localizations.dart';

// Function to initialize Hive
Future<void> _initHive() async {
  developer.log(
    'Initializing Hive for Tonton main app...',
    name: 'TonTon.HiveInit',
  );
  try {
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    developer.log(
      'Hive initialized at: ${appDocumentDir.path}',
      name: 'TonTon.HiveInit',
    );

    // Register adapters
    if (!Hive.isAdapterRegistered(1)) {
      // MealTimeTypeAdapter
      Hive.registerAdapter(MealTimeTypeAdapter());
      developer.log('MealTimeTypeAdapter registered.', name: 'TonTon.HiveInit');
    }
    if (!Hive.isAdapterRegistered(2)) {
      // MealRecordAdapter
      Hive.registerAdapter(MealRecordAdapter());
      developer.log('MealRecordAdapter registered.', name: 'TonTon.HiveInit');
    }
    if (!Hive.isAdapterRegistered(3)) {
      // DailySummaryAdapter
      Hive.registerAdapter(DailySummaryAdapter());
      developer.log('DailySummaryAdapter registered.', name: 'TonTon.HiveInit');
    }

    // Open boxes
    // Using a distinct box name for the main app to avoid conflict with health_poc_app if it shares storage
    await Hive.openBox<MealRecord>('tonton_meal_records');
    developer.log('Box "tonton_meal_records" opened.', name: 'TonTon.HiveInit');

    await Hive.openBox<DailySummary>('tonton_daily_summaries');
    developer.log(
      'Box "tonton_daily_summaries" opened.',
      name: 'TonTon.HiveInit',
    );

    // Initialize MealDataService after Hive is ready so that the box is reused
    // consistently across the app.
    await mealDataService.init();
    developer.log(
      'MealDataService initialized after Hive.',
      name: 'TonTon.HiveInit',
    );
  } catch (e, stack) {
    developer.log(
      'Error initializing Hive: $e',
      name: 'TonTon.HiveInit.Error',
      error: e,
      stackTrace: stack,
    );
    // Depending on the app's requirements, you might want to rethrow or handle this error.
  }
}

void main() async {
  // Modified to be async
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    developer.log('.env file loaded successfully', name: 'TonTon.EnvLoad');
  } catch (e) {
    developer.log(
      'Could not load .env file. Using compile-time variables if available. Error: $e',
      name: 'TonTon.EnvLoad.Error',
    );
    // エラーが発生しても継続できるように、デフォルト値を設定
    dotenv.testLoad(
      fileInput: '''
      SUPABASE_URL=default_url
      SUPABASE_ANON_KEY=default_key
    ''',
    );
  }

  // Initialize Supabase using environment variables
  try {
    final supabaseUrl =
        dotenv.env['SUPABASE_URL'] ??
        Platform.environment['SUPABASE_URL'] ??
        const String.fromEnvironment('SUPABASE_URL');
    final supabaseAnonKey =
        dotenv.env['SUPABASE_ANON_KEY'] ??
        Platform.environment['SUPABASE_ANON_KEY'] ??
        const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase URL or Anon Key is missing. Ensure .env file is set up or variables are passed via --dart-define.',
      );
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    developer.log(
      'Supabase initialized successfully with URL: $supabaseUrl',
      name: 'TonTon.SupabaseInit',
    );
  } catch (e, stack) {
    developer.log(
      'Error initializing Supabase: $e',
      name: 'TonTon.SupabaseInit.Error',
      error: e,
      stackTrace: stack,
    );
    rethrow;
  }

  await _initHive(); // Added Hive initialization call
  developer.log(
    'TonTon App starting after initialization...',
    name: 'TonTon.main',
  );
  final dailySummaryService = DailySummaryDataService();
  final startDateNotifier = OnboardingStartDateNotifier(dailySummaryService);
  final onboardingService = OnboardingService(
    startDateNotifier,
    HealthService(),
  );
  await onboardingService.ensureInitialized();
  final firstLaunch = await onboardingService.getFirstLaunch();

  runApp(
    ProviderScope(
      overrides: [
        onboardingStartDateProvider.overrideWith((ref) => startDateNotifier),
        firstLaunchTimestampProvider.overrideWith((ref) async => firstLaunch),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      developer.log(
        'App paused - flushing Hive boxes',
        name: '[HIVE_LIFECYCLE]',
      );
      await _flushAllBoxes();
    } else if (state == AppLifecycleState.resumed) {
      developer.log('App resumed', name: '[HIVE_LIFECYCLE]');
      // No provider refresh needed on resume
    }
  }

  Future<void> _flushAllBoxes() async {
    final mealBox = Hive.box<MealRecord>('tonton_meal_records');
    await mealBox.flush();
    final summaryBox = Hive.box<DailySummary>('tonton_daily_summaries');
    await summaryBox.flush();
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building MyApp widget', name: 'TonTon.MyApp.build');

    final router = ref.watch(routerProvider);

    return provider_pkg.ChangeNotifierProvider<HealthProvider>(
      create: (context) {
        developer.log(
          'Creating HealthProvider',
          name: 'TonTon.Provider.create',
        );
        return HealthProvider();
      },
      child: MaterialApp.router(
        onGenerateTitle:
            (context) => AppLocalizations.of(context)?.appTitle ?? 'Tonton',
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
        routerConfig: router,
      ),
    );
  }
}
