---
title: "Claude Code PMで実現する並列AI開発 - 仕様駆動で3倍速のソフトウェア開発"
emoji: "🤖"
type: "tech"
topics: ["claudecode", "ai", "github", "projectmanagement", "automation"]
published: false
---

## はじめに：AIエージェント開発の新たな課題

Claude CodeやCursor、GitHub Copilotなど、AIを活用した開発ツールが急速に普及しています。しかし、実際にAIエージェントを使った開発を進めると、以下のような壁にぶつかることがあります。

- 💬 **コンテキストの喪失** - セッションが変わるたびに、また同じ説明から始める必要がある
- 🔀 **並列作業の衝突** - 複数のAIが同じファイルを編集して競合が発生
- 📋 **仕様とコードの乖離** - 最初に定義した要件から実装が徐々にずれていく
- 👥 **進捗の不透明性** - チーム全体で「今何が起きているか」が把握しづらい

これらの問題を解決するために開発されたのが **Claude Code PM（ccpm）** です。

## Claude Code PMとは？

[Claude Code PM](https://github.com/automazeio/ccpm) は、Claude Codeを活用した**仕様駆動型プロジェクト管理システム**です。GitHub IssuesとGit worktreesを組み合わせることで、複数のAIエージェントが並列に作業できる環境を提供します。

### 🎯 コアコンセプト：「すべてのコードは仕様に紐づく」

ccpmの根幹にある思想は、**"Every line of code must trace back to a specification"**（すべてのコード行は仕様に遡れなければならない）です。

```mermaid
graph LR
    A[PRD/仕様書] --> B[Epic/実装計画]
    B --> C[Tasks/タスク]
    C --> D[GitHub Issues]
    D --> E[Code/実装]
    E --> F[Commit/PR]
```

## 実績データが示す効果

ccpmを採用したプロジェクトでは、以下のような改善が報告されています：

| 指標 | 改善率 | 説明 |
|------|--------|------|
| **コンテキストスイッチ** | -89% | セッション間での再説明が激減 |
| **バグ率** | -75% | 仕様との一貫性が保たれるため |
| **開発速度** | 3倍 | 5-8タスクの並列実行により |
| **チーム透明性** | +100% | GitHub Issuesで全員が進捗を把握 |

## 5ステップのワークフロー

### 1️⃣ PRD（製品要求仕様書）の作成

```bash
/pm:prd-new my-awesome-feature
```

AIガイド付きのブレインストーミングを通じて、構造化された仕様書を作成します。

### 2️⃣ Epic（実装計画）への変換

```bash
/pm:prd-parse my-awesome-feature
```

PRDを技術的な実装計画に変換し、アーキテクチャや依存関係を定義します。

### 3️⃣ タスクへの分解

```bash
/pm:epic-decompose my-awesome-feature
```

Epicを具体的なタスクに分解し、それぞれに受け入れ条件を設定します。

### 4️⃣ GitHub Issuesとの同期

```bash
/pm:epic-sync my-awesome-feature
# または一括実行
/pm:epic-oneshot my-awesome-feature
```

タスクをGitHub Issuesとして登録し、進捗管理の基盤を作ります。

### 5️⃣ 並列実行の開始

```bash
/pm:issue-start 123  # Issue #123の作業を開始
/pm:issue-start 124  # 別のターミナルでIssue #124も同時に
```

Git worktreesを使って、複数のタスクを独立した環境で同時進行できます。

## 実装例：ECサイトの機能追加

実際にECサイトにレビュー機能を追加する例を見てみましょう。

### Step 1: PRD作成

```bash
/pm:prd-new product-reviews
```

AIが以下のような項目について質問してきます：
- ユーザーストーリー
- 成功指標
- 技術的制約
- セキュリティ要件

### Step 2: タスク分解の結果

自動的に以下のようなタスクに分解されます：

```markdown
- [ ] データベーススキーマの設計と実装
- [ ] APIエンドポイントの開発
- [ ] フロントエンドコンポーネントの作成
- [ ] 認証・認可の実装
- [ ] テストケースの作成
- [ ] ドキュメントの更新
```

### Step 3: 並列実行

3人のAIエージェントが同時に作業：

```bash
# Agent 1: データベース担当
/pm:issue-start 201  # reviews テーブルの作成

# Agent 2: API担当
/pm:issue-start 202  # RESTful APIの実装

# Agent 3: フロントエンド担当
/pm:issue-start 203  # Reactコンポーネントの開発
```

各エージェントは独立したworktreeで作業するため、ファイルの競合を心配する必要がありません。

## セットアップ（2分で完了）

### 前提条件

- Claude Code（最新版）
- GitHubリポジトリ
- GitHub CLI（`gh`コマンド）

### インストール手順

```bash
# プロジェクトルートで実行
git clone https://github.com/automazeio/ccpm.git .claude/
cd .claude/

# 初期化
/pm:init

# GitHub認証の確認
gh auth status
```

### 基本的な使い方

```bash
# 新機能の仕様作成から実装まで
/pm:prd-new feature-name
/pm:prd-parse feature-name
/pm:epic-decompose feature-name
/pm:epic-sync feature-name

# 既存Issueから作業開始
/pm:issue-start 456
```

## アーキテクチャの特徴

### 🔧 技術スタック

- **言語**: シェルスクリプト + Markdown
- **依存関係**: Git, GitHub CLI, jq
- **ディレクトリ構造**:

```
.claude/
├── commands/     # Claude Codeコマンド
├── pm/          # プロジェクト管理ロジック
│   ├── prds/    # 仕様書
│   ├── epics/   # 実装計画
│   └── tasks/   # タスク定義
└── worktrees/   # 並列作業用ディレクトリ
```

### 🔄 コンテキスト保持の仕組み

各worktreeには専用の`.context`ファイルが生成され、AIエージェントは常に以下を把握できます：

- 現在作業中のIssue番号
- 関連する仕様書とタスク
- 依存関係と進捗状況

## コミュニティの声

RedditやHacker Newsでの反響：

> "仕様書から構造化されたリリースまで自動化でき、出荷時間が半分になりました" - スタートアップCTO

> "3つ以上の並列タスクは慎重に。人間のアーキテクトによる調整は依然として重要" - シニアエンジニア

> "GitHub Issuesが単一の真実の源（Single Source of Truth）として機能するのが素晴らしい" - プロジェクトマネージャー

## よくある質問

### Q: 既存プロジェクトにも導入できる？

A: はい。`.claude/`ディレクトリを追加するだけで、既存のワークフローを大きく変更することなく導入できます。

### Q: 並列実行の上限は？

A: 理論上は無制限ですが、実用的には3-5タスクの並列が推奨されています。それ以上は人間による調整コストが増大します。

### Q: Claude Code以外でも使える？

A: 基本的な機能はCLIベースなので、他のAIツールやIDEからも利用可能です。ただし、最適化はClaude Code向けになっています。

### Q: チーム開発での注意点は？

A: GitHub Issuesの命名規則とラベル管理を事前に決めておくことが重要です。また、Epic分解時の粒度をチーム内で統一しておくと、よりスムーズに運用できます。

## ベストプラクティス

### ✅ DO

- **小さく始める**: 最初は1-2タスクの並列から始めて、徐々に増やす
- **仕様を詳細に**: PRD作成時は可能な限り具体的に記述
- **定期的な同期**: GitHub Issuesの状態を定期的に確認
- **人間のレビュー**: 重要な設計判断は必ず人間が確認

### ❌ DON'T

- **過度な並列化**: 10以上のタスクを同時に走らせない
- **仕様の省略**: 「後で考える」項目を残さない
- **自動マージ**: PRは必ず人間がレビュー
- **コンテキスト無視**: `.context`ファイルを手動で編集しない

## まとめ：AI時代の開発手法

Claude Code PMは、AIエージェントを活用した開発における「カオス」を「秩序」に変える強力なツールです。

**主な利点：**
- 📊 **完全なトレーサビリティ** - 仕様からコードまですべて追跡可能
- 🚀 **3倍の開発速度** - 並列実行による効率化
- 👁️ **透明性の向上** - GitHub Issuesでチーム全体が状況を把握
- 🛡️ **品質の向上** - 仕様との一貫性によりバグ率75%削減

AIを「単なるコード補完ツール」から「本格的な開発パートナー」へと進化させる、それがClaude Code PMの目指す世界です。

## 参考リンク

- [GitHub リポジトリ](https://github.com/automazeio/ccpm)
- [公式ドキュメント](https://github.com/automazeio/ccpm/wiki)
- [導入事例とベンチマーク](https://automaze.io/blog/claude-code-pm-case-studies)

---

*この記事が参考になった場合は、GitHubリポジトリへのスターをお願いします！質問やフィードバックは[Issues](https://github.com/automazeio/ccpm/issues)まで。*