---
title: "gh-sub-issueを作った後にClaude Code PMを調査してみた - Issue分解とAI並列開発の関係"
emoji: "🔍"
type: "tech"
topics: ["claudecode", "ai", "github", "projectmanagement", "automation", "ghsubissue"]
published: true
---

## はじめに：gh-sub-issue開発から始まった調査

先日、GitHub Issuesを階層的に管理するためのCLIツール「[gh-sub-issue](https://github.com/yahsan2/gh-sub-issue)」を開発・公開しました。このツールは、大きなIssueを小さなsub-issueに分解して管理することで、タスクの可視化と並列作業を効率化することを目的としています。

gh-sub-issueの開発中、「このツールに依存している他のプロジェクトがあるのでは？」と気になり調査したところ、興味深いプロジェクトを発見しました。それが **Claude Code PM（ccpm）** です。

実際にコードを確認してみると、ccpmも内部でgh-sub-issueのようなIssue分解機能を実装しており、さらにそれをAIエージェントの並列開発と組み合わせているようでした。

## なぜ調査したのか

私が開発したgh-sub-issueは、以下のような機能を提供しています：

```bash
# Issueを階層的に分解
gh sub-issue create --parent 123 --title "サブタスク"

# 親子関係の可視化
gh sub-issue list --parent 123
```

Claude Code PMがこの概念をどのように拡張しているのか、また、AIエージェントとの統合でどのような価値を生み出しているのかに興味を持ち、詳しく調査することにしました。

## Claude Code PMとは？

[Claude Code PM](https://github.com/automazeio/ccpm) は、Claude Codeを活用した**仕様駆動型プロジェクト管理システム**とのことです。GitHub IssuesとGit worktreesを組み合わせることで、複数のAIエージェントが並列に作業できる環境を提供するというコンセプトが特徴的です。

### 🎯 gh-sub-issueとの共通点

調査してみると、ccpmも私のgh-sub-issueと同様に、**大きなタスクを小さなIssueに分解する**という考え方を採用していました。ただし、ccpmはこれをさらに発展させ、AIエージェントとの統合を実現している点が興味深いです。

### プロジェクトのコアコンセプト

公式ドキュメントによると、ccpmの根幹にある思想は **"Every line of code must trace back to a specification"**（すべてのコード行は仕様に遡れなければならない）とのことです。

```mermaid
graph LR
    A[PRD/仕様書] --> B[Epic/実装計画]
    B --> C[Tasks/タスク]
    C --> D[GitHub Issues]
    D --> E[Code/実装]
    E --> F[Commit/PR]
```

## 報告されている効果

プロジェクトのドキュメントや利用者のフィードバックによると、以下のような改善が報告されているそうです：

| 指標 | 改善率 | 説明 |
|------|--------|------|
| **コンテキストスイッチ** | -89% | セッション間での再説明が激減 |
| **バグ率** | -75% | 仕様との一貫性が保たれるため |
| **開発速度** | 3倍 | 5-8タスクの並列実行により |
| **チーム透明性** | +100% | GitHub Issuesで全員が進捗を把握 |

※これらの数値は開発元による報告であり、実際の効果は使用環境により異なる可能性があります。

## ワークフローの仕組み

公式ドキュメントを調査したところ、以下の5つのステップで動作するようです：

### 1️⃣ PRD（製品要求仕様書）の作成

```bash
/pm:prd-new my-awesome-feature
```

AIガイド付きのブレインストーミングを通じて、構造化された仕様書を作成する機能があるとのこと。

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

**ここがgh-sub-issueと似ている部分です！** ccpmも内部でIssueの階層構造を作成し、親子関係を管理しているようです。

### 4️⃣ GitHub Issuesとの同期

```bash
/pm:epic-sync my-awesome-feature
# または一括実行
/pm:epic-oneshot my-awesome-feature
```

タスクをGitHub Issuesとして登録し、進捗管理の基盤を作ります。私のgh-sub-issueでは手動で行う必要がある部分を、ccpmは自動化している点が印象的でした。

### 5️⃣ 並列実行の開始

```bash
/pm:issue-start 123  # Issue #123の作業を開始
/pm:issue-start 124  # 別のターミナルでIssue #124も同時に
```

Git worktreesを使って、複数のタスクを独立した環境で同時進行できます。

## 使用例：ECサイトへのレビュー機能追加

ドキュメントに記載されていた使用例を紹介します。ECサイトにレビュー機能を追加するケースです。

### Step 1: PRD作成

```bash
/pm:prd-new product-reviews
```

AIが以下のような項目について対話的に確認するそうです：
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

### Step 3: 並列実行の例

複数のAIエージェントが同時に作業できる仕組みになっているようです：

```bash
# Agent 1: データベース担当
/pm:issue-start 201  # reviews テーブルの作成

# Agent 2: API担当
/pm:issue-start 202  # RESTful APIの実装

# Agent 3: フロントエンド担当
/pm:issue-start 203  # Reactコンポーネントの開発
```

各エージェントは独立したworktreeで作業するため、ファイルの競合を回避できる設計になっているとのことです。

## セットアップ方法

ドキュメントによると、セットアップは比較的簡単なようです。

### 必要な環境

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

### 基本的なコマンド例

```bash
# 新機能の仕様作成から実装まで
/pm:prd-new feature-name
/pm:prd-parse feature-name
/pm:epic-decompose feature-name
/pm:epic-sync feature-name

# 既存Issueから作業開始
/pm:issue-start 456
```

## 技術的な特徴

リポジトリを調査したところ、以下のような技術的特徴があることがわかりました：

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

興味深い点として、各worktreeには専用の`.context`ファイルが生成される仕組みがあるようです。これにより、AIエージェントは以下の情報を常に把握できるとのこと：

- 現在作業中のIssue番号
- 関連する仕様書とタスク
- 依存関係と進捗状況

## ユーザーからのフィードバック

オンラインコミュニティで見つけたいくつかのフィードバックを紹介します：

> "仕様書から構造化されたリリースまで自動化でき、出荷時間が半分になった" - あるスタートアップCTOのコメント

> "3つ以上の並列タスクは慎重に。人間のアーキテクトによる調整は依然として重要" - シニアエンジニアの意見

> "GitHub Issuesが単一の真実の源（Single Source of Truth）として機能するのが良い" - プロジェクトマネージャーの評価

## よくある質問（FAQから抜粋）

### Q: 既存プロジェクトにも導入できる？

A: ドキュメントによると、`.claude/`ディレクトリを追加するだけで、既存のワークフローを大きく変更することなく導入できるそうです。

### Q: 並列実行の上限は？

A: 理論上は無制限とのことですが、実用的には3-5タスクの並列が推奨されているようです。それ以上は人間による調整コストが増大する傾向があるとのこと。

### Q: Claude Code以外でも使える？

A: 基本的な機能はCLIベースなので、他のAIツールやIDEからも利用可能とされています。ただし、最適化はClaude Code向けになっているそうです。

### Q: チーム開発での注意点は？

A: GitHub Issuesの命名規則とラベル管理を事前に決めておくことが重要とのこと。また、Epic分解時の粒度をチーム内で統一しておくと、よりスムーズに運用できるようです。

## 推奨されるベストプラクティス

プロジェクトのドキュメントから、以下のようなベストプラクティスが提案されていました：

### ✅ 推奨事項

- **小さく始める**: 最初は1-2タスクの並列から始めて、徐々に増やす
- **仕様を詳細に**: PRD作成時は可能な限り具体的に記述
- **定期的な同期**: GitHub Issuesの状態を定期的に確認
- **人間のレビュー**: 重要な設計判断は必ず人間が確認

### ❌ 避けるべきこと

- **過度な並列化**: 10以上のタスクを同時に走らせない
- **仕様の省略**: 「後で考える」項目を残さない
- **自動マージ**: PRは必ず人間がレビュー
- **コンテキスト無視**: `.context`ファイルを手動で編集しない

## 所感：gh-sub-issueとClaude Code PMの相乗効果

Claude Code PMを調査して、私が開発したgh-sub-issueの概念がAI開発においてどのように活用されているかを理解できました。

### gh-sub-issueとccpmの比較

| 観点 | gh-sub-issue（私のツール） | Claude Code PM |
|------|---------------------------|----------------|
| **Issue分解** | 手動で階層構造を作成 | AIが自動で分解提案 |
| **並列作業** | 人間が複数タスクを処理 | AIエージェントが並列実行 |
| **コンテキスト管理** | Issue間のリンクで管理 | worktreeごとに.contextファイル |
| **仕様との紐付け** | 手動で関連付け | PRDから自動生成 |

### 学んだこと

1. **Issue分解の重要性** - gh-sub-issueで実現したかった「タスクの適切な粒度への分解」が、AI開発でも重要な要素であることを確認できました。

2. **自動化の可能性** - 私のツールでは手動で行っている部分を、AIを活用することで大幅に自動化できる可能性が見えました。

3. **統合的なアプローチ** - Issue管理（gh-sub-issue）とworktree管理を組み合わせることで、より効率的な並列開発が可能になることがわかりました。

### 今後の展望

gh-sub-issueとClaude Code PMのような仕様駆動型ツールを組み合わせることで、以下のような開発フローが実現できそうです：

1. gh-sub-issueでタスクを階層的に整理
2. Claude Code PMでAIエージェントに並列実行させる
3. 人間はレビューと全体の調整に集中

私のgh-sub-issueも、将来的にはAIとの統合を検討する価値がありそうです。

## 参考リンク

### 私が開発したツール
- [gh-sub-issue GitHub リポジトリ](https://github.com/yahsan2/gh-sub-issue) - GitHub Issuesの階層管理ツール

### 調査したプロジェクト
- [Claude Code PM GitHub リポジトリ](https://github.com/automazeio/ccpm)
- [公式ドキュメント](https://github.com/automazeio/ccpm/wiki)
- [プロジェクトサイト](https://automaze.io/)

---

*この記事は、私が開発したgh-sub-issueに関連して、Claude Code PMというオープンソースプロジェクトを調査したレポートです。実際の効果や適用性は、各プロジェクトの状況により異なることにご注意ください。*
