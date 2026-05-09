/// LLM が生成したパターン解説。テンプレ ([DietaryPatternEntry]) を
/// パーソナライズ paraphrase した結果。
///
/// LLM 出力は構造化フィールドのみ。System prompt で:
///   - 医療アドバイス禁止
///   - 「〜すべき」「〜しなさい」など指示形禁止
///   - データ観察 + 一般知識の言い換え + 親しみあるトーンに限定
/// と縛る。失敗時はテンプレ ([DietaryPatternEntry]) にフォールバックする想定。
class PatternNarrative {
  /// 状況のフレンドリーな観察文 (100-150 文字、user の具体数値を含む)。
  final String description;

  /// 一般知識の bullet (2-3 個、命令形不可、「〜と紹介されている」など中立フレーズ)。
  final List<String> knowledgeBullets;

  /// 振り返りプロンプト (1-2 個、ユーザーデータに即した疑問形)。
  final List<String> reflectionPrompts;

  const PatternNarrative({
    required this.description,
    required this.knowledgeBullets,
    required this.reflectionPrompts,
  });

  factory PatternNarrative.fromJson(Map<String, dynamic> json) {
    final knowledgeRaw = json['knowledgeBullets'] as List?;
    final reflectionRaw = json['reflectionPrompts'] as List?;
    return PatternNarrative(
      description: (json['description'] as String?)?.trim() ?? '',
      knowledgeBullets: knowledgeRaw == null
          ? const []
          : knowledgeRaw.whereType<String>().toList(),
      reflectionPrompts: reflectionRaw == null
          ? const []
          : reflectionRaw.whereType<String>().toList(),
    );
  }

  bool get isEmpty =>
      description.isEmpty && knowledgeBullets.isEmpty && reflectionPrompts.isEmpty;
}
