import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/providers.dart';

class SavingsTrendScreen extends ConsumerWidget {
  const SavingsTrendScreen({super.key});

  // Previously this screen offered demo controls via a dropdown.
  // Those elements were removed, leaving only a simple list of savings data.

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsRecordsAsync = ref.watch(calorieSavingsDataProvider);
    return savingsRecordsAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (savingsRecords) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('カロリー貯金'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView.builder(
            itemCount: savingsRecords.length,
            itemBuilder: (context, index) {
              final record = savingsRecords[index];
              return ListTile(
                title: Text('${record.date.month}/${record.date.day}'),
                subtitle: Text(
                  '摂取: ${record.caloriesConsumed.toStringAsFixed(0)} kcal\n'
                  '消費: ${record.caloriesBurned.toStringAsFixed(0)} kcal',
                ),
                trailing: Text(
                  record.cumulativeSavings.toStringAsFixed(0),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
