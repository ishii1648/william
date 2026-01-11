-- .luacheckrc
-- My Rancher - luacheck設定ファイル

-- Hammerspoonのグローバル変数（読み取り専用）
read_globals = {
    "hs",
}

-- 除外するディレクトリ
exclude_files = {
    ".worktrees/**",
}

-- Lua標準ライブラリ
std = "lua54"

-- グローバル設定
max_line_length = 120

-- init.luaではhs.shutdownCallbackへの代入を許可
files["init.lua"] = {
    globals = {
        "hs.shutdownCallback",
    },
}
