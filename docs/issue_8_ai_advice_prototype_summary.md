# AIアドバイス機能プロトタイプ 技術サマリー (Issue #8)

## 1. イシュー番号・概要
*   **イシュー番号:** #8
*   **概要:** AI Meal Advice Prototype - ユーザーの食事記録と目標に基づき、AIが「最後の一食」のメニュー案を提案するプロトタイプ機能。

## 2. 実装コンポーネント詳細

### 2.1. Supabase Edge Function (`generate-meal-advice`)
*   **ファイルパス:** `supabase/functions/generate-meal-advice/index.ts`
*   **エンドポイントURL (デプロイ後):** `[あなたのSupabaseプロジェクトURL]/functions/v1/generate-meal-advice`
*   **リクエストスキーマ (JSON):**
    ```json
    {
      "targetCalories": "number (例: 2000)",
      "targetPfcRatio": {
        "protein": "number (0.0-1.0, 合計1.0)",
        "fat": "number (0.0-1.0, 合計1.0)",
        "carbohydrate": "number (0.0-1.0, 合計1.0)"
      },
      "consumedMealsPfc": {
        "protein": "number (g)",
        "fat": "number (g)",
        "carbohydrate": "number (g)",
        "calories": "number (kcal)"
      },
      "activeCalories": "number (kcal, 活動による消費カロリー)",
      "lang": "string (e.g., 'ja' or 'en', optional, default 'en')"
    }
    ```
    * `lang` を `'ja'` にすると、レスポンスが日本語で返されます。
*   **レスポンススキーマ (JSON - 成功時、メニュー提案あり):**
    ```json
    {
      "advice": "string (例: \"Here's a suggestion for your next meal:\")",
      "remainingCaloriesForLastMeal": "string (kcal, 例: \"650\")",
      "calculatedTargetPfcForLastMeal": {
        "protein": "string (g, 例: \"48.8\")",
        "fat": "string (g, 例: \"14.4\")",
        "carbohydrate": "string (g, 例: \"79.7\")"
      },
      "menuSuggestion": {
        "menuName": "string (例: \"鶏むね肉と彩り野菜のグリル、キヌア添え\")",
        "description": "string (例: \"高タンパクでヘルシーな鶏むね肉と、ビタミン豊富な野菜、良質な炭水化物のキヌアを組み合わせたバランスの良い一品です。\")",
        "estimatedNutrition": {
          "calories": "number (kcal)",
          "protein": "number (g)",
          "fat": "number (g)",
          "carbohydrates": "number (g)"
        },
        "recommendationReason": "string (例: \"このメニューは、目標タンパク質量をしっかり摂取しつつ、許容カロリー内に収まるよう調整されています。キヌアが腹持ちを良くし、野菜でビタミンも補給できます。\")"
      }
    }
    ```
*   **レスポンススキーマ (JSON - 成功時、カロリー目標達成済み):**
    ```json
    {
      "advice": "string (例: \"You have already met or exceeded your calorie goal for the day!\")",
      "remainingCalories": "number (kcal, 負の値または0)",
      "menuSuggestions": []
    }
    ```
*   **レスポンススキーマ (JSON - エラー時):**
    ```json
    {
      "error": "string (エラーメッセージ)",
      "details": "any (エラー詳細、オプショナル)"
    }
    ```
*   **算出ロジック概要:**
    1.  総目標カロリー = `targetCalories` (基礎代謝等) + `activeCalories` (活動消費)
    2.  残存許容カロリー = 総目標カロリー - `consumedMealsPfc.calories` (既に摂取したカロリー)
    3.  1日の目標PFCグラム数:
        *   タンパク質(g) = (総目標カロリー * `targetPfcRatio.protein`) / 4 (kcal/g)
        *   脂質(g) = (総目標カロリー * `targetPfcRatio.fat`) / 9 (kcal/g)
        *   炭水化物(g) = (総目標カロリー * `targetPfcRatio.carbohydrate`) / 4 (kcal/g)
    4.  「最後の一食」の目標PFCグラム数 = (1日の目標PFCグラム数) - (`consumedMealsPfc` の各PFCグラム数)
*   **Gemini API連携詳細:**
    *   **使用モデル:** `gemini-1.5-pro`
    *   **APIバージョン:** `v1`
    *   **エンドポイントURL:** `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=${GEMINI_API_KEY}`
    *   **リクエストボディ主要パラメータ:**
        ```json
        {
          "contents": [{
            "parts": [{
              "text": "プロンプト文字列" // 下記参照
            }]
          }],
          "generationConfig": {
            "temperature": 0.7, // 生成の多様性
            "maxOutputTokens": 500 // 最大出力トークン数
          }
        }
        ```
    *   **プロンプトエンジニアリングの要点:**
        *   算出された「最後の一食」の最大許容カロリー、目標タンパク質(g)、目標脂質(g)、目標炭水化物(g)を明確に提示。
        *   具体的なメニュー案を1つ提案するよう指示。
        *   提案メニューに含めるべき項目（メニュー名、簡単な説明、AI推定栄養価、おすすめ理由）をリスト形式で指定。
        *   出力形式を厳密なJSONオブジェクトとし、各キー名も指定。
        *   提案メニューのカロリーが許容範囲内であること、PFCバランスを考慮すること（特にタンパク質優先）、一般的で健康的なメニューを提案することなどを指示。

### 2.2. Flutterアプリケーション
*   **追加・変更されたデータモデル:**
    *   `lib/models/pfc_breakdown.dart`:
        *   `PfcBreakdown`: タンパク質、脂質、炭水化物、カロリー（オプショナル）の値を保持。`toJson`, `fromJson`, `calculatedCalories`を提供。
        *   `PfcRatio`: タンパク質、脂質、炭水化物の比率（合計1.0）を保持。`toJson`, `fromJson`を提供。
    *   `lib/models/ai_advice_request.dart`:
        *   `AiAdviceRequest`: Edge Functionへのリクエストデータ（`targetCalories`, `targetPfcRatio`, `consumedMealsPfc`, `activeCalories`）をカプセル化。`toJson`を提供。
    *   `lib/models/ai_advice_response.dart`:
        *   `EstimatedNutrition`: AI提案メニューの推定栄養価（カロリー、PFCグラム）。`fromJson`を提供。
        *   `MenuSuggestion`: AI提案メニュー詳細（名称、説明、栄養価、理由）。`fromJson`を提供。
        *   `AiAdviceResponse`: Edge Functionからのレスポンス全体。アドバイスメッセージ、残カロリー、目標PFC、メニュー提案などを保持。`fromJson`でパース処理。
*   **`AiAdviceService` (`lib/services/ai_advice_service.dart`):**
    *   `getMealAdvice(AiAdviceRequest request)`メソッドを提供。
    *   `SupabaseClient`インスタンスをコンストラクタで受け取る。
    *   `_supabaseClient.functions.invoke('generate-meal-advice', body: request.toJson())` を使用してEdge Functionを呼び出し。
    *   レスポンスステータスコード200以外の場合やレスポンスデータがnullの場合は例外をスロー。
    *   成功時はレスポンスデータを`AiAdviceResponse.fromJson`でパースして返却。
    *   `FunctionException`を含む各種例外をキャッチし、エラーメッセージと共に再スロー。
*   **UIレイヤーでの連携箇所 (`lib/screens/home_screen.dart` - `_HomeScreenState`):**
    *   「食事」タブ (`_tabController.index == 1`) 内にアドバイス取得UI (`_buildAiAdviceSection`) を追加。
    *   `ElevatedButton.icon` (「AIに最後の食事の提案を求める」) を表示。
        *   `todayMeals.length < 2` の場合はボタンを無効化し、その旨をテキストで表示。
    *   ボタン押下で `_fetchAiMealAdvice` メソッドを実行:
        *   ローディング状態 `_isFetchingAdvice` を管理。
        *   `AiAdviceRequest` のためのデータを収集:
            *   `targetCalories`: `2000` (ハードコードされたプレースホルダー)
            *   `targetPfcRatio`: `PfcRatio(protein: 0.3, fat: 0.2, carbohydrate: 0.5)` (ハードコードされたプレースホルダー)
            *   `consumedMealsPfc`: `ref.watch(todaysMealRecordsProvider)` からPFCとカロリーを合計して生成。
            *   `activeCalories`: `provider_pkg.Provider.of<HealthProvider>(context, listen: false).todayActivity?.workoutCalories ?? 0` を使用。
        *   `AiAdviceService(Supabase.instance.client).getMealAdvice(request)` を呼び出し。
        *   結果を `_aiAdviceResponse` に格納し、UIを更新。
        *   エラー発生時は `ScaffoldMessenger` で `SnackBar` を表示。
    *   アドバイス表示用ウィジェット (`_buildAdviceDisplay`):
        *   `_aiAdviceResponse` がnullでない場合に `Card` ウィジェットを表示。
        *   アドバイスメッセージ、提案メニュー詳細（名称、説明、栄養価、理由）、計算された目標値などを整形して表示。

### 3. 環境変数
*   **`GEMINI_API_KEY`**:
    *   **用途:** Supabase Edge Function (`generate-meal-advice`) がGoogle Gemini API (`gemini-1.5-pro`) を呼び出すために必須のAPIキー。
    *   **設定場所:** Supabaseプロジェクトの環境変数。
        *   Supabase Dashboard: Project Settings > Edge Functions > `generate-meal-advice` > Add new secret。
        *   または Supabase CLI: `supabase secrets set GEMINI_API_KEY=your_actual_api_key_value`

### 4. デプロイ手順
*   **`generate-meal-advice` Edge Functionのデプロイコマンド:**
    ```bash
    supabase functions deploy generate-meal-advice --no-verify-jwt
    ```
*   **注意点:**
    *   コマンドはプロジェクトのルートディレクトリで実行。
    *   ローカル環境にDocker Desktopがインストールされ、実行中であること。
    *   `--no-verify-jwt` オプションは、開発初期段階でJWT検証を省略する場合に使用。本番環境ではセキュリティポリシーに応じて適切なJWT検証設定を検討。
    *   `GEMINI_API_KEY` がSupabaseプロジェクトのシークレットとして正しく設定されていること。
*   **デプロイ時に発生した問題とその解決策のサマリー:**
    *   **問題1:** `geminiUrl` が古い設定 (`v1beta/models/gemini-pro`) のままデプロイされ続け、Gemini APIから404エラー（モデルが見つからない）が発生。
        *   **解決策:** ローカルの `supabase/functions/generate-meal-advice/index.ts` ファイル内の `geminiUrl` を `v1/models/gemini-1.5-pro` を使用する正しいURLに修正し、再度デプロイ。
    *   **問題2:** `supabase functions deploy` コマンド実行時にDockerデーモン接続エラー (`Cannot connect to the Docker daemon at unix:///var/run/docker.sock`)。
        *   **解決策:** Docker Desktopアプリケーションを起動し、Dockerデーモンが実行中であることを確認してからデプロイコマンドを再実行。
    *   **問題3 (Flutterビルド時):** `Supabase` クラスが見つからないエラー (`The getter 'Supabase' isn't defined`)。
        *   **解決策:** `lib/screens/home_screen.dart` に `import 'package:supabase_flutter/supabase_flutter.dart';` を追加。
    *   **問題4 (Flutterビルド時):** `FunctionException` の `message` および `response` プロパティが存在しないエラー。
        *   **解決策:** `lib/services/ai_advice_service.dart` のエラーハンドリング部分で、`e.message` の代わりに `e.details?.toString() ?? e.toString()` を使用し、`e.response` の参照を削除。

### 5. テスト概要
*   **実施したテスト内容:**
    *   **ユニットテスト:** 現時点では未作成。
    *   **インテグレーションテスト:** 現時点では未作成。
    *   **手動テスト (Flutterアプリ - iOSシミュレータ/実機):**
        *   食事記録が0食、1食、2食以上の場合の「AIアドバイスを求める」ボタンの活性状態と挙動を確認。
        *   2食以上記録がある状態でボタンをタップし、AIアドバイスが正常に取得・表示されることを確認。
        *   提案されたメニューの内容（名称、説明、栄養価、理由）が期待通り表示されるか確認。
        *   既に1日の目標カロリーを超過している場合に、適切なメッセージが表示されるか確認。
        *   (間接的に) Edge Functionが正しいGeminiモデル (`gemini-1.5-pro`) を呼び出し、レスポンスを得られることを確認。
*   **主要なテストケースと確認結果 (手動):**
    *   **ケース1:** 2食分の食事を記録 (例: 朝食300kcal, 昼食500kcal)。目標2000kcal、活動消費200kcal。→ AIアドバイスボタンが有効。タップすると、残りの許容カロリー (1400kcal) とPFCに基づいたメニュー提案が表示される。(成功)
    *   **ケース2:** 3食分の食事を記録し、合計カロリーが目標を超過 (例: 2300kcal摂取)。→ AIアドバイスボタンは有効だが、タップすると「既に目標カロリーを達成/超過しています」旨のメッセージが表示される。(成功)
    *   **ケース3:** 食事記録が1食のみ。→ AIアドバイスボタンが無効化され、「2食以上記録すると利用できます」のメッセージが表示される。(成功)

### 6. 既知の課題・制限事項（プロトタイプとして）
*   **AI提案の質と一貫性:**
    *   AI (Gemini 1.5 Pro) の提案はプロンプトに大きく依存し、常に最適またはユーザーが期待する質の提案が得られるとは限らない。
    *   提案される栄養価はAIによる推定であり、実際のメニューとは誤差が生じる可能性がある。
*   **提案バリエーションの制約:**
    *   現在は常に1つのメニュー案のみを提案する仕様。
*   **ユーザーの嗜好・アレルギー等の未対応:**
    *   ユーザー個別の食事の好み（例: 和食中心、特定の食材を避けたい等）やアレルギー情報は考慮されていない。
*   **固定された目標値:**
    *   Flutterアプリ側で、1日の目標摂取カロリー (2000 kcal) および目標PFCバランス (タンパク質30%, 脂質20%, 炭水化物50%) が固定値としてハードコードされている。これらはユーザーが設定変更できるべき項目。
*   **アクティブカロリーの精度:**
    *   現在、`HealthProvider` から取得できる `workoutCalories` を活動消費カロリーとして使用しているが、これは1日の総活動消費カロリーの一部である可能性が高い。より正確な値の取得方法や手動入力の検討が必要。
*   **エラーメッセージの具体性:**
    *   AIからの予期せぬ形式のレスポンスや、その他のAPIエラー発生時のユーザーへのフィードバックが汎用的。

### 7. 今後の改善・拡張案（エンジニアリング視点）
*   **プロンプトエンジニアリングの高度化:**
    *   ユーザーの過去の食事記録、好み、アレルギー情報などをプロンプトに含め、よりパーソナライズされた提案を実現。
    *   複数のメニュー案（例: 3案）を要求し、ユーザーが選択できるようにする。
    *   調理の難易度、調理時間、主要食材などの情報もAIに要求し、表示する。
*   **ユーザー設定機能の導入:**
    *   目標カロリー、目標PFCバランス、アレルギー情報、食事の好みなどをユーザーがアプリ内で設定・永続化できるようにする。
*   **入力バリデーションの強化:**
    *   Edge Function側で、リクエストとして受け取る各数値（カロリー、PFCグラム数、比率など）の妥当な範囲チェックを強化。
*   **エラーハンドリングとユーザーフィードバックの改善:**
    *   Gemini APIからのエラーレスポンスを詳細に解析し、具体的なエラー原因をユーザーに分かりやすく伝える。
    *   ネットワーク接続不良やタイムアウト時のリトライ処理や適切なメッセージ表示。
*   **状態管理の最適化 (Flutter):**
    *   `HomeScreen` におけるAIアドバイス関連の状態（ローディング、レスポンスデータ、エラー）管理を、Riverpodの `StateNotifierProvider` や `AsyncNotifierProvider` を用いてより宣言的かつ堅牢な形にリファクタリング。
*   **テストの拡充:**
    *   `AiAdviceService` および関連するデータモデルクラスのユニットテストを作成。
    *   Supabase CLIのテスト機能を利用して、`generate-meal-advice` Edge Functionのインテグレーションテスト（モックリクエストを用いた動作確認）を整備。
*   **提案メニューの永続化と活用:**
    *   提案されたメニューをユーザーが「お気に入り」として保存したり、実際にその食事を記録する際のテンプレートとして利用できる機能。
*   **コストと利用状況のモニタリング:**
    *   Gemini APIの利用料金とAPIコール数を監視する仕組みを検討。
