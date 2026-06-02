import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/reward_suggestion.dart';

/// 「今月の余白 kcal」を context に渡して、AI が一般的な食事候補を 4 件提案する。
/// 出力は構造化 JSON のみ・自然文の医療/個別アドバイスは含まない。
///
/// 既存 `DirectGeminiService` と同じ `gemini-2.5-flash` を使用。
class RewardSuggestionService {
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

  /// [budgetKcal] kcal 以内の食事候補を 4 件取得する。
  ///
  /// [recentMealNames] と [monthlyAchievementPercent] は context として渡される
  /// (なくても動く)。LLM が「最近食べてないジャンル」「PFC 偏り補正」を
  /// 軽く考慮できるようにするための情報のみ。
  static Future<List<RewardSuggestion>> suggest({
    required int budgetKcal,
    List<String> recentMealNames = const [],
    int? monthlyAchievementPercent,
  }) async {
    final prompt = _buildPrompt(
      budgetKcal: budgetKcal,
      recentMealNames: recentMealNames,
      monthlyAchievementPercent: monthlyAchievementPercent,
    );

    developer.log(
      'Calling Gemini for food suggestions (budget=$budgetKcal kcal)',
      name: 'TonTon.RewardSuggestionService',
    );

    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _key);
    final response = await model.generateContent([Content.text(prompt)]);
    final raw = response.text ?? '';

    return _parse(raw);
  }

  static String _buildPrompt({
    required int budgetKcal,
    required List<String> recentMealNames,
    int? monthlyAchievementPercent,
  }) {
    final mealsLine =
        recentMealNames.isEmpty ? '(未提供)' : recentMealNames.take(20).join(', ');
    final achLine =
        monthlyAchievementPercent == null
            ? '(未提供)'
            : '$monthlyAchievementPercent%';

    return '''
あなたは食事候補をリストアップするアシスタントです。
ユーザーがダイエット中に無理なく楽しめる「余白」として kcal 目安が決まっています。
その予算 ($budgetKcal kcal) 以内に収まる、一般的に知られている食品/メニューを 4 件提案してください。

参考情報:
- 直近の食事履歴: $mealsLine
- 月次目標達成度: $achLine

要件:
- 4 件提案する
- 単品で完結するもの (例: "ティラミス 1 個", "唐揚げ 4 個")
- カロリーは整数で見積もる (実食で前後しても良い)
- reason は「過去履歴を踏まえると〜」「PFC 的に〜」のような客観的な根拠を 1 行
- 医療アドバイスや具体的な健康上の助言は含めない
- 命令形を避け「〜と紹介されている」「〜と整合する」など中立な書き方

応答は以下の JSON 形式で厳密に出力してください。説明文や ``` は不要、JSON のみ:

{
  "suggestions": [
    {
      "emoji": "🍰",
      "name": "ティラミス 1 個",
      "kcal": 320,
      "reason": "今週はタンパク質が十分なため糖質枠に余裕がある"
    }
  ]
}
''';
  }

  static List<RewardSuggestion> _parse(String raw) {
    if (raw.isEmpty) return const [];
    // Strip code fences if any.
    var text = raw.trim();
    if (text.startsWith('```')) {
      // Remove first/last fence lines.
      final lines = text.split('\n');
      if (lines.length >= 3) {
        text = lines.sublist(1, lines.length - 1).join('\n');
      }
    }
    try {
      final json = jsonDecode(text) as Map<String, dynamic>;
      final list = (json['suggestions'] as List?) ?? const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(RewardSuggestion.fromJson)
          .toList();
    } catch (e, st) {
      developer.log(
        'Failed to parse reward suggestions JSON: $e',
        name: 'TonTon.RewardSuggestionService',
        error: e,
        stackTrace: st,
      );
      return const [];
    }
  }
}
