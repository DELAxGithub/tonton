import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/templates/standard_page_layout.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../providers/providers.dart';
import '../../../routes/app_page.dart';
import '../../../routes/router.dart';
import 'package:go_router/go_router.dart';

class WeightInputScreen extends ConsumerStatefulWidget implements AppPage {
  const WeightInputScreen({super.key});

  @override
  ConsumerState<WeightInputScreen> createState() => _WeightInputScreenState();

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(title: const Text('体重入力'));
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) => null;
}

class _WeightInputScreenState extends ConsumerState<WeightInputScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final weight = double.tryParse(_controller.text);
    if (weight != null) {
      await ref.read(userWeightProvider.notifier).setWeight(weight);
    }
    if (mounted) {
      context.go(TontonRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existing = ref.watch(userWeightProvider);
    if (existing != null && _controller.text.isEmpty) {
      _controller.text = existing.toString();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('体重入力')),
      body: StandardPageLayout(
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '体重 (kg)'),
          ),
          const SizedBox(height: 24),
          TontonButton.primary(
            label: '保存',
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
