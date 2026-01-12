# william

Hammerspoonで動作するシンプルなランチャーアプリ

## 概要

Alfredのようなランチャーを最小限の機能で自作したもの。Luaスクリプトによるプラグイン形式で機能を追加できる。

### 機能

- **アプリランチャー**: インストール済みアプリケーションを検索・起動
- **ghqプラグイン**: `gh`プレフィックスでghqリポジトリを検索し、Ghosttyで開く（Shift+EnterでGitHubページを開く）

## セットアップ

### 必要なもの

- [Hammerspoon](https://www.hammerspoon.org/)

### インストール

```bash
# Hammerspoonをインストール
brew install hammerspoon --cask

# hs CLIをインストール（Hammerspoonメニュー → Install CLI）
# または手動で:
# sudo ln -s /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs /usr/local/bin/hs

# リポジトリをクローン
ghq get github.com/ishii1648/william
# または
git clone https://github.com/ishii1648/william.git

# ~/.hammerspoonにデプロイ（Hammerspoonも自動リロード）
./scripts/deploy.sh
```

## 使い方

デフォルトのホットキー `Cmd + Shift + Space` でランチャーを起動。

| プレフィックス | 機能 |
|---------------|------|
| (なし) | アプリケーション検索 |
| `gh` | ghqリポジトリ検索 |

## 設定

`config.lua` を編集してカスタマイズできる。

```lua
return {
    -- ホットキー設定
    hotkey = {
        mods = {"cmd", "shift"},
        key = "space",
    },

    -- UI設定
    ui = {
        placeholder = "Search...",
        rows = 10,
        width = 40,
        darkMode = true,
    },

    -- 有効なプラグイン
    plugins = {
        "app_launcher",
        "ghq",
    },
}
```

## プラグイン追加

`plugins/` ディレクトリにLuaファイルを追加し、`config.lua` の `plugins` に登録する。

プラグインは以下のインターフェースを実装する:

```lua
local MyPlugin = {}

-- 候補を返す
function MyPlugin:getChoices(query, settings)
    return {
        { text = "Item", subText = "Description" }
    }
end

-- 選択時のアクション
function MyPlugin:execute(choice, settings)
    -- 実行処理
end

return MyPlugin
```
