---
title: "個人用とクライアント用の Claude Code を併用する方法 - devcontainer + ボリューム分離で安全に"
emoji: "🔐"
type: "tech"
topics: ["claudecode", "devcontainer", "docker", "security", "freelance"]
published: false
---

## この記事を読むべき人

- フリーランスエンジニア・コンサルタント
- 複数のクライアントプロジェクトを抱えている開発者
- 個人プロジェクトとクライアントワークを両立している人
- Claude Code を安全に使いたいと考えている人

## よくある困りごと

### シナリオ 1: 「誤って個人アカウントでクライアントコードにアクセスしてしまった...」

あなたは個人の趣味プロジェクトで Claude Code を使っていました。ある日、クライアントワークで Claude Code を起動したら、同じアカウントでログインされていました。

**問題点**:
- 個人アカウントの会話履歴にクライアントの機密コードが混ざる
- API 使用料金の請求を分けられない
- クライアントに「個人アカウントでアクセスしました」と報告しにくい
- 監査やコンプライアンスの観点で問題になる可能性

### シナリオ 2: 「クライアント A のコードがクライアント B の Claude セッションに...」

複数のクライアントプロジェクトを同時進行中。Claude Code でクライアント A のプロジェクトを作業後、クライアント B のプロジェクトに切り替えたら、同じセッションが続いていました。

**問題点**:
- クライアント A のコードや設計がクライアント B のセッションに残る
- 誤って別クライアントの情報を参照してしまう
- セキュリティ違反のリスク
- NDA（秘密保持契約）違反の可能性

### シナリオ 3: 「環境変数やAPI キーを見られたくない...」

Claude Code に `.env` ファイルを見られたくないが、毎回確認するのは面倒。うっかりアクセス許可してしまい、機密情報が Claude のログに残ってしまった。

**問題点**:
- データベースパスワードや API キーの漏洩リスク
- 一度許可すると記録に残る
- クライアントへの説明責任が果たせない

## この記事の解決策: devcontainer + ボリューム分離

これらの問題を**技術的に完全に解決**する方法を紹介します。

### 解決策の全体像

```
個人プロジェクト
  → ローカルでは Claude Code を使わない（リスク回避）

クライアント A（例: client-a）
  → 専用の devcontainer
  → 専用のボリューム（claude-client-a）
  → クライアント A のアカウントでログイン
  → セキュリティポリシー適用

クライアント B（例: 別の会社）
  → 専用の devcontainer
  → 専用のボリューム（claude-client-b）
  → クライアント B のアカウントでログイン
  → セキュリティポリシー適用
```

**重要なポイント**: 各クライアントは**物理的に隔離された環境**で動作します。

## なぜこの方法が優れているのか

### 1. 完全な隔離 = 混ざらない保証

**devcontainer とは**:
- Docker コンテナ内で開発環境を動かす仕組み
- 各プロジェクトが**別々の仮想マシン**のように動作
- クライアント A のコンテナからクライアント B のファイルに物理的にアクセスできない

**ボリューム分離とは**:
- Claude Code の認証情報やセッション履歴を保存する場所
- `claude-client-a` と `claude-client-b` は**完全に別の場所**
- 一方のセッションが他方に影響することは**技術的に不可能**

### 2. セキュリティポリシーの強制

devcontainer を使うと、Claude Code が**何にアクセスできるか**を厳密に制御できます。

**.claude/settings.json で制御できること**:

```json
{
  "permissions": {
    "deny": [
      "Read(./.env*)",
      "Read(./secrets/**)",
      "Read(~/.ssh/**)",
      "Bash(curl:*)",
      "Bash(git push:--force)"
    ],
    "ask": [
      "Bash(git:*)",
      "Bash(yarn:add*)",
      "Bash(rm:*)"
    ]
  }
}
```

### 3. 請求の透明性

各クライアント専用のアカウントを使うことで、API 使用量がアカウントごとに完全に分離されます。

### 4. 監査証跡の明確化

**ボリューム = アカウント = プロジェクト** という対応関係で、監査やセキュリティレビューに対応しやすくなります。

## 使い方: 2つの方法

devcontainer を使う方法は2つあります。

### 方法 1: VS Code 拡張機能

VS Code には **Dev Containers 拡張機能**（旧 Remote - Containers）が用意されています。

1. VS Code に「Dev Containers」拡張機能をインストール
2. プロジェクトに `.devcontainer/devcontainer.json` を配置
3. コマンドパレットから「Dev Containers: Reopen in Container」を実行
4. コンテナ内で Claude Code 拡張機能を使用

VS Code ユーザーには最も馴染みやすい方法です。

### 方法 2: devcontainer CLI

ターミナルから直接操作したい場合は **devcontainer CLI** を使います。

```bash
# インストール
npm install -g @devcontainers/cli

# コンテナを起動
devcontainer up --workspace-folder .

# コンテナ内に入る
devcontainer exec --workspace-folder . zsh

# Claude Code を起動
claude
```

エディタに依存しないので、Vim/Neovim ユーザーや複数エディタを使い分ける人に便利です。

## セットアップ

### ステップ 1: 前提条件

- Docker Desktop がインストールされていること
- VS Code + Dev Containers 拡張機能、または devcontainer CLI

### ステップ 2: devcontainer.json を作成

プロジェクトに `.devcontainer/devcontainer.json` を作成します。

```json
{
  "name": "Client A Project",
  "image": "mcr.microsoft.com/devcontainers/javascript-node:20",

  "mounts": [
    "source=claude-client-a,target=/home/node/.claude,type=volume",
    "source=${localEnv:HOME}/.gitconfig,target=/home/node/.gitconfig,type=bind,consistency=cached"
  ],

  "postCreateCommand": "sudo chown -R node:node /home/node/.claude && npm install -g @anthropic-ai/claude-code",

  "remoteUser": "node"
}
```

**ポイント**: `source=claude-client-a` のボリューム名をクライアントごとに変更します。

### ステップ 3: 起動

**VS Code の場合**:
コマンドパレット → 「Dev Containers: Reopen in Container」

**CLI の場合**:
```bash
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . zsh
claude
```

初回起動時に Claude Code にログインすると、認証情報がボリュームに保存されます。

### ステップ 4: 別のクライアントを追加

新しいクライアントのプロジェクトでは、ボリューム名を変更するだけです。

```json
{
  "mounts": [
    "source=claude-client-acme,target=/home/node/.claude,type=volume"
  ]
}
```

## セキュリティ設定

`.claude/settings.json` で Claude Code のアクセス権限を制御できます。

```json
{
  "permissions": {
    "deny": [
      "Read(./.env*)",
      "Read(./secrets/**)",
      "Read(~/.ssh/**)",
      "Read(~/.aws/**)",
      "Bash(curl:*)",
      "Bash(wget:*)",
      "Bash(git push:--force)"
    ],
    "ask": [
      "Bash(git:*)",
      "Bash(yarn:add*)",
      "Bash(rm:*)"
    ]
  }
}
```

- **deny**: 完全にブロック（確認なしで拒否）
- **ask**: 実行前に確認が入る

## 日常的な使い方

```bash
# クライアント A で作業
cd ~/projects/client-a
devcontainer exec --workspace-folder . zsh
claude

# クライアント B で作業（別ターミナル）
cd ~/projects/client-b
devcontainer exec --workspace-folder . zsh
claude
```

両方のコンテナが同時に動作しても、互いに干渉しません。

## ボリューム管理

```bash
# 全てのクライアント用ボリュームを確認
docker volume ls | grep claude-client

# 認証情報をリセットしたい場合
docker volume rm claude-client-a
```

## まとめ

- **完全な隔離**: クライアント間で情報が混ざることが技術的に不可能
- **セキュリティ**: 環境変数や SSH キーを Claude から保護
- **請求の透明性**: アカウントごとに API 使用量が分離
- **監査証跡**: どのプロジェクトでどのアカウントを使ったか明確

VS Code の Dev Containers 拡張機能か devcontainer CLI を使って、安全にクライアントワークを進めましょう。
