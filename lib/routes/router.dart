import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/home_screen_new.dart';
import '../screens/activity_screen.dart';
import '../screens/meals_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/meal_input_screen_new.dart';
import '../screens/savings_trend_screen.dart';
import '../screens/use_savings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/onboarding_set_start_date_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/progress_achievements_screen.dart';
import '../screens/ai_meal_logging/ai_meal_logging_step1_camera.dart';
import '../screens/ai_meal_logging/ai_meal_logging_step2_analyzing.dart';
import '../screens/ai_meal_logging/ai_meal_logging_step3_confirm_edit.dart';
import '../widgets/main_navigation_bar.dart';
import 'app_page.dart';
import '../models/meal_record.dart';
import 'dart:io';
import '../models/estimated_meal_nutrition.dart';

/// Route names for named navigation
class TontonRoutes {
  static const String home = '/';
  static const String activity = '/activity';
  static const String meals = '/meals';
  static const String insights = '/insights';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String addMeal = '/add-meal';
  static const String editMeal = '/edit-meal';
  static const String savingsTrend = '/savings-trend';
  static const String useSavings = '/use-savings';
  static const String onboardingStartDate = '/onboarding/start-date';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String progressAchievements = '/progress-achievements';
  static const String aiMealCamera = '/ai-meal/camera';
  static const String aiMealAnalyzing = '/ai-meal/analyzing';
  static const String aiMealConfirm = '/ai-meal/confirm';
}

/// Provider for the router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  
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
      
      // Determine if the user is going to an auth page
      final isAuthRoute = state.matchedLocation == TontonRoutes.login || 
                          state.matchedLocation == TontonRoutes.signup;
      
      // If the user is not logged in and trying to access a protected page
      if (!isLoggedIn && !isAuthRoute) {
        return TontonRoutes.login;
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
        path: TontonRoutes.onboardingStartDate,
        name: 'onboardingStartDate',
        builder: (context, state) => const OnboardingSetStartDateScreen(),
      ),

      // Shell route with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          final appBar = child is AppPage ? child.buildAppBar(context) : null;
          final fab = child is AppPage ? child.buildFloatingActionButton(context) : null;
          return AppShell(
            appBar: appBar,
            floatingActionButton: fab,
            bottomNavigationBar: MainNavigationBar(location: state.matchedLocation),
            body: child,
          );
        },
        routes: [
          GoRoute(
            path: TontonRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreenNew(),
          ),
          GoRoute(
            path: TontonRoutes.activity,
            name: 'activity',
            builder: (context, state) => const ActivityScreen(),
          ),
          GoRoute(
            path: TontonRoutes.meals,
            name: 'meals',
            builder: (context, state) => const MealsScreen(),
          ),
          GoRoute(
            path: TontonRoutes.insights,
            name: 'insights',
            builder: (context, state) => const InsightsScreen(),
          ),
        ],
      ),
      
      // Meal routes
      GoRoute(
        path: TontonRoutes.addMeal,
        name: 'addMeal',
        builder: (context, state) => const MealInputScreenNew(),
      ),
      GoRoute(
        path: TontonRoutes.editMeal,
        name: 'editMeal',
        builder: (context, state) {
          final MealRecord mealRecord = state.extra as MealRecord;
          return MealInputScreenNew(mealRecord: mealRecord);
        },
      ),
      
      // Savings trend route
      GoRoute(
        path: TontonRoutes.savingsTrend,
        name: 'savingsTrend',
        builder: (context, state) => const SavingsTrendScreen(),
      ),
      GoRoute(
        path: TontonRoutes.useSavings,
        name: 'useSavings',
        builder: (context, state) => const UseSavingsScreen(),
      ),

      // Profile route
      GoRoute(
        path: TontonRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: TontonRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: TontonRoutes.progressAchievements,
        name: 'progressAchievements',
        builder: (context, state) => const ProgressAchievementsScreen(),
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
          final File image = state.extra as File;
          return AIMealLoggingStep2Analyzing(imageFile: image);
        },
      ),
      GoRoute(
        path: TontonRoutes.aiMealConfirm,
        name: 'aiMealConfirm',
        builder: (context, state) {
          final Map extra = state.extra as Map;
          return AIMealLoggingStep3ConfirmEdit(
            imageFile: extra['image'] as File,
            nutrition: extra['nutrition'] as EstimatedMealNutrition,
          );
        },
      ),
    ],
  );
});
