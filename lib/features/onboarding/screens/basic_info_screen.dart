import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/templates/standard_page_layout.dart';
import '../../../design_system/atoms/tonton_button.dart';
import '../../../design_system/atoms/tonton_labeled_text_field.dart';
import '../../../routes/router.dart';
import '../../../providers/providers.dart';

class BasicInfoScreen extends ConsumerStatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedGender;
  String? _selectedAgeGroup;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // テキストフィールドの変更を監視
    _nicknameController.addListener(_updateFormState);
    _weightController.addListener(_updateFormState);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _updateFormState() {
    // フォームの状態が変更されたらUIを更新
    setState(() {});
  }

  bool get _isFormValid {
    // ニックネームのみ必須、体重は任意
    return _nicknameController.text.isNotEmpty;
  }

  Future<void> _saveAndContinue() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      try {
        // ニックネームの保存
        if (_nicknameController.text.isNotEmpty) {
          await ref
              .read(userProfileProvider.notifier)
              .updateDisplayName(_nicknameController.text);
          if (!mounted) return;
        }

        // 体重の保存
        if (_weightController.text.isNotEmpty) {
          final weight = double.tryParse(_weightController.text);
          if (weight != null) {
            await ref.read(userProfileProvider.notifier).updateWeight(weight);
            if (!mounted) return;
          }
        }

        // 性別と年齢層の保存
        if (_selectedGender != null) {
          await ref
              .read(userProfileProvider.notifier)
              .updateGender(_selectedGender!);
          if (!mounted) return;
        }

        if (_selectedAgeGroup != null) {
          await ref
              .read(userProfileProvider.notifier)
              .updateAgeGroup(_selectedAgeGroup!);
          if (!mounted) return;
        }

        // オンボーディングを完了させる（両方のフラグを同期）
        // UserProfileのonboardingCompletedフラグを設定
        await ref.read(userProfileProvider.notifier).completeOnboarding();
        if (!mounted) return;

        // OnboardingCompletionProviderのフラグも設定
        await ref.read(onboardingCompletedProvider.notifier).complete();
        if (!mounted) return;

        // OnboardingServiceも完了させる
        final service = ref.read(onboardingServiceProvider);
        await service.completeOnboarding();
        if (!mounted) return;

        // デフォルトの開始日を設定
        if (ref.read(onboardingStartDateProvider) == null) {
          await ref.read(onboardingStartDateProvider.notifier).setDate(DateTime.now());
        }

        // 次の画面へ遷移（暫定的に直接ホーム画面へ）
        if (mounted) {
          // Give a small delay to ensure state propagation
          await Future.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;

          // Force reload of completion providers to ensure they reflect the saved state
          await ref.read(onboardingCompletedProvider.notifier).reload();
          if (!mounted) return;

          context.go(TontonRoutes.home);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StandardPageLayout(
          children: [
            const SizedBox(height: 40),
            // プログレスインジケーター
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            Text('プロフィール設定', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'あなたに合った目標を設定します',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ニックネーム入力
                  LabeledTextField(
                    label: 'ニックネーム（必須）',
                    controller: _nicknameController,
                    hintText: '例：トントン',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ニックネームを入力してください';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 体重入力
                  LabeledTextField(
                    label: '体重（任意）',
                    controller: _weightController,
                    hintText: '例：60.5',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      // 体重は任意項目なので、入力がある場合のみバリデーション
                      if (value != null && value.isNotEmpty) {
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0 || weight > 300) {
                          return '正しい体重を入力してください';
                        }
                      }
                      return null;
                    },
                    suffixIcon: Text(
                      'kg',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 性別選択
                  Text(
                    '性別（任意）',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'male', label: Text('男性')),
                      ButtonSegment(value: 'female', label: Text('女性')),
                    ],
                    selected: _selectedGender != null ? {_selectedGender!} : {},
                    emptySelectionAllowed: true,
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedGender =
                            newSelection.isEmpty ? null : newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // 年齢層選択
                  Text(
                    '体の変化（任意）',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<String>(
                    title: const Text('若い頃と変わらない'),
                    value: 'young',
                    groupValue: _selectedAgeGroup,
                    onChanged: (value) {
                      setState(() {
                        _selectedAgeGroup = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: const Text('脂肪が増えやすくなった'),
                    value: 'middle',
                    groupValue: _selectedAgeGroup,
                    onChanged: (value) {
                      setState(() {
                        _selectedAgeGroup = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    title: const Text('健康が気になってきた'),
                    value: 'senior',
                    groupValue: _selectedAgeGroup,
                    onChanged: (value) {
                      setState(() {
                        _selectedAgeGroup = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: TontonButton.primary(
                label: _isLoading ? '保存中...' : '次へ',
                onPressed:
                    _isFormValid && !_isLoading ? _saveAndContinue : null,
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
