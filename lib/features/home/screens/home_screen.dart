import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../theme/colors.dart';
import '../../../theme/app_theme.dart' as app_theme;
import '../../../design_system/organisms/hero_piggy_bank_display.dart';
import '../../../design_system/organisms/calorie_summary_row.dart';
import '../../../design_system/molecules/pfc_bar_display.dart';
import '../../../widgets/todays_meal_records_list.dart';
import '../../../widgets/ai_advice_card_compact.dart';
import '../../../routes/router.dart';

/// Main home screen matching .pen HomeScreen design
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'おはようございます！';
    if (hour < 18) return 'こんにちは！';
    return 'こんばんは！';
  }

  String _displayName(User? user) {
    final meta = user?.userMetadata ?? {};
    final name = meta['full_name'] ?? meta['name'] ?? meta['username'];
    if (name is String && name.isNotEmpty) return name;
    final email = user?.email ?? '';
    return email.split('@').first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final todayMeals = ref.watch(todaysMealRecordsProvider);

    final greeting = _greetingFor(DateTime.now());
    final userName = _displayName(user);

    // Calculate PFC for the PFC section
    final protein = todayMeals.fold<double>(0, (s, m) => s + m.protein);
    final fat = todayMeals.fold<double>(0, (s, m) => s + m.fat);
    final carbs = todayMeals.fold<double>(0, (s, m) => s + m.carbs);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

              // Header: greeting + username | bell button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          color: app_theme.TontonColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userName,
                        style: TextStyle(
                          color: app_theme.TontonColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  // Bell icon button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: TontonColors.shadowSubtle,
                          offset: Offset(0, 1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: app_theme.TontonColors.textPrimary,
                        size: 22,
                      ),
                      onPressed: () {
                        // TODO: notifications
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // CalorieSavingsHero
              const HeroPiggyBankDisplay(),
              const SizedBox(height: 20),

              // Summary section
              _SectionHeader(title: '今日のサマリー'),
              const SizedBox(height: 12),
              const CalorieSummaryRow(),
              const SizedBox(height: 20),

              // PFC Balance section
              _SectionHeader(title: 'PFCバランス'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: TontonColors.shadowSubtle,
                      offset: Offset(0, 2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: PfcBarDisplay(
                  title: '',
                  protein: protein,
                  fat: fat,
                  carbs: carbs,
                ),
              ),
              const SizedBox(height: 20),

              // Meals section
              _SectionHeader(
                title: '今日の食事',
                actionText: 'すべて見る',
                onAction: () => context.push(TontonRoutes.progress),
              ),
              const SizedBox(height: 12),
              const _MealsList(),
              const SizedBox(height: 20),

              // AI Advice section
              _SectionHeader(title: 'AIアドバイス', actionText: 'もっと見る'),
              const SizedBox(height: 12),
              const AiAdviceCardCompact(),
              const SizedBox(height: 20),
            ],
          ),
        );
  }
}

/// Section header matching .pen SectionHeader component
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: app_theme.TontonColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: TextStyle(
                color: TontonColors.pigPink,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Meals list without its own header (handled by HomeScreen SectionHeader)
class _MealsList extends ConsumerWidget {
  const _MealsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const TodaysMealRecordsList();
  }
}
