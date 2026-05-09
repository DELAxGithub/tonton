/// AI に提案してもらった「ご褒美フード候補」1 件。
///
/// LLM 出力は構造化フィールドのみ。reason は「過去 30 日の傾向と整合する」という
/// 客観コメントを期待する (医療/個別健康アドバイスではなく食事候補の提示)。
class RewardSuggestion {
  /// 視覚的な絵文字 (LLM が出すか fallback から取る)。
  final String emoji;

  /// 食品/メニュー名 (例: ティラミス 1 個)。
  final String name;

  /// カロリー (kcal)。
  final int kcal;

  /// なぜこの候補なのかの 1-2 行説明 (例: "今週はタンパク質が十分で糖質枠に余裕")。
  final String reason;

  const RewardSuggestion({
    required this.emoji,
    required this.name,
    required this.kcal,
    required this.reason,
  });

  factory RewardSuggestion.fromJson(Map<String, dynamic> json) {
    return RewardSuggestion(
      emoji: (json['emoji'] as String?) ?? '🍴',
      name: (json['name'] as String?) ?? '名称不明',
      kcal: (json['kcal'] as num?)?.toInt() ?? 0,
      reason: (json['reason'] as String?) ?? '',
    );
  }
}
