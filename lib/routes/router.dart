import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/home_screen_new.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/meal_input_screen_new.dart';
import '../screens/savings_trend_screen.dart';
import '../models/meal_record.dart';

/// Route names for named navigation
class TontonRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String addMeal = '/add-meal';
  static const String editMeal = '/edit-meal';
  static const String savingsTrend = '/savings-trend';
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
      // Home screen with tabs (ShellRoute for nested navigation)
      GoRoute(
        path: TontonRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreenNew(),
      ),
      
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
    ],
  );
});