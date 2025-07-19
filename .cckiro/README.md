# トントン - spec-driven development設定

このプロジェクトはspec-driven developmentを標準化しています。

## 自動化された開発プロセス

### 🔄 自動検出・誘導システム
開発関連のタスクを開始すると、自動的にspec-driven developmentプロセスが起動します。

**検出キーワード:**
- リファクタリング、新機能、実装、開発
- 機能追加、バグ修正、改善、変更
- 作成、追加、削除、修正

### 📋 必須フェーズ

1. **事前準備フェーズ**
   - `.cckiro/specs/{task-name}` ディレクトリ作成

2. **要件フェーズ** 
   - `requirements.md` 作成・ユーザー承認

3. **設計フェーズ**
   - `design.md` 作成・ユーザー承認

4. **実装計画フェーズ**
   - `implementation-plan.md` 作成・ユーザー承認

5. **実装フェーズ**
   - 承認された計画に基づく実装

## 設定ファイル

### Claude Code Hooks
`.claude-code/hooks.json` - 開発タスク自動検出・プロセス誘導

### プロジェクト設定
`.cckiro/config.json` - spec-driven development設定

### テンプレート
`.cckiro/templates/` - 各フェーズのドキュメントテンプレート

## 使用方法

1. **通常通りタスクを開始** - 自動検出により誘導されます
2. **各フェーズで承認** - "進めて" "OK" などで次フェーズに進行
3. **spec済みタスク** - 既存specがある場合は「spec済み」と明記

## ファイル構成

```
.cckiro/
├── config.json              # プロジェクト設定
├── README.md                 # このファイル
├── specs/                    # 全タスクのspec保管
│   └── {task-name}/         # タスクごとのディレクトリ
│       ├── requirements.md
│       ├── design.md
│       └── implementation-plan.md
└── templates/               # spec作成用テンプレート
    ├── requirements_template.md
    ├── design_template.md
    └── implementation_plan_template.md

.claude-code/
└── hooks.json               # Claude Code hooks設定
```

## 設定カスタマイズ

設定は `.cckiro/config.json` で調整可能：
- `enforce_spec_for_major_changes`: 大きな変更でのspec強制
- `allowed_direct_changes`: spec不要な小さな変更
- `require_approval`: フェーズ間承認の必要性

この設定により、今後すべての開発タスクで一貫したspec-driven developmentが適用されます。