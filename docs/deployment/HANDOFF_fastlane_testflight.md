# 引き継ぎ: tonton を TestFlight に上げる (fastlane)

> 作成 2026-06-01 / 対象マシン: **MacBook Pro (`delaxpro`)** / 対象バージョン: `1.7.1+36`
> 目的: `bundle exec fastlane ios beta` で TestFlight アップロードを成功させる。
> 注意: `docs/deployment/fastlane_setup.md` は**実 Fastfile と命名が食い違う古い汎用ドキュメント**。当てにしないこと。正は本ファイル + `ios/fastlane/Fastfile`。

## 結論（先に要点）

このMBPで beta が通らない原因は **ただ1つ** — match リポ復号用 `MATCH_PASSWORD` が
このマシンに無い（keychain 未登録 & zshrc に export 行なし）。
他（ASC API キー三点・.p8・`.env`・`.env.default` の罠）は **すべて整っている**。

`MATCH_PASSWORD` の値は人間（小寺）しか知らない（Mac Studio で初期化済の match 暗号化PW）。
**AI は値を入手できないので、下記「人間の1手」は本人が実施する。**

## このMBPの現状（検証済 2026-06-01）

| 必要物 | 状態 | 供給元 |
|---|---|---|
| `ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_KEY_PATH` | ✅ あり | `~/.zshrc` で export（ISSUER は `69a6de84-48dd-47e3-e053-5b8c7c11a4d1` 固定） |
| `~/.appstoreconnect/AuthKey_*.p8` | ✅ あり | ファイル実在 |
| repo-root `.env`（SUPABASE_URL / SUPABASE_ANON_KEY / GEMINI_API_KEY） | ✅ あり | `op inject`（`.env.tpl`） |
| `ios/fastlane/.env.default` の空 `MATCH_PASSWORD=""` 上書き罠 | ✅ コメントアウト済 (commit `fee443e`) | — |
| **keychain `delax-fastlane-match`** | ❌ **このMBPに無い** | ← これだけ未整備 |
| **zshrc の `MATCH_PASSWORD` export 行** | ❌ このMBPに無い | ← 要追加 |

## 人間の1手（小寺が実施 / AI は触らない）

```bash
# 1) match 復号PW を keychain に登録（プロンプト入力 = 履歴に残らない）
security add-generic-password -a "fastlane-match" -s "delax-fastlane-match" -w

# 2) zshrc に export 行を追加（恒久化）。Mac Studio と同じ運用に揃える。
#    ~/.zshrc 末尾の ASC_* export の近くに:
export MATCH_PASSWORD=$(security find-generic-password -a "fastlane-match" -s "delax-fastlane-match" -w)
# 追加後: source ~/.zshrc （または新しいシェル）
```

> 暫定で済ませるなら keychain 登録せず `export MATCH_PASSWORD='...'` を当該シェルで1回でも可。
> ただし恒久運用は keychain + zshrc（Mac Studio と同形）が正。

## Codex 側の手順（PW投入後）

```bash
cd /Users/delaxpro/src/10_apps/tonton

# 0) 事前確認（値は出さない）
echo "ASC_KEY_ID set?     ${ASC_KEY_ID:+yes}"
echo "MATCH_PASSWORD set? ${MATCH_PASSWORD:+yes}"   # ← yes が出ること
ls ~/.appstoreconnect/*.p8

# 1) 証明書/プロファイル同期が必要なら（通常は beta 内 readonly match で足りる）
cd ios && bundle exec fastlane ios sync_certs   # 失敗時のみ

# 2) ビルド & TestFlight アップロード
cd /Users/delaxpro/src/10_apps/tonton/ios
bundle exec fastlane ios beta
```

## Fastfile の要点（`ios/fastlane/Fastfile`）

- lane は 2 本: **`sync_certs`**（match 書込）/ **`beta`**（build + upload）。
- `beta` は実行時に **repo-root `.env` を全キー ENV に流し込む**（SUPABASE/GEMINI 用）。
  → `MATCH_PASSWORD` は **`.env` ではなくシェル環境（keychain export）から渡る**設計。
- 失敗ポイントと要求変数:
  - `asc_api_key`（L12-21）: `ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_KEY_PATH` 未設定なら `UI.user_error!`。
  - `match(readonly:true)`（L65）: **`MATCH_PASSWORD` 未設定だと復号失敗/プロンプト停止**。← 今回の唯一の壁。
  - `match` 設定: git storage `https://github.com/DELAxGithub/fastlane-match`、`app-store`、`force_legacy_encryption: true`、Team `Z88477N5ZU`、Bundle `com.HiroshiKodera.tonton`。
- `upload_to_testflight(skip_waiting_for_build_processing: true)` — 投入後の処理待ちはしない。

## 既知の注意

- ビルド番号 `1.7.1+36`: 過去 TestFlight は `+30` 投入（devlog 2026-05-09）。`+36` は未使用想定だが、
  もし「build already exists」で弾かれたら `pubspec.yaml` の build 番号を `+37` 以降に bump。
- `flutter analyze` の error は **全て `widgetbook/` 配下の既存ドリフト**（TestFlight ビルド対象外）。beta には無関係。
- `force push しない` / `MATCH_PASSWORD を平文で .env / git に置かない`（keychain or op 経由のみ）。
