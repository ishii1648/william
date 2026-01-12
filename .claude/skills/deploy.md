---
description: Luaファイル編集後にlint + deployを実行
---

worktreeをHammerspoonにデプロイし、静的解析を実行します。

1. `make lint` で静的解析を実行
2. `make deploy WORKTREE=feat/ghq` でデプロイ

両方成功したらHammerspoonをリロードするよう案内してください。
