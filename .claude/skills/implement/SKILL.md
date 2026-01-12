---
name: implement
description: 実装とテストをセットで行う。Use when implementing new features or modifying existing code.
---

機能実装時は、コードとテストをセットで作成します。

## 実行手順

1. **実装を行う**
   - 要求された機能を実装
2. **対応するテストを作成/更新**
   - `spec/` ディレクトリに `_spec.lua` ファイルを作成
   - 既存テストがあれば更新
   - Hammerspoon依存（hs API）のモジュールはテスト対象外
3. **`make test` を実行**
   - テストが通ることを確認
   - 失敗したら修正
4. **完了後は `/deploy` を実行するよう案内**
