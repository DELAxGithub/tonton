# 環境変数の設定ガイド

## 概要
このプロジェクトでは、機密情報（SupabaseのURLやアクセスキーなど）を安全に管理するために、環境変数を使用しています。

## セットアップ手順

1. `.env.example`ファイルをコピーして`.env`ファイルを作成します：
   ```bash
   cp .env.example .env
   ```

2. `.env`ファイルを編集し、必要な値を設定します：
   ```plaintext
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

## 環境変数の優先順位
環境変数は以下の順序で読み込まれます：

1. `.env`ファイル
2. システム環境変数（Platform.environment）
3. コンパイル時の変数（--dart-define）

## コンパイル時の変数の使用方法
開発環境で`.env`ファイルを使用できない場合は、以下のようにコマンドラインで変数を設定できます：

```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

## CI/CD での使用
CI/CD環境では、環境変数を直接設定することをお勧めします。
