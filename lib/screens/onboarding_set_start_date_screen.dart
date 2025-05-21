import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../design_system/templates/standard_page_layout.dart';
import '../design_system/atoms/tonton_button.dart';
import '../utils/icon_mapper.dart';
import '../routes/router.dart';

class OnboardingSetStartDateScreen extends ConsumerStatefulWidget {
  const OnboardingSetStartDateScreen({super.key});

  @override
  ConsumerState<OnboardingSetStartDateScreen> createState() =>
      _OnboardingSetStartDateScreenState();
}

enum _StartDateOption { firstMeal, specific }

class _OnboardingSetStartDateScreenState
    extends ConsumerState<OnboardingSetStartDateScreen> {
  _StartDateOption _option = _StartDateOption.firstMeal;
  DateTime _selectedDate = DateTime.now();

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

  void _next() {
    // TODO: persist choice
    context.go(TontonRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('開始日設定')),
      body: StandardPageLayout(
        children: [
          const Text('いつから始める？'),
          RadioListTile<_StartDateOption>(
            value: _StartDateOption.firstMeal,
            groupValue: _option,
            title: const Text('はじめて食事を記録した日'),
            onChanged: (val) => setState(() => _option = val!),
          ),
          RadioListTile<_StartDateOption>(
            value: _StartDateOption.specific,
            groupValue: _option,
            title: const Text('特定の日付を選ぶ'),
            onChanged: (val) => setState(() => _option = val!),
          ),
          if (_option == _StartDateOption.specific)
            ListTile(
              leading: Icon(TontonIcons.calendar),
              title: const Text('開始日'),
              subtitle: Text(DateFormat.yMd().format(_selectedDate)),
              onTap: _pickDate,
            ),
          const SizedBox(height: 24),
          TontonButton.primary(
            label: 'これでOK！',
            onPressed: _next,
            leading: TontonIcons.arrow,
          ),
        ],
      ),
    );
  }
}
