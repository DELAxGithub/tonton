import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../routes/app_page.dart';
import '../routes/router.dart';
import '../design_system/templates/standard_page_layout.dart';
import 'package:go_router/go_router.dart';

class InsightsScreen extends ConsumerWidget implements AppPage {
  const InsightsScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(title: Text(l10n.tabInsights));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return StandardPageLayout(
      children: [
        Center(child: Text(l10n.tabInsights)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context.push(TontonRoutes.progressAchievements),
          child: const Text('View Progress'),
        ),
      ],
    );
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) => null;
}
