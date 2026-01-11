-- core/launcher.lua
-- ランチャーのメインコントローラー

local Chooser = require("core.chooser")
local Hotkey = require("core.hotkey")
local PluginLoader = require("core.plugin_loader")

local Launcher = {}
Launcher.__index = Launcher

--- 新しいLauncherインスタンスを作成
--- @param config table 設定
--- @return table Launcherインスタンス
function Launcher:new(config)
    local self = setmetatable({}, Launcher)
    self.config = config
    self.chooser = nil
    self.hotkey = nil
    self.pluginLoader = nil
    self.plugins = {}
    return self
end

--- ランチャーを開始
function Launcher:start()
    -- プラグインをロード
    self.pluginLoader = PluginLoader:new(self.config)
    self.plugins = self.pluginLoader:loadAll()

    -- Chooserを初期化
    self.chooser = Chooser:new({
        config = self.config.ui,
        onSelect = function(choice) self:handleSelection(choice) end,
        onQueryChange = function(query) self:handleQueryChange(query) end,
    })

    -- ホットキーをバインド
    self.hotkey = Hotkey:new(self.config.hotkey, function()
        self:toggle()
    end)
    self.hotkey:enable()

    hs.notify.new({title = "My Rancher", informativeText = "Launcher ready!"}):send()
end

--- ランチャーを停止
function Launcher:stop()
    if self.hotkey then
        self.hotkey:disable()
    end
    if self.chooser then
        self.chooser:hide()
    end
end

--- 表示/非表示を切り替え
function Launcher:toggle()
    if self.chooser:isVisible() then
        self.chooser:hide()
    else
        self:show()
    end
end

--- ランチャーを表示
function Launcher:show()
    local choices = self:collectChoices("")
    self.chooser:setChoices(choices)
    self.chooser:show()
end

--- クエリ変更時の処理
--- @param query string 検索クエリ
function Launcher:handleQueryChange(query)
    local choices = self:collectChoices(query)
    self.chooser:setChoices(choices)
end

--- 全プラグインから候補を収集
--- @param query string 検索クエリ
--- @return table 候補の配列
function Launcher:collectChoices(query)
    local allChoices = {}

    for _, plugin in ipairs(self.plugins) do
        if plugin.getChoices then
            local choices = plugin:getChoices(query, self.config.pluginSettings[plugin.name] or {})
            for _, choice in ipairs(choices) do
                choice.plugin = plugin.name
                table.insert(allChoices, choice)
            end
        end
    end

    -- スコアでソート（高い順）
    table.sort(allChoices, function(a, b)
        return (a.score or 0) > (b.score or 0)
    end)

    return allChoices
end

--- 選択時の処理
--- @param choice table 選択された候補
function Launcher:handleSelection(choice)
    if not choice then return end

    for _, plugin in ipairs(self.plugins) do
        if plugin.name == choice.plugin and plugin.execute then
            plugin:execute(choice, self.config.pluginSettings[plugin.name] or {})
            break
        end
    end
end

return Launcher
