import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../design_system/templates/standard_page_layout.dart';
import '../../../design_system/organisms/hero_piggy_bank_display.dart';
import '../../../design_system/organisms/calorie_summary_row.dart';
import '../../../design_system/organisms/pfc_balance_card.dart';
import '../../../widgets/todays_meal_records_list.dart';
import '../../../widgets/ai_advice_card_compact.dart';
import '../../../theme/tokens.dart';
import '../../../routes/router.dart';

/// Main home screen of the app
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'おはよう';
    if (hour < 18) return 'こんにちは';
    return 'こんばんは';
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


    final dailySummaryAsync = ref.watch(todayCalorieSummaryProvider);

    final greeting = _greetingFor(DateTime.now());
    final userName = _displayName(user);

    return dailySummaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (summary) {
        return Scaffold(
          body: StandardPageLayout(
            children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Text(
                '$greeting、$userName',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const HeroPiggyBankDisplay(),
            const SizedBox(height: Spacing.xl),
            const CalorieSummaryRow(),
            const SizedBox(height: Spacing.md),
            const PfcBalanceCard(),
            const SizedBox(height: Spacing.xl),
            const AiAdviceCardCompact(),
            const SizedBox(height: Spacing.xl),
            const TodaysMealRecordsList(),
            const SizedBox(height: Spacing.xxl),
          ],
          ),
          floatingActionButton: FloatingActionButton.large(
            onPressed: () => context.push(TontonRoutes.aiMealCamera),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Icons.add,
              size: 36,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

}