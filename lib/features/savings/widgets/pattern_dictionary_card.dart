import 'package:flutter/material.dart';

import '../models/dietary_pattern.dart';
import '../models/pattern_narrative.dart';
import '../services/pattern_matching_service.dart';

/// 「挫折パターン辞典マッチング」カード。
///
/// 構成は二段:
/// 1. パターン分類はルールベース ([PatternMatchResult]) で決定論的に決まる。
/// 2. 表示文は LLM が paraphrase した [PatternNarrative] があれば優先、
///    なければテンプレ ([DietaryPatternEntry]) にフォールバック。
///
/// LLM は「観察 + 一般知識の言い換え」だけ担当 (system prompt でガード)。
/// 個別の医療/健康アドバイスは生成しない設計。
class PatternDictionaryCard extends StatelessWidget {
  final PatternMatchResult result;
  final PatternNarrative? narrative;
  final bool narrativeLoading;
  final VoidCallback? onRefresh;

  const PatternDictionaryCard({
    super.key,
    required this.result,
    this.narrative,
    this.narrativeLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final entry = DietaryPatternDictionary.get(result.patternId);
    final lowConfidence = result.similarity < 0.4;

    final lavenderBorder = const Color(0xFFDCC9F0);
    final lavenderText = const Color(0xFF6B4FB8);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5EDFF), Color(0xFFFFF0F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: lavenderBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー: 辞典バッジ + タイトル + (refresh)
          Row(
            children: [
              const Icon(Icons.search, size: 16, color: Color(0xFF6B4FB8)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '今日の状況',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, size: 18),
                  color: lavenderText,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // データ不足時はパターン詳細を出さず案内のみ
          if (lowConfidence) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                result.dataObservation,
                style: const TextStyle(fontSize: 12, height: 1.6),
              ),
            ),
          ] else ...[
            // パターン名 + 類似度 + (LLM 生成中インジケータ)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: lavenderBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: lavenderText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '類似度 ${(result.similarity * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B6469),
                        ),
                      ),
                    ],
                  ),
                ),
                if (narrativeLoading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // 概要 (narrative があれば LLM 文章、なければテンプレ)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (narrative != null && narrative!.description.isNotEmpty)
                        ? narrative!.description
                        : entry.generalDescription,
                    style: const TextStyle(fontSize: 12, height: 1.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.dataObservation,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 「📖 一般的に知られていること」 / 振り返りメモ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 こんなことが起きてる',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B6469),
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final knowledge in _knowledgeBullets(entry))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 16,
                            child: Text('・', style: TextStyle(height: 1.5)),
                          ),
                          Expanded(
                            child: Text(
                              knowledge,
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  const Text(
                    '💭 自分に問いかけ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B6469),
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final prompt in _reflectionBullets(entry))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 16,
                            child: Text('?', style: TextStyle(height: 1.5)),
                          ),
                          Expanded(
                            child: Text(
                              prompt,
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          // ディスクレーマー (App Store 安全側)
          Text(
            '※ 一般情報の提示です。医療判断は専門家にご相談ください。',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<String> _knowledgeBullets(DietaryPatternEntry entry) {
    if (narrative != null && narrative!.knowledgeBullets.isNotEmpty) {
      return narrative!.knowledgeBullets;
    }
    return entry.generalKnowledge;
  }

  List<String> _reflectionBullets(DietaryPatternEntry entry) {
    if (narrative != null && narrative!.reflectionPrompts.isNotEmpty) {
      return narrative!.reflectionPrompts;
    }
    return entry.reflectionPrompts;
  }
}
