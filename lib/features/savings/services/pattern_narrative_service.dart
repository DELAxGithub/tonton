import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/dietary_pattern.dart';
import '../models/pattern_narrative.dart';
import 'pattern_matching_service.dart';

/// 「ガード付き LLM 文章生成」レイヤー。
///
/// 入力: 決定論的に分類済みの [PatternMatchResult] + 該当パターンの
/// 事前審査済みテンプレ ([DietaryPatternEntry]) + ユーザーの数値サマリ。
///
/// 出力: パーソナライズされた [PatternNarrative]。
///
/// **設計の要点:**
/// - パターン分類は LLM ではなくルールベース ([PatternMatchingService]) が担当。
///   LLM は文章の paraphrase + 数値言及だけ任せる。
/// - System prompt で「医療アドバイス禁止 / 指示形禁止 / データ観察 + 一般知識
///   の言い換えに限定」を強制。
/// - 失敗時はテンプレで埋めるフォールバック (UI 側で実装)。
class PatternNarrativeService {
  static String? _apiKey;

  static String get _key {
    if (_apiKey != null) return _apiKey!;
    final k = dotenv.env['GEMINI_API_KEY'];
    if (k == null || k.isEmpty) {
      throw Exception('GEMINI_API_KEY is not set in .env');
    }
    _apiKey = k;
    return k;
  }

  static Future<PatternNarrative> generate({
    required PatternMatchResult result,
    required DietaryPatternEntry templateEntry,
    required String summaryStats,
  }) async {
    final prompt = _buildPrompt(
      result: result,
      template: templateEntry,
      summaryStats: summaryStats,
    );

    developer.log(
      'Calling Gemini for pattern narrative (pattern=${templateEntry.id})',
      name: 'TonTon.PatternNarrativeService',
    );

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _key);
    final response = await model.generateContent([Content.text(prompt)]);
    final raw = response.text ?? '';

    return _parse(raw);
  }

  static String _buildPrompt({
    required PatternMatchResult result,
    required DietaryPatternEntry template,
    required String summaryStats,
  }) {
    final knowledgeJoined = template.generalKnowledge
        .map((k) => '- $k')
        .join('\n');
    final reflectionJoined = template.reflectionPrompts
        .map((p) => '- $p')
        .join('\n');

    return '''
あなたは体重トレンドを観察するフレンドリーなコーチです。
医療アドバイスや個別の健康上の指示はせず、データの観察と一般情報の親しみやすい
言い換えだけを行います。

# 役割の制約 (絶対に守る)
- 「〜してください」「〜すべき」「〜しなさい」など指示形は禁止
- 医療診断・治療法・薬・サプリ・栄養素処方は触れない
- データの客観観察 + 一般的に知られていることの言い換えに留める
- ポジティブな励ましは可。ただし結果を保証しない
- 100% 日本語、絵文字は description に最大 1 個までなら可

# このユーザーの判定
パターン: ${template.name} (${template.shortLabel})
類似度: ${(result.similarity * 100).round()}%

# 辞典の元エントリ (これを paraphrase する)
[一般説明]
${template.generalDescription}

[一般的に知られていること]
$knowledgeJoined

[振り返りプロンプト案]
$reflectionJoined

# ユーザーのデータ
$summaryStats

# 出力フォーマット (JSON のみ、説明文や ``` は不要)
{
  "description": "100-150 文字。ユーザー数値を最低 1 つ言及した親しみあるトーンの観察文。元説明の paraphrase で良いが、新鮮さを出す。",
  "knowledgeBullets": ["...", "..."],
  "reflectionPrompts": ["...?", "...?"]
}

要件詳細:
- description: 100-150 文字、必ず数値 (例 "-1.5kg", "±0.8kg", "30日") を 1 つ以上入れる
- knowledgeBullets: 2-3 個、辞典 entry の paraphrase で OK、命令形避け「〜と紹介されている」「〜と知られている」で締める
- reflectionPrompts: 1-2 個、必ず疑問形、可能ならユーザーデータに即した具体性
''';
  }

  static PatternNarrative _parse(String raw) {
    if (raw.isEmpty) {
      return const PatternNarrative(
        description: '',
        knowledgeBullets: [],
        reflectionPrompts: [],
      );
    }
    var text = raw.trim();
    if (text.startsWith('```')) {
      final lines = text.split('\n');
      if (lines.length >= 3) {
        text = lines.sublist(1, lines.length - 1).join('\n');
      }
    }
    try {
      final json = jsonDecode(text) as Map<String, dynamic>;
      return PatternNarrative.fromJson(json);
    } catch (e, st) {
      developer.log(
        'Failed to parse pattern narrative JSON: $e',
        name: 'TonTon.PatternNarrativeService',
        error: e,
        stackTrace: st,
      );
      return const PatternNarrative(
        description: '',
        knowledgeBullets: [],
        reflectionPrompts: [],
      );
    }
  }
}
