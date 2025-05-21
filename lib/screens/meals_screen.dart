import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../routes/app_page.dart';
import '../routes/router.dart';
import '../utils/icon_mapper.dart';

class MealsScreen extends ConsumerWidget implements AppPage {
  const MealsScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(title: Text(l10n.tabMeals));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Center(child: Text(l10n.tabMeals));
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.pushNamed('addMeal'),
      tooltip: AppLocalizations.of(context).addMeal,
      child: Icon(TontonIcons.add),
    );
  }
}
