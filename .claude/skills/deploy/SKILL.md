---
name: deploy
description: Luaファイル編集後にlint + deployを実行。Use when Lua files (.lua) are edited or modified.
---

worktreeをHammerspoonにデプロイし、静的解析を実行します。

## 実行手順

1. **`make lint` を実行**
2. **warning または error があれば修正**
   - luacheck の出力を確認し、指摘された問題をすべて修正
   - 再度 `make lint` を実行
   - warning 0 になるまで繰り返す
3. **warning 0 を確認後、`make deploy` を実行**
4. **成功したら Hammerspoon をリロードするよう案内**
