-- config.lua
-- ユーザー設定ファイル

return {
    -- ランチャー起動のショートカットキー
    -- mods: 修飾キーの配列 ("cmd", "alt", "ctrl", "shift")
    -- key: メインキー
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
        searchSubText = true,
    },

    -- 有効なプラグイン（読み込み順序）
    plugins = {
        "app_launcher",
    },

    -- プラグイン固有の設定
    pluginSettings = {
        app_launcher = {
            paths = {
                "/Applications",
                "/System/Applications",
                "~/Applications",
            },
        },
    },
}
