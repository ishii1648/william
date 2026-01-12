---
name: deploy
description: Luaファイル編集後にlint + deployを実行。Use when Lua files (.lua) are edited or modified.
---

worktreeをHammerspoonにデプロイし、静的解析を実行します。

まず、現在のworktree名を特定してください（カレントディレクトリのパスから `.worktrees/` 以降の部分を抽出）。

次に以下を**並列で**実行してください:
- `make lint`
- `make deploy WORKTREE=<worktree名>`

両方成功したらHammerspoonをリロードするよう案内してください。
