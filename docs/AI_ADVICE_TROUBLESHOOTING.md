# AIアドバイス機能のトラブルシューティング

## エラー対応と修正内容

### 1. Context依存の問題修正
- **ファイル**: `lib/features/meal_logging/providers/ai_advice_provider.dart`
- **修正内容**:
  - BuildContext依存を削除し、言語コードを引数として受け取るように変更
  - `Provider.of<HealthProvider>`の使用を削除し、Riverpodのproviderを使用
  - Refを通じて必要なデータにアクセス

### 2. エラーハンドリングの強化
- **ファイル**: `lib/services/ai_advice_service.dart`
- **実装内容**:
  - JSONレスポンスのサニタイズ機能（不正な文字の除去）
  - FunctionExceptionの適切なキャッチ
  - developer.logによる詳細なエラーロギング
  - ユーザーフレンドリーなエラーメッセージ

### 3. エラー時の暫定対応
- **ファイル**: `lib/features/meal_logging/providers/ai_advice_provider.dart`
- **実装内容**:
  - エラー発生時にダミーデータを返す
  - 日本語と英語の両方に対応
  - 基本的な栄養アドバイスを表示

### 4. UI側のエラー処理
- **ファイル**: `lib/widgets/ai_advice_modal.dart`
- **実装内容**:
  - エラー状態の表示
  - 再試行ボタン
  - ローディング中の適切な表示

## Edge Function設定の確認

### 1. Supabaseダッシュボードで確認
1. [Supabase Dashboard](https://app.supabase.io)にログイン
2. プロジェクトを選択
3. 左メニューから「Edge Functions」を選択
4. 以下の関数がデプロイされているか確認：
   - `generate-meal-advice`
   - `generate-meal-advice-v2`

### 2. 環境変数の確認
Edge Functions内で以下の環境変数が設定されているか確認：
- `GEMINI_API_KEY`

### 3. CORS設定の確認
Edge Functionのコードに以下が含まれているか確認：
```typescript
import { corsHeaders } from "../_shared/cors.ts";

// OPTIONS リクエストの処理
if (req.method === "OPTIONS") {
  return new Response("ok", { headers: corsHeaders });
}
```

## デバッグ方法

### 1. ブラウザのコンソールでエラーを確認
```javascript
// デベロッパーツールのConsoleタブで確認
```

### 2. Supabaseのログを確認
1. Supabaseダッシュボード → Edge Functions → 該当の関数を選択
2. 「Logs」タブでエラーログを確認

### 3. Flutter側のログを確認
```bash
flutter logs
```

### 4. テスト用コマンド
```bash
# Edge Functionの動作確認
curl -X POST https://[PROJECT_ID].supabase.co/functions/v1/generate-meal-advice-v2 \
  -H "Authorization: Bearer [ANON_KEY]" \
  -H "Content-Type: application/json" \
  -d '{
    "targetCalories": 2000,
    "targetPfcRatio": {"protein": 0.3, "fat": 0.3, "carbohydrate": 0.4},
    "consumedMealsPfc": {"protein": 50, "fat": 30, "carbohydrate": 100, "calories": 850},
    "activeCalories": 300,
    "lang": "ja"
  }'
```

## よくある問題と解決方法

### 1. "Function not found"エラー
- **原因**: Edge Functionがデプロイされていない
- **解決**: `supabase functions deploy`コマンドでデプロイ

### 2. JSONパースエラー（position 777など）
- **原因**: Gemini APIからの不正なレスポンス
- **解決**: 既に実装済みのサニタイズ機能で対応

### 3. タイムアウトエラー
- **原因**: Gemini APIの応答が遅い
- **解決**: Edge Functionのタイムアウト設定を延長

### 4. CORS エラー
- **原因**: CORS設定が不適切
- **解決**: Edge FunctionにcorsHeadersを追加

## 推奨事項

1. **キャッシュの活用**
   - 同じ条件でのアドバイス生成を避けるため、キャッシュを使用
   - `aiAdviceCacheProvider`で実装済み

2. **エラー時の再試行**
   - UIに再試行ボタンを実装済み
   - 自動リトライは実装していない（ユーザー操作による）

3. **ログの活用**
   - `developer.log`でエラーの詳細を記録
   - 本番環境では適切なログ収集サービスと連携を推奨