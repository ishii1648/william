---
name: deploy
description: Luaファイル編集後に必ず実行。lint + deployを行う。MUST run after editing any .lua files.
---

worktreeをHammerspoonにデプロイし、静的解析を実行します。

## 実行手順

1. **`make lint` を実行**
2. **warning または error があれば修正**
   - luacheck の出力を確認し、指摘された問題をすべて修正
   - 再度 `make lint` を実行
   - warning 0 になるまで繰り返す
3. **`make test` を実行**
   - テストが通ることを確認
   - 失敗したら修正
4. **lint と test が通ったら `make deploy` を実行**
5. **成功したら Hammerspoon をリロードするよう案内**
