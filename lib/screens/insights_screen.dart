import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../routes/app_page.dart';

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
    return Center(child: Text(l10n.tabInsights));
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) => null;
}
