---
name: deploy
description: Luaファイル編集後にlint + deployを実行。Use when Lua files (.lua) are edited or modified.
---

worktreeをHammerspoonにデプロイし、静的解析を実行します。

以下を**並列で**実行してください:
- `make lint`
- `make deploy WORKTREE=feat/ghq`

両方成功したらHammerspoonをリロードするよう案内してください。
