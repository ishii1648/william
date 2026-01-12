-- spec/core/plugin_loader_spec.lua
-- plugin_loader.lua のテスト

describe("PluginLoader", function()
    local PluginLoader

    setup(function()
        PluginLoader = require("core.plugin_loader")
    end)

    describe("new()", function()
        it("インスタンスを作成する", function()
            local config = { plugins = {} }
            local loader = PluginLoader.new(config)

            assert.is_not_nil(loader)
            assert.are.same({}, loader.loadedPlugins)
        end)

        it("configを保持する", function()
            local config = { plugins = {"test"}, pluginSettings = {} }
            local loader = PluginLoader.new(config)

            assert.are.equal(config, loader.config)
        end)
    end)

    describe("loadAll()", function()
        local mockPlugin

        before_each(function()
            mockPlugin = {
                initCalled = false,
                initSettings = nil,
                init = function(self, settings)
                    self.initCalled = true
                    self.initSettings = settings
                end,
                getChoices = function() return {} end,
            }
            package.loaded["plugins.mock_plugin"] = mockPlugin
        end)

        after_each(function()
            package.loaded["plugins.mock_plugin"] = nil
        end)

        it("設定されたプラグインをロードする", function()
            local config = {
                plugins = {"mock_plugin"},
                pluginSettings = {
                    mock_plugin = { key = "value" }
                }
            }
            local loader = PluginLoader.new(config)
            local plugins = loader:loadAll()

            assert.are.equal(1, #plugins)
            assert.are.equal("mock_plugin", plugins[1].name)
        end)

        it("プラグインのinitを呼び出す", function()
            local config = {
                plugins = {"mock_plugin"},
                pluginSettings = {
                    mock_plugin = { key = "value" }
                }
            }
            local loader = PluginLoader.new(config)
            loader:loadAll()

            assert.is_true(mockPlugin.initCalled)
            assert.are.same({ key = "value" }, mockPlugin.initSettings)
        end)

        it("pluginSettingsがない場合は空テーブルを渡す", function()
            local config = {
                plugins = {"mock_plugin"},
                pluginSettings = {}
            }
            local loader = PluginLoader.new(config)
            loader:loadAll()

            assert.is_true(mockPlugin.initCalled)
            assert.are.same({}, mockPlugin.initSettings)
        end)

        it("存在しないプラグインは無視する", function()
            local config = {
                plugins = {"nonexistent_plugin"},
                pluginSettings = {}
            }
            local loader = PluginLoader.new(config)
            local plugins = loader:loadAll()

            assert.are.equal(0, #plugins)
        end)

        it("複数プラグインをロードする", function()
            local mockPlugin2 = {
                init = function() end,
            }
            package.loaded["plugins.mock_plugin2"] = mockPlugin2

            local config = {
                plugins = {"mock_plugin", "mock_plugin2"},
                pluginSettings = {}
            }
            local loader = PluginLoader.new(config)
            local plugins = loader:loadAll()

            assert.are.equal(2, #plugins)

            package.loaded["plugins.mock_plugin2"] = nil
        end)

        it("init関数がないプラグインも正常にロードする", function()
            local pluginWithoutInit = {
                getChoices = function() return {} end,
            }
            package.loaded["plugins.no_init_plugin"] = pluginWithoutInit

            local config = {
                plugins = {"no_init_plugin"},
                pluginSettings = {}
            }
            local loader = PluginLoader.new(config)
            local plugins = loader:loadAll()

            assert.are.equal(1, #plugins)
            assert.are.equal("no_init_plugin", plugins[1].name)

            package.loaded["plugins.no_init_plugin"] = nil
        end)
    end)

    describe("get()", function()
        it("ロードされたプラグインを取得する", function()
            local mockPlugin = { init = function() end }
            package.loaded["plugins.test_plugin"] = mockPlugin

            local config = {
                plugins = {"test_plugin"},
                pluginSettings = {}
            }
            local loader = PluginLoader.new(config)
            loader:loadAll()

            local result = loader:get("test_plugin")
            assert.are.equal(mockPlugin, result)

            package.loaded["plugins.test_plugin"] = nil
        end)

        it("存在しないプラグインはnilを返す", function()
            local config = { plugins = {}, pluginSettings = {} }
            local loader = PluginLoader.new(config)

            assert.is_nil(loader:get("nonexistent"))
        end)

        it("ロード前はnilを返す", function()
            local config = {
                plugins = {"some_plugin"},
                pluginSettings = {}
            }
            local loader = PluginLoader.new(config)

            assert.is_nil(loader:get("some_plugin"))
        end)
    end)
end)
