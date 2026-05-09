/// 8 つの「挫折パターン辞典」エントリ。
///
/// すべてのテンプレ文言は事前審査済みの一般情報。LLM やルールベース判定は
/// **どのパターンに当てはまるか**だけを返し、自然文のフリー生成は行わない。
/// これにより App Store Review Guideline 1.4.1 の「個別の医療/健康アドバイス」
/// 判定を回避する。
enum DietaryPatternId {
  smooth(1), // ① 順調
  bodyStall(2), // ② 体側で停滞 (理論↓ 実測→)
  foodDrift(3), // ③ 食事側で逸脱 (理論→ 実測→)
  rebound(4), // ④ 食べすぎリバウンド (理論↑ 実測↑)
  whoosh(5), // ⑤ Whoosh 効果 (停滞 → 突然降下)
  zigzag(6), // ⑥ ホルモン周期/ジグザグ
  initialWaterShed(7), // ⑦ 初期の水分抜け
  saltSpike(8); // ⑧ 連休の塩分スパイク

  final int id;
  const DietaryPatternId(this.id);

  static DietaryPatternId fromId(int id) {
    return DietaryPatternId.values.firstWhere(
      (p) => p.id == id,
      orElse: () => DietaryPatternId.smooth,
    );
  }
}

/// 1 つの辞典エントリ。
///
/// すべてのテキストはアプリ側で固定 (LLM 生成ではない)。
/// 「一般的に〜と言われている」など断定を避ける書き方で App Store-safe。
class DietaryPatternEntry {
  /// 識別子。
  final DietaryPatternId id;

  /// 表示順インデックス (① ② のような番号)。
  final int displayOrder;

  /// 表示名 (短く、辞典っぽく)。
  final String name;

  /// 1 行サマリ (チャート/カードに添える)。
  final String shortLabel;

  /// 状況の客観記述 (1-2 文)。「一般に〜と言われている」フレームで書く。
  final String generalDescription;

  /// 一般的に知られている対処/解釈の選択肢 (3-4 個、1 行ずつ)。
  /// 命令形を避け「〜と紹介されている」「〜と言われている」で締める。
  final List<String> generalKnowledge;

  /// 自己振り返り用の問いかけ (2-3 個、疑問形)。
  /// AI が「指示」する代わりにユーザーが自分で考えるきっかけを提供する。
  final List<String> reflectionPrompts;

  const DietaryPatternEntry({
    required this.id,
    required this.displayOrder,
    required this.name,
    required this.shortLabel,
    required this.generalDescription,
    required this.generalKnowledge,
    required this.reflectionPrompts,
  });
}

/// 8 パターンの辞典本体。
class DietaryPatternDictionary {
  DietaryPatternDictionary._();

  static const Map<DietaryPatternId, DietaryPatternEntry> entries = {
    DietaryPatternId.smooth: DietaryPatternEntry(
      id: DietaryPatternId.smooth,
      displayOrder: 1,
      name: '① 順調',
      shortLabel: '理論↓ 実測↓',
      generalDescription:
          '計画・理論・実測の 3 線がほぼ重なる状態として一般に紹介されているパターンです。'
          '食事ログと体重ログの整合がとれている期間と言われています。',
      generalKnowledge: [
        '食事の量と運動量がうまく噛み合っている期間と紹介されている',
        '中長期で見てこの状態を続けることが大事と言われている',
        '次の中間チェック時に振り返ることが推奨されている',
      ],
      reflectionPrompts: [
        'この期間うまくいった食事/運動の習慣を記録しておきますか？',
        '次の 2 週間も同じ生活リズムを保てそうですか？',
      ],
    ),
    DietaryPatternId.bodyStall: DietaryPatternEntry(
      id: DietaryPatternId.bodyStall,
      displayOrder: 2,
      name: '② 体側で停滞',
      shortLabel: '理論↓ 実測→',
      generalDescription:
          '食事ログ上は計画通り (理論線が下降中) ですが、実測体重が動きにくい期間。'
          '一般に水分・グリコーゲン・ホルモン周期などが背景にあると言われています。',
      generalKnowledge: [
        '体重が一時的に動かない期間は珍しくないと一般に言われている',
        '塩分・睡眠・水分が体重変動に影響すると紹介されている',
        '理論線がトレンドの目安として使われることが多い',
        '数日〜1 週間で平準化するケースが多いと紹介されている',
      ],
      reflectionPrompts: [
        '最近、塩分が多い食事や睡眠不足はありましたか？',
        '体重で一喜一憂せず、もう 1 週間続けてみますか？',
      ],
    ),
    DietaryPatternId.foodDrift: DietaryPatternEntry(
      id: DietaryPatternId.foodDrift,
      displayOrder: 3,
      name: '③ 食事側で逸脱',
      shortLabel: '理論→ 実測→',
      generalDescription:
          '理論線が計画から離れていて、実測もこれに追従している状態。'
          '食事ログ上のカロリー赤字が小さくなっている期間と言われています。',
      generalKnowledge: [
        '食事の量や記録漏れが背景にあるケースが多いと紹介されている',
        '写真ログでの記録の取り直しが選択肢として知られている',
        '間食やドリンクの記録漏れは典型的と言われている',
      ],
      reflectionPrompts: [
        '最近の食事スタイルや忙しさで変わったことはありますか？',
        '記録から漏れている間食やドリンクはありませんか？',
      ],
    ),
    DietaryPatternId.rebound: DietaryPatternEntry(
      id: DietaryPatternId.rebound,
      displayOrder: 4,
      name: '④ 食べすぎリバウンド',
      shortLabel: '理論↑ 実測↑',
      generalDescription:
          '理論線も実測も上向きで一致している状態。'
          'カロリー摂取が消費を上回り、体重も追従していると一般に言われています。',
      generalKnowledge: [
        '理論と実測が一致して上向きの場合、食事量の見直しが選択肢と紹介されている',
        '一時的なイベント (旅行・連休) で発生することが多い',
        '次の 1 週間で立て直すケースが一般的と言われている',
      ],
      reflectionPrompts: [
        '最近のイベント (旅行・外食・飲み会) で食事量が増えましたか？',
        '次の 1 週間で計画ペースに戻すスケジュールを立てますか？',
      ],
    ),
    DietaryPatternId.whoosh: DietaryPatternEntry(
      id: DietaryPatternId.whoosh,
      displayOrder: 5,
      name: '⑤ Whoosh',
      shortLabel: '停滞 → 突然降下',
      generalDescription:
          '実測体重が長期間動かなかった後、急に減少して理論線に追いつく現象。'
          '一般に Lyle McDonald 仮説として知られています。',
      generalKnowledge: [
        '低カロリー期間に脂肪細胞の水分が抜ける現象として紹介されている',
        '停滞中も食事を継続したケースで起きやすいと言われている',
        '理論線が steady なら諦めない判断材料になると紹介されている',
      ],
      reflectionPrompts: [
        '停滞期間中も食事ログを続けられましたか？',
        '停滞のあとの急降下を脂肪減と勘違いしないよう注意しますか？',
      ],
    ),
    DietaryPatternId.zigzag: DietaryPatternEntry(
      id: DietaryPatternId.zigzag,
      displayOrder: 6,
      name: '⑥ ジグザグ',
      shortLabel: '実測 ジグザグ',
      generalDescription:
          '実測体重が短期間で大きく上下する状態。一般にホルモン周期・水分・'
          'グリコーゲン保持などが背景にあると言われています。',
      generalKnowledge: [
        '体重が周期的に上下するのは一般的と紹介されている',
        '理論線をトレンドの目安にする使い方が紹介されている',
        '塩分を一時的に減らすと数日で平準化することが多いと言われている',
      ],
      reflectionPrompts: [
        '体重で一喜一憂せず、理論線を真の進捗として見られますか？',
        '生活リズムや塩分量に変化はありましたか？',
      ],
    ),
    DietaryPatternId.initialWaterShed: DietaryPatternEntry(
      id: DietaryPatternId.initialWaterShed,
      displayOrder: 7,
      name: '⑦ 初期の水分抜け',
      shortLabel: '初週 急降下 → 停滞',
      generalDescription:
          '開始直後に実測が大きく下がり、その後数週間 plateau (停滞) に入る状態。'
          '一般にグリコーゲン枯渇に伴う水分減と言われています。',
      generalKnowledge: [
        '糖質制限/低カロリー開始時に起きやすいと紹介されている',
        '初週の急減は脂肪減ではなく水分減のことが多いと言われている',
        '第 2 週以降の停滞を「失敗」と誤認しない判断材料になる',
      ],
      reflectionPrompts: [
        '初週の急降下を「順調すぎる」と感じませんでしたか？',
        '第 2 週からの停滞を理論線で評価できそうですか？',
      ],
    ),
    DietaryPatternId.saltSpike: DietaryPatternEntry(
      id: DietaryPatternId.saltSpike,
      displayOrder: 8,
      name: '⑧ 塩分スパイク',
      shortLabel: '短期 +2kg → 1 週で戻る',
      generalDescription:
          '数日の高塩分・高糖質摂取で実測が急上昇し、その後 1 週ほどで戻る状態。'
          '一般にナトリウム + 糖質に伴う水分保持と言われています。',
      generalKnowledge: [
        '旅行・外食・寿司などのあと出やすいと紹介されている',
        'ピーク時の体重と理論線の差は水分が中心と言われている',
        '通常 3〜7 日で平準化することが多いと紹介されている',
      ],
      reflectionPrompts: [
        '直近に外食/旅行/外飲みなどはありましたか？',
        'ピーク時の +N kg を「太った」と思わず水分と捉えられますか？',
      ],
    ),
  };

  static DietaryPatternEntry get(DietaryPatternId id) =>
      entries[id] ?? entries[DietaryPatternId.smooth]!;
}
