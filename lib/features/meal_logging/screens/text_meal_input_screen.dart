import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/ai_estimation_provider.dart';
import '../../../routes/router.dart';
import '../../../theme/colors.dart';

/// テキスト入力から食事を記録する画面
/// テキスト → Gemini AI栄養推定 → 確認・編集画面（Step3再利用）
class TextMealInputScreen extends ConsumerStatefulWidget {
  const TextMealInputScreen({super.key});

  @override
  ConsumerState<TextMealInputScreen> createState() =>
      _TextMealInputScreenState();
}

class _TextMealInputScreenState extends ConsumerState<TextMealInputScreen> {
  final _controller = TextEditingController();
  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await ref
          .read(aiEstimationProvider.notifier)
          .estimateNutritionFromText(text)
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (result != null) {
        context.push(
          TontonRoutes.aiMealConfirm,
          extra: {'nutrition': result},
        );
      } else {
        setState(() {
          _errorMessage = '栄養情報を推定できませんでした。もう少し詳しく入力してみてください。';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '分析に失敗しました: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('テキストで記録'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '食べたものを入力',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '料理名や食材、量を入力するとAIが栄養素を推定します',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // テキスト入力
              TextField(
                controller: _controller,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: '例: 鶏胸肉 200g、ご飯 150g、味噌汁',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerLowest,
                ),
                onSubmitted: (_) => _analyze(),
              ),

              // エラーメッセージ
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 入力例
              Text(
                '入力のコツ',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildTip('量を書くと精度UP', '「サラダチキン 1個」「ご飯 大盛り」'),
              _buildTip('複数品OK', '「カレーライス、サラダ、コーヒー」'),
              _buildTip('お店の名前もOK', '「松屋の牛丼 並盛」'),

              const Spacer(),

              // 分析ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isAnalyzing || _controller.text.trim().isEmpty
                      ? null
                      : _analyze,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isAnalyzing ? 'AIが分析中...' : 'AIで栄養を推定'),
                  style: FilledButton.styleFrom(
                    backgroundColor: TontonColors.pigPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String title, String example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: TontonColors.pigPink.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '$title  ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: example,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
