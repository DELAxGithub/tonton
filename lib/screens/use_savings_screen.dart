import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/templates/standard_page_layout.dart';
import '../design_system/atoms/tonton_button.dart';
import '../utils/icon_mapper.dart';
import '../routes/router.dart';
import '../providers/savings_balance_provider.dart';

class UseSavingsScreen extends ConsumerStatefulWidget {
  const UseSavingsScreen({super.key});

  @override
  ConsumerState<UseSavingsScreen> createState() => _UseSavingsScreenState();
}

class _UseSavingsScreenState extends ConsumerState<UseSavingsScreen> {
  DateTime _selectedDate = DateTime.now();
  double _amountToUse = 0;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _confirm() async {
    await ref
        .read(savingsBalanceProvider.notifier)
        .deduct(_amountToUse.roundToDouble());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_amountToUse.round()} kcal を使いました')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ご褒美設定')),
      body: StandardPageLayout(
        children: [
          Consumer(
            builder: (context, ref, _) {
              final balance = ref.watch(savingsBalanceProvider).round();
              return Text(
                '使える貯金: $balance kcal',
                style: Theme.of(context).textTheme.titleMedium,
              );
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(TontonIcons.calendar),
            title: const Text('いつのご褒美にする？'),
            subtitle: Text(DateFormat.yMd().format(_selectedDate)),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          Text('いくら使う？ (${_amountToUse.round()} kcal)'),
          Slider(
            value: _amountToUse,
            onChanged: (v) => setState(() => _amountToUse = v),
            min: 0,
            max: 1000,
            divisions: 20,
          ),
          const SizedBox(height: 24),
          TontonButton.primary(
            label: 'この内容でご褒美を設定！',
            leading: TontonIcons.present,
            onPressed: _amountToUse > 0 ? _confirm : null,
          ),
        ],
      ),
    );
  }
}
