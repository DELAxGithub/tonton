import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../providers/providers.dart';
import '../features/home/screens/home_screen.dart';
import '../features/onboarding/screens/login_screen.dart';
import '../features/onboarding/screens/signup_screen.dart';
import '../features/savings/screens/savings_trend_screen.dart';
import '../features/savings/screens/use_savings_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/basic_info_screen.dart';
import '../features/onboarding/screens/onboarding_set_start_date_screen.dart';
import '../features/health/screens/weight_input_screen.dart';
import '../features/onboarding/providers/onboarding_providers.dart';
import '../features/profile/screens/settings_screen.dart';
import '../features/progress/screens/progress_achievements_screen.dart';
import '../features/progress/screens/daily_meals_detail_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/meal_logging/ai/ai_meal_logging_step1_camera.dart';
import '../features/meal_logging/ai/ai_meal_logging_step2_analyzing.dart';
import '../features/meal_logging/ai/ai_meal_logging_step3_confirm_edit.dart';
import '../widgets/main_navigation_bar.dart';
import 'app_page.dart';
import '../design_system/templates/app_shell.dart';
import 'dart:io';
import '../models/estimated_meal_nutrition.dart';
import '../models/calorie_savings_record.dart';

/// Route names for named navigation
class TontonRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String addMeal = '/add-meal';
  static const String editMeal = '/edit-meal';
  static const String savingsTrend = '/savings-trend';
  static const String progress = '/progress';
  static const String useSavings = '/use-savings';
  static const String onboardingBasicInfo = '/onboarding/basic-info';
  static const String onboardingHealthKit = '/onboarding/health-kit';
  static const String onboardingIntro = '/onboarding';
  static const String onboardingStartDate = '/onboarding/start-date';
  static const String onboardingWeight = '/onboarding/weight';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String progressAchievements = '/progress-achievements';
  static const String aiMealCamera = '/ai-meal/camera';
  static const String aiMealAnalyzing = '/ai-meal/analyzing';
  static const String aiMealConfirm = '/ai-meal/confirm';
  static const String dailyMealsDetail = '/daily-meals-detail';
}

/// Provider for the router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    initialLocation: TontonRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Check if the user is logged in
      final isLoggedIn = authState.when(
        data: (state) => state.session?.user != null,
        loading: () => false,
        error: (_, __) => false,
      );

      // Determine if the user is going to an auth or onboarding page
      final isAuthRoute =
          state.matchedLocation == TontonRoutes.login ||
          state.matchedLocation == TontonRoutes.signup;
      final isOnboardingRoute =
          state.matchedLocation == TontonRoutes.onboardingBasicInfo ||
          // state.matchedLocation == TontonRoutes.onboardingHealthKit ||
          state.matchedLocation == TontonRoutes.onboardingIntro ||
          state.matchedLocation == TontonRoutes.onboardingStartDate ||
          state.matchedLocation == TontonRoutes.onboardingWeight;

      // If the user is not logged in and trying to access a protected page
      if (!isLoggedIn && !isAuthRoute) {
        return TontonRoutes.login;
      }

      // Skip onboarding flow - it's now completed automatically on login/signup
      // This block is commented out to bypass the profile setup requirement
      // if (isLoggedIn && !onboardingCompleted && !isOnboardingRoute) {
      //   return TontonRoutes.onboardingBasicInfo;
      // }

      // Prevent accessing onboarding again once completed
      if (isLoggedIn && onboardingCompleted && isOnboardingRoute) {
        return TontonRoutes.home;
      }

      // If the user is logged in and trying to access an auth page
      if (isLoggedIn && isAuthRoute) {
        return TontonRoutes.home;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Authentication routes
      GoRoute(
        path: TontonRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: TontonRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: TontonRoutes.onboardingBasicInfo,
        name: 'onboardingBasicInfo',
        builder: (context, state) => const BasicInfoScreen(),
      ),
      GoRoute(
        path: TontonRoutes.onboardingIntro,
        name: 'onboardingIntro',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: TontonRoutes.onboardingStartDate,
        name: 'onboardingStartDate',
        builder: (context, state) => const OnboardingSetStartDateScreen(),
      ),
      GoRoute(
        path: TontonRoutes.onboardingWeight,
        name: 'onboardingWeight',
        builder: (context, state) => const WeightInputScreen(),
      ),

      // Shell route with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          final appPage = child is AppPage ? child as AppPage : null;
          final appBar = appPage?.buildAppBar(context);
          return AppShell(
            appBar: appBar,
            bottomNavigationBar: MainNavigationBar(
              location: state.matchedLocation,
            ),
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: TontonRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: TontonRoutes.aiMealCamera,
            name: 'aiMealCamera',
            builder: (context, state) => const AIMealLoggingStep1Camera(),
          ),
          GoRoute(
            path: TontonRoutes.savingsTrend,
            name: 'savingsTrend',
            builder: (context, state) => const SavingsTrendScreen(),
          ),
          GoRoute(
            path: TontonRoutes.progressAchievements,
            name: 'progressAchievements',
            builder: (context, state) => const ProgressAchievementsScreen(),
          ),
          GoRoute(
            path: TontonRoutes.progress,
            name: 'progress',
            builder: (context, state) => const ProgressAchievementsScreen(),
          ),
          GoRoute(
            path: TontonRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: TontonRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      GoRoute(
        path: TontonRoutes.useSavings,
        name: 'useSavings',
        builder: (context, state) => const UseSavingsScreen(),
      ),

      // Daily meals detail
      GoRoute(
        path: TontonRoutes.dailyMealsDetail,
        name: 'dailyMealsDetail',
        builder: (context, state) {
          final Map<String, dynamic>? extra =
              state.extra as Map<String, dynamic>?;
          final date = extra?['date'] as DateTime? ?? DateTime.now();
          final savingsRecord =
              extra?['savingsRecord'] as CalorieSavingsRecord?;
          return DailyMealsDetailScreen(
            date: date,
            savingsRecord: savingsRecord,
          );
        },
      ),

      // AI meal logging flow
      GoRoute(
        path: TontonRoutes.aiMealAnalyzing,
        name: 'aiMealAnalyzing',
        builder: (context, state) {
          final String? imagePath = state.extra as String?;
          if (imagePath == null) return const SizedBox.shrink();
          return AIMealLoggingStep2Analyzing(imageFile: File(imagePath));
        },
      ),
      GoRoute(
        path: TontonRoutes.aiMealConfirm,
        name: 'aiMealConfirm',
        builder: (context, state) {
          final Map<String, dynamic>? extra =
              state.extra as Map<String, dynamic>?;
          return AIMealLoggingStep3ConfirmEdit(
            imageFile: File(extra?['image'] as String),
            nutrition: extra?['nutrition'] as EstimatedMealNutrition,
          );
        },
      ),
    ],
  );
});
