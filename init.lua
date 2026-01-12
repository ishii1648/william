-- init.lua
-- Hammerspoonが最初に読み込むエントリーポイント

local config = require("config")
local Launcher = require("core.launcher")

-- ランチャーインスタンスを作成
local launcher = Launcher.new(config)

-- 初期化
launcher:start()

-- リロード時のクリーンアップ
hs.shutdownCallback = function()
    launcher:stop()
end
