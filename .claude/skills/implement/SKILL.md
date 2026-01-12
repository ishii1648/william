---
name: implement
description: 機能追加・コード修正時に必ず使用。実装・テスト作成・lint・deployまで一貫して行う。MUST use when implementing features or modifying code.
---

機能実装時は、コード作成からデプロイまで一貫して行います。
テストは別エージェントが作成し、実装者のバイアスを排除します。

## 実行手順

1. **実装を行う**
   - 要求された機能を実装

2. **テスト作成エージェントを起動**
   - Task tool で別エージェントを起動
   - 以下の情報を渡す:
     - モジュール名/関数名
     - 公開インターフェース（引数、戻り値）
     - 期待される振る舞いの概要
   - Hammerspoon依存（hs API）のモジュールはテスト対象外

3. **`make lint` を実行**
   - luacheck の出力を確認
   - warning または error があれば修正
   - warning 0 になるまで繰り返す

4. **`make test` を実行**
   - テストが通ることを確認
   - 失敗したら実装またはテストを修正

5. **`make deploy` を実行**
   - Hammerspoon へデプロイ
