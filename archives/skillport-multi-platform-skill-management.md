---
title: "Claude CodeとCodexでスキルを共有したい！skillportを使ってみた"
emoji: "⚓"
type: "tech"
topics: ["ai", "claude", "codex", "mcp", "automation"]
published: false
---

## はじめに：スキル管理、めんどくさくないですか？

最近、Codex にも skill 機能がリリースされましたね。

Claude CodeからCodexに乗り換えようとして、ふと気づいたんです。

「あれ、`.claude/skills/` に10個以上あるスキル、全部移行するの...？」

Claude Code、Codex、Cursor、GitHub Copilot... 複数のAIツールを使い分けていると、同じスキルを各ツールで個別に設定し直す羽目になります。これ、明らかに非効率ですよね。

そんな悩みを抱えていたところ、私が愛用している cc-ssd の作者の新作で **[skillport](https://github.com/gotalab/skillport)** というツールを見かけました。まだリリースされたばかりですが、「複数のAIツールでスキルを共有できる」という課題は感じていてコンセプトに惹かれて、実際に使ってみることにしました。

正直、まだ完全には理解できていない部分もありますが、使ってみてわかったことをまとめてみます。

## skillportとは？

skillportは**AIエージェントのスキルを一元管理し、複数のツールで利用できるプラットフォーム**です。「スキルの港（Port）」という名前が示す通り、「一度管理すれば、どこでも利用可能（Manage once, serve anywhere）」というコンセプトで設計されています。

主な特徴は以下の2つ：

**1. マルチプラットフォーム対応**

同じスキルセットをClaude Code、Codex、Cursor、Copilotなど、複数のAIツールで共有できます。これが一番魅力的なポイントです。

**2. 2つの運用モード**

- **MCPモード**: 複数プロジェクトでグローバルにスキルを共有
- **CLIモード**: 単一プロジェクト内でシンプルに運用

この辺りの使い分けは、実際に使ってみないとピンと来なかったので、まずは試してみることにしました。

## AIエージェントのスキルの特徴

前提ですがAIエージェントの管理するskillには、以下のような特徴があります：

**段階的な情報開示**

skillは、メタデータ（約100トークン/skill）のみを最初に読み込んで、実際の詳細は必要なときだけ呼び出す仕組みになっています。

```markdown
# AIが最初に見る情報（約100トークン/skill）
- ID: data-processor
- 説明: CSV/JSONデータを処理
- カテゴリ: data

# 実際に使うときだけ読み込まれる詳細（数千トークン）
- 具体的な実装手順
- コード例
- エラーハンドリング
```

この仕組みにより、大量のskillを管理していてもコンテキストを圧迫しません。

このスキルをどのように管理・共有するかが、skillportの肝になります。

## 実際に使ってみた

### インストール

まずはインストールから。`uv` を使っている場合は以下のコマンドで入ります：

```bash
# uvを使う場合（推奨）
uv tool install skillport

# または pip
pip install skillport
```

私は `uv` で管理しているので、`uv tool install skillport` でサクッとインストールできました。

### MCPモード：グローバルなスキル管理

複数のプロジェクトで同じスキルを使いたい場合に向いているモードです。

私の場合、Claude Code と Codex を併用しているので、このモードが適していそうでした。設定は拍子抜けするほど簡単で、Codex の `settings.json` に以下を追加するだけ：

```json
// Codexの設定例（settings.json）
{
  "mcpServers": {
    "skillport": {
      "command": "uvx",
      "args": ["skillport", "mcp"]
    }
  }
}
```

これだけで、Codexから全てのskillportスキルにアクセスできるようになります。本当にこれだけ？と思いましたが、実際にこれで動きました。

### CLIモード：プロジェクト単位での管理

特定のプロジェクトでのみスキルを使いたい場合は、CLIモードも試してみました。

```bash
# プロジェクトルートで初期化
cd your-project
skillport init

# スキルを追加
skillport add hello-world

# AGENTS.mdを生成（AIツールが読み込む）
skillport doc
```

`skillport init` を実行すると、プロジェクト内に `.skillport/` ディレクトリが作成され、`AGENTS.md` ファイルにスキル情報が記録されます。この `AGENTS.md` をAIツールが読み込む仕組みです。

### 基本コマンド

```bash
# スキルの追加
skillport add hello-world                    # ビルトインスキル
skillport add https://github.com/.../skills  # GitHub URLから
skillport add ./local/path/to/skill          # ローカルパスから

# スキルの管理
skillport list                               # インストール済みスキル一覧
skillport search <query>                     # キーワード検索
skillport show <id>                          # スキルの詳細表示
skillport remove <id>                        # アンインストール

# ドキュメント生成
skillport doc                                # AGENTS.mdを更新
skillport doc --all                          # 全ての設定ファイルを更新

# スキルの検証
skillport lint [id]                          # スキルの整合性チェック
```

## 使ってみてわかった実用シーン

### ケース1：Codexへの移行が一瞬で終わった

これが一番感動したポイントです。冒頭で書いた「Claude Codeの20個以上のスキルをCodexに移行する」問題ですが、skillportを使ったら本当に一瞬で解決しました。

**従来なら：**
```bash
# 各スキルを手動でCodex用に設定し直す
# .claude/skills/ から .codex/skills/ にコピー＆調整...
# 設定ファイルのフォーマットが違ったら書き換え...
```

**skillportを使ったら：**
```json
// Codexのsettings.jsonに1行追加するだけ
{
  "mcpServers": {
    "skillport": {
      "command": "uvx",
      "args": ["skillport", "mcp"]
    }
  }
}
```

これだけで全てのスキルがCodexでも利用可能になりました。正直、「え、これで終わり？」って感じでした。

### その他の機能（まだ試せていない）

他にも以下のような機能があります：

**環境変数でのフィルタリング**
```bash
# カテゴリでスキルを絞り込める
export SKILLPORT_ENABLED_CATEGORIES="development,testing"
```

**GitHubリポジトリからのスキル追加**
```bash
# プライベートリポジトリからも追加できる
skillport add https://github.com/your-company/internal-skills
```

このあたりは、チームでスキルを共有する場面で便利そうですが、私はまだ個人利用しかしていないので、実際の使用感はわかりません。

## スキルの保存場所

skillportをインストールすると、以下のような構造でスキルが保存されます：

**MCPモード：**
```
~/.local/share/skillport/
├── skills/
│   ├── data-processor/
│   ├── api-tester/
│   └── doc-generator/
└── metadata.json
```

**CLIモード：**
```
your-project/
├── .skillport/
│   └── skills/
│       └── ...
├── AGENTS.md          # AIツールが読み込む
└── .skillport.toml    # 設定ファイル
```

## MCPモード vs CLIモードの選び方

| 特性 | MCPモード | CLIモード |
|------|----------|----------|
| **対応範囲** | 複数プロジェクト | 単一プロジェクト |
| **初期セットアップ** | クライアント設定に1行追加 | `skillport init`が必要 |
| **対応ツール** | Cursor, Copilot, Windsurf等 | シェルコマンド実行環境 |
| **スキル保存場所** | グローバルディレクトリ | プロジェクト内 |
| **更新の影響範囲** | 全プロジェクトに反映 | 該当プロジェクトのみ |
| **向いている場面** | 標準的なスキルを横断利用 | プロジェクト固有のスキル |

### 推奨される使い分け

**MCPモードが向いているケース：**
- 複数のプロジェクトで同じスキルを使う
- チームで標準的なスキルセットを共有
- Codex、Cursor、Copilotなど複数のAIツールを使い分けている

**CLIモードが向いているケース：**
- プロジェクト固有のスキルを使う
- バージョン管理でスキルも含めて管理したい
- シンプルな運用を好む

**併用も可能：**
```bash
# グローバルスキル（MCPモード）
# + プロジェクト固有スキル（CLIモード）

skillport --skills-dir .claude/skills add ./project-specific-skill
skillport doc
```

## スキルの開発について

skillportでは、独自のスキルを作成することもできます。基本的なスキル構造はこんな感じ：

```
my-custom-skill/
├── skill.json          # メタデータ
├── README.md           # 詳細説明
├── scripts/            # 実行スクリプト
│   └── main.py
└── examples/           # 使用例
    └── example.md
```

GitHubリポジトリで公開すれば、`skillport add https://github.com/username/my-custom-skill` で誰でも使えるようになります。

この辺りはまだ試していないのですが、既存のClaude Codeスキルを移行する際に参考になりそうです。


## 使ってみた感想

### 良かったところ

**1. セットアップが本当に簡単だった**

「MCPサーバーの設定」と聞いて少し身構えていましたが、実際には `settings.json` に数行追加するだけでした。これならAIツールを乗り換えるときの心理的ハードルがかなり下がります。

「また設定し直すのか...」という憂鬱から解放されるのは、想像以上に快適でした。

**2. 既存のスキルがそのまま使える**

Claude Codeで使っていたスキルを、特に変換作業なしでCodexでも使えるようになったのは感動的でした。スキルの二重管理から解放されるだけで、日々のストレスがかなり減ります。

### 気になったところ

**1. まだドキュメントが少ない**

リリースされたばかりということもあり、公式ドキュメント以外の情報がほとんどありません。困ったときに「ググって解決」がまだ難しいかもしれません。

**2. スキルエコシステムはこれから**

公式のスキルリポジトリはまだ発展途上で、「すぐに使える便利なスキル」がたくさんあるわけではありません。今後の成長に期待、という感じです。

**3. 内部の仕組みが完全には理解できていない**

「段階的な情報開示」などの仕組みは、概念は理解できるものの、実際にどう動いているのかは正直まだわかっていません。もう少し使い込んでみないと、真価がわからない気がします。

## まとめ

skillportを使ってみて、**複数のAIツールを使い分けている人には確実に刺さるツール**だと感じました。

特に以下のような方は試してみる価値があると思います：

- Claude CodeとCodex（またはCursor、Copilot）を併用している
- プロジェクトごとに異なるAIツールを使い分けている
- スキルの二重管理にうんざりしている

まだリリースされたばかりで、完全に理解できていない部分もありますが、「一度管理すれば、どこでも利用可能」というコンセプトは、AIツールが次々と登場する現状において非常に実用的だと思います。

しばらく使い込んでみて、また気づいたことがあれば追記するかもしれません。

## 参考リンク

- [skillport GitHub リポジトリ](https://github.com/gotalab/skillport)
- [Model Context Protocol (MCP) 仕様](https://modelcontextprotocol.io/)

---

*この記事は skillport v1.0 を基に執筆しています。今後のアップデートで機能や仕様が変更される可能性があります。*
