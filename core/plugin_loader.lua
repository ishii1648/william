-- core/plugin_loader.lua
-- プラグインの動的ロードと管理

local PluginLoader = {}
PluginLoader.__index = PluginLoader

--- 新しいPluginLoaderインスタンスを作成
--- @param config table 設定
--- @return table PluginLoaderインスタンス
function PluginLoader.new(config)
    local self = setmetatable({}, PluginLoader)
    self.config = config
    self.loadedPlugins = {}
    return self
end

--- 全プラグインをロード
--- @return table ロードされたプラグインの配列
function PluginLoader:loadAll()
    local plugins = {}

    for _, pluginName in ipairs(self.config.plugins or {}) do
        local ok, plugin = pcall(function()
            return require("plugins." .. pluginName)
        end)

        if ok and plugin then
            -- プラグインの初期化
            if plugin.init then
                plugin:init(self.config.pluginSettings[pluginName] or {})
            end
            plugin.name = pluginName
            table.insert(plugins, plugin)
            self.loadedPlugins[pluginName] = plugin
            print("[My Rancher] Loaded plugin: " .. pluginName)
        else
            print("[My Rancher] Failed to load plugin: " .. pluginName)
            if not ok then
                print("  Error: " .. tostring(plugin))
            end
        end
    end

    return plugins
end

--- プラグインを取得
--- @param name string プラグイン名
--- @return table|nil プラグイン
function PluginLoader:get(name)
    return self.loadedPlugins[name]
end

return PluginLoader
