import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/templates/standard_page_layout.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../providers/providers.dart';
import '../../../routes/app_page.dart';
import '../../../routes/router.dart';
import '../../onboarding/providers/onboarding_providers.dart';
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
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // フォーカス状態の変更を監視
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // キーボードを閉じる
    _focusNode.unfocus();

    final weight = double.tryParse(_controller.text);
    if (weight != null) {
      await ref.read(userWeightProvider.notifier).setWeight(weight);

      // オンボーディング中の場合は完了処理を実行
      final isOnboarding =
          ModalRoute.of(context)?.settings.name?.contains('onboarding') ??
          false;
      if (isOnboarding) {
        await ref.read(onboardingServiceProvider).completeOnboarding();
        // オンボーディング完了状態を更新
        ref.invalidate(onboardingCompletedProvider);
      }
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

    return GestureDetector(
      onTap: () {
        // 画面タップでキーボードを閉じる
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('体重入力')),
        body: StandardPageLayout(
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: '体重 (kg)',
                suffixIcon:
                    _focusNode.hasFocus
                        ? IconButton(
                          icon: const Icon(Icons.done),
                          onPressed: () {
                            _focusNode.unfocus();
                          },
                        )
                        : null,
              ),
              onSubmitted: (_) => _save(),
              // iOS用のキーボードツールバー
              inputFormatters: [
                // 数字と小数点のみ許可
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
              ],
            ),
            const SizedBox(height: 24),
            TontonButton.primary(label: '保存', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
