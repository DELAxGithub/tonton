# トントン TODO リスト

**最終更新**: 2025年6月18日  
**対象バージョン**: v1.0.x - v1.1

---

## 🚨 **緊急対応（App Store審査前）**

### App Store提出要件
- [ ] **GitHub Pages設定**
  - [ ] リポジトリ設定でGitHub Pagesを有効化
  - [ ] ブランチ: app-store-clean
  - [ ] プライバシーポリシーURLアクセス確認: https://delaxgithub.github.io/tonton/privacy/
  - [ ] サポートページURLアクセス確認: https://delaxgithub.github.io/tonton/support/

- [ ] **デモアカウント準備**
  - [ ] reviewer@tonton-health.app のアカウント作成
  - [ ] サンプル食事データの入力（7日分程度）
  - [ ] 各機能の動作確認

- [ ] **スクリーンショット作成**
  - [ ] iPhone 6.9インチ (iPhone 16 Pro Max) - 必須
  - [ ] iPhone 6.7インチ (iPhone 16 Pro) - 必須
  - [ ] iPhone 6.5インチ (iPhone 16 Plus)
  - [ ] iPad 13インチ (iPad Pro)
  - [ ] iPad 12.9インチ (iPad Pro)

- [ ] **App Store Connect設定**
  - [ ] アプリ説明文の作成（日本語・英語）
  - [ ] キーワード設定
  - [ ] プライバシー情報の入力
  - [ ] 年齢制限の設定確認

---

## 🐛 **バグ修正・技術的負債**

### 高優先度
- [ ] **Weight History統合** (`lib/features/progress/screens/progress_achievements_screen.dart:51`)
  ```dart
  // TODO: Implement weight history fetching
  final weightRecords = List.generate(
    records.length,
    (index) => null as WeightRecord?,
  );
  ```

- [ ] **プロフィール画面の未実装UI** (`lib/features/profile/screens/profile_screen.dart`)
  - [ ] 年齢層選択UI（TODO: 年齢層選択UI）
  - [ ] 性別選択UI（TODO: 性別選択UI）
  - [ ] ログアウトボタン（TODO: ログアウトボタン）

### 中優先度
- [ ] **食事編集機能** (`lib/features/progress/screens/daily_meals_detail_screen.dart`)
  - [ ] Edit meal screen navigation の実装
  - [ ] 食事記録編集フローの完成

- [ ] **Undo機能** (`lib/widgets/todays_meal_records_list.dart`)
  - [ ] 食事削除のUndo機能実装

- [ ] **Import修正** (`lib/features/onboarding/screens/basic_info_screen.dart`)
  - [ ] Start date provider import の修正

### 低優先度
- [ ] **Deprecated画面の削除**
  - [ ] `tonton_coach_screen.dart` の削除
  - [ ] `home_screen_phase3.dart` の削除
  - [ ] 関連する未使用コードの整理

---

## 🎯 **新機能実装**

### v1.1 向け機能

#### プロフィール管理の完成
- [ ] **年齢層選択UI**
  ```dart
  // 実装場所: lib/features/profile/screens/profile_screen.dart
  DropdownButtonFormField<String>(
    decoration: const InputDecoration(
      labelText: '年齢層',
      border: OutlineInputBorder(),
    ),
    items: const [
      DropdownMenuItem(value: '20s', child: Text('20代')),
      DropdownMenuItem(value: '30s', child: Text('30代')),
      DropdownMenuItem(value: '40s', child: Text('40代')),
      DropdownMenuItem(value: '50s', child: Text('50代以上')),
    ],
    onChanged: (_) {},
  )
  ```

- [ ] **性別選択UI**
  ```dart
  // 実装場所: lib/features/profile/screens/profile_screen.dart
  SegmentedButton<String>(
    segments: const [
      ButtonSegment(value: 'male', label: Text('男性')),
      ButtonSegment(value: 'female', label: Text('女性')),
    ],
    selected: const {'male'},
    onSelectionChanged: (_) {},
  )
  ```

#### 食事管理の拡張
- [ ] **食事編集画面の実装**
  - [ ] カロリー調整機能
  - [ ] 食事時間変更機能
  - [ ] 食事名編集機能
  - [ ] 栄養素調整機能

- [ ] **お気に入り食事機能**
  - [ ] 食事のお気に入り登録
  - [ ] お気に入り一覧表示
  - [ ] クイック追加機能

#### データ可視化の改善
- [ ] **体重履歴チャート**
  - [ ] HealthKitからの体重データ取得
  - [ ] 体重推移グラフの実装
  - [ ] 目標体重設定機能

- [ ] **詳細分析画面**
  - [ ] 週次栄養バランス分析
  - [ ] 月次カロリー収支サマリー
  - [ ] トレンド分析機能

---

## 🔧 **技術的改善**

### パフォーマンス最適化
- [ ] **画像処理最適化**
  - [ ] クライアントサイド画像圧縮の実装
  - [ ] 遅延読み込み（Lazy Loading）の実装
  - [ ] 重複画像のキャッシュ機能

- [ ] **API最適化**
  - [ ] AI API レスポンス時間の改善
  - [ ] リクエスト失敗時のリトライ機能
  - [ ] オフラインモード対応の基礎実装

### コード品質向上
- [ ] **エラーハンドリング統一**
  - [ ] 共通エラー処理クラスの実装
  - [ ] ユーザーフレンドリーなエラーメッセージ
  - [ ] エラーログ収集システム

- [ ] **テスト強化**
  - [ ] 単体テストカバレッジ向上（目標80%）
  - [ ] 統合テストの追加
  - [ ] Widget テストの充実

---

## 📱 **UI/UX改善**

### オンボーディング改善
- [ ] **プロフィール設定ガイド**
  - [ ] 設定項目の説明追加
  - [ ] プログレスインジケーターの実装
  - [ ] スキップ機能の追加

### ナビゲーション改善
- [ ] **戻るボタンの統一**
  - [ ] 一貫したナビゲーション体験
  - [ ] ブレッドクラム表示

### アニメーション追加
- [ ] **達成時のアニメーション**
  - [ ] カロリー貯金達成時の演出
  - [ ] 豚の貯金箱アニメーション
  - [ ] 目標達成お祝い画面

---

## 🛡️ **セキュリティ・プライバシー**

### データ保護強化
- [ ] **暗号化実装**
  - [ ] ローカルデータの暗号化
  - [ ] 通信の暗号化強化
  - [ ] API キー管理の改善

### プライバシー機能
- [ ] **データエクスポート機能**
  - [ ] 個人データのCSV出力
  - [ ] 食事履歴のバックアップ
  - [ ] GDPR対応データ提供

---

## 📊 **分析・監視**

### ユーザー行動分析
- [ ] **使用状況トラッキング**
  - [ ] 機能利用率の計測
  - [ ] ユーザージャーニー分析
  - [ ] 離脱ポイントの特定

### パフォーマンス監視
- [ ] **アプリパフォーマンス計測**
  - [ ] 画面表示速度の監視
  - [ ] メモリ使用量の最適化
  - [ ] バッテリー消費量の改善

---

## 📝 **ドキュメント整備**

### 開発ドキュメント
- [ ] **API仕様書の更新**
  - [ ] Supabase関数の詳細説明
  - [ ] エラーコードの一覧化
  - [ ] レスポンス形式の標準化

### ユーザードキュメント
- [ ] **ヘルプページの充実**
  - [ ] 機能説明の詳細化
  - [ ] トラブルシューティングガイド
  - [ ] よくある質問の追加

---

## 🎯 **実装優先順位**

### P0 (緊急・必須)
1. GitHub Pages設定・App Store提出要件
2. Weight History統合
3. プロフィール画面の未実装UI

### P1 (高優先度)
1. 食事編集機能
2. データ可視化改善
3. エラーハンドリング統一

### P2 (中優先度)
1. パフォーマンス最適化
2. テスト強化
3. UI/UX改善

### P3 (低優先度)
1. アニメーション追加
2. 分析・監視機能
3. ドキュメント整備

---

**注意**: このTODOリストは開発状況に応じて継続的に更新されます。完了した項目は定期的にアーカイブし、新しいタスクを追加していきます。