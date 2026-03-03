import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../providers/providers.dart';
import '../features/home/screens/home_screen.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../features/onboarding/screens/login_screen.dart';
import '../features/onboarding/screens/signup_screen.dart';
import '../features/savings/screens/savings_screen.dart';
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
import '../features/meal_logging/screens/edit_meal_screen.dart';
import '../features/meal_logging/screens/text_meal_input_screen.dart';
import '../models/meal_record.dart';
import '../widgets/main_navigation_bar.dart';
import '../design_system/templates/app_shell.dart';
import 'dart:io';
import '../models/estimated_meal_nutrition.dart';

/// Route names for named navigation
class TontonRoutes {
  static const String home = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String addMeal = '/add-meal';
  static const String editMeal = '/edit-meal';
  static const String savings = '/savings';
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
  static const String textMealInput = '/text-meal-input';
}

/// Auth/onboarding routes that don't require login
const _publicRoutes = {
  TontonRoutes.welcome,
  TontonRoutes.login,
  TontonRoutes.signup,
};

/// Onboarding routes (require login but not onboarding completion)
const _onboardingRoutes = {
  TontonRoutes.onboardingIntro,
  TontonRoutes.onboardingBasicInfo,
  TontonRoutes.onboardingStartDate,
  TontonRoutes.onboardingWeight,
};

/// Provider for the router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return GoRouter(
    initialLocation: TontonRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.when(
        data: (state) => state.session?.user != null,
        loading: () => null, // Unknown state during loading
        error: (_, __) => false,
      );

      // While auth state is loading, don't redirect
      if (isLoggedIn == null) return null;

      // Read current onboarding state (not watched, avoids rebuild loop)
      // null means still loading from SharedPreferences — don't redirect yet
      final onboardingCompleted = ref.read(onboardingCompletedProvider);
      if (onboardingCompleted == null) return null;

      final currentPath = state.matchedLocation;
      final isPublicRoute = _publicRoutes.contains(currentPath);
      final isOnboardingRoute = _onboardingRoutes.contains(currentPath);

      // Not logged in → welcome screen (unless already on a public route)
      if (!isLoggedIn) {
        return isPublicRoute ? null : TontonRoutes.welcome;
      }

      // Logged in but on a public route → redirect based on onboarding
      // Exception: allow /signup for anonymous users linking their email
      if (isPublicRoute && currentPath != TontonRoutes.signup) {
        return onboardingCompleted
            ? TontonRoutes.home
            : TontonRoutes.onboardingBasicInfo;
      }

      // Logged in, onboarding not completed, not on onboarding route → go to onboarding
      if (!onboardingCompleted && !isOnboardingRoute) {
        return TontonRoutes.onboardingBasicInfo;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Public auth routes
      GoRoute(
        path: TontonRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
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

      // Onboarding routes
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

      // Stateful shell route with bottom navigation — preserves tab state
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(
            bottomNavigationBar: MainNavigationBar(
              navigationShell: navigationShell,
            ),
            body: navigationShell,
          );
        },
        branches: [
          // Branch 0: ホーム
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: TontonRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: 記録（進捗）
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: TontonRoutes.progress,
                name: 'progress',
                builder: (context, state) =>
                    const ProgressAchievementsScreen(),
              ),
            ],
          ),
          // Branch 2: 貯金
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: TontonRoutes.savings,
                name: 'savings',
                builder: (context, state) => const SavingsScreen(),
              ),
            ],
          ),
          // Branch 3: プロフィール
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: TontonRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone detail routes (pushed over tabs)
      GoRoute(
        path: TontonRoutes.progressAchievements,
        name: 'progressAchievements',
        builder: (context, state) => const ProgressAchievementsScreen(),
      ),
      GoRoute(
        path: TontonRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Edit meal route
      GoRoute(
        path: TontonRoutes.editMeal,
        name: 'editMeal',
        builder: (context, state) {
          final mealRecord = state.extra as MealRecord;
          return EditMealScreen(mealRecord: mealRecord);
        },
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
          return DailyMealsDetailScreen(
            date: date,
          );
        },
      ),

      // AI meal logging flow
      GoRoute(
        path: TontonRoutes.aiMealCamera,
        name: 'aiMealCamera',
        builder: (context, state) => const AIMealLoggingStep1Camera(),
      ),
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
          final imagePath = extra?['image'] as String?;
          return AIMealLoggingStep3ConfirmEdit(
            imageFile: imagePath != null ? File(imagePath) : null,
            nutrition: extra?['nutrition'] as EstimatedMealNutrition,
          );
        },
      ),

      // Text-based meal input
      GoRoute(
        path: TontonRoutes.textMealInput,
        name: 'textMealInput',
        builder: (context, state) => const TextMealInputScreen(),
      ),
    ],
  );
});
