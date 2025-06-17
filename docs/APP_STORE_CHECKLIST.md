# App Store申請チェックリスト

## ✅ 基本情報
- [x] アプリ名: トントン ヘルス (TonTon Health)
- [x] バージョン: 1.0.0+6
- [x] カテゴリ: ヘルスケア＆フィットネス
- [x] 年齢制限: 12+
- [x] プライバシーポリシーURL: https://delaxgithub.github.io/tonton/privacy/

## ✅ 技術要件
- [x] iOS最小バージョン: 16.2
- [x] Info.plistに年齢制限設定 (LSApplicationContentRating: 12)
- [x] ビルドエラーなし
- [x] 実機でのテスト完了

## ✅ プライバシー要件
- [x] プライバシーポリシー作成
- [x] データ収集の説明
- [x] サードパーティ共有の明記
- [x] アカウント削除機能実装

## ✅ 権限の説明
- [x] カメラ使用目的の説明
- [x] フォトライブラリ使用目的の説明
- [x] HealthKit使用目的の説明
- [x] 権限拒否時の動作確認

## ✅ ローカライゼーション
- [x] 日本語対応
- [x] 英語対応 (一部)
- [x] プライバシー関連の文言追加

## 📝 App Store申請前の最終確認事項

### 1. GitHub Pages設定
- [ ] リポジトリ設定でGitHub Pagesを有効化
- [ ] ブランチ: app-store-clean
- [ ] フォルダ: / (root)
- [ ] URLアクセス確認: https://delaxgithub.github.io/tonton/privacy/

### 2. デモアカウント準備
- [ ] reviewer@tonton-health.app のアカウント作成
- [ ] サンプルデータの入力

### 3. スクリーンショット準備
- [ ] iPhone 6.9インチ (iPhone 16 Pro Max)
- [ ] iPhone 6.7インチ (iPhone 16 Pro)
- [ ] iPhone 6.5インチ (iPhone 16 Plus)
- [ ] iPad 13インチ (iPad Pro)
- [ ] iPad 12.9インチ (iPad Pro)

### 4. App Store Connect設定
- [ ] アプリ説明文の入力
- [ ] キーワードの設定
- [ ] プロモーションテキストの入力
- [ ] 新機能の説明
- [ ] プライバシー情報の入力

### 5. ビルドアップロード
- [ ] Xcodeでアーカイブ作成
- [ ] App Store Connectにアップロード
- [ ] TestFlightでの動作確認

## 🚨 注意事項
- JWT tokenがgit履歴に残っていないことを確認
- Supabase認証情報が最新であることを確認
- .envファイルがgitignoreされていることを確認

## 📅 申請スケジュール
- GitHub Pages有効化: 即時
- URLアクセス可能: 5-10分後
- App Store申請: GitHub Pages確認後
- 審査期間: 通常2-7日