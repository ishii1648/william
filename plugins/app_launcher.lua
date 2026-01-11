-- plugins/app_launcher.lua
-- インストール済みアプリケーションの起動

local fuzzy = require("utils.fuzzy")

local AppLauncher = {}
AppLauncher.__index = AppLauncher

-- キャッシュ
local cachedApps = nil
local cacheTime = nil
local CACHE_TTL = 300 -- 5分

--- 初期化
--- @param settings table プラグイン設定
function AppLauncher:init(settings)
    self.settings = settings
    cachedApps = nil
end

--- アプリ一覧を取得
--- @return table アプリ情報の配列
function AppLauncher:getApps()
    local now = os.time()

    -- キャッシュが有効ならそれを返す
    if cachedApps and cacheTime and (now - cacheTime) < CACHE_TTL then
        return cachedApps
    end

    local apps = {}
    local paths = self.settings.paths or {"/Applications", "/System/Applications"}

    for _, basePath in ipairs(paths) do
        -- チルダを展開
        local expandedPath = basePath:gsub("^~", os.getenv("HOME"))

        -- .appファイルを検索
        local output, status = hs.execute("find '" .. expandedPath .. "' -maxdepth 2 -name '*.app' -type d 2>/dev/null")

        if status then
            for appPath in output:gmatch("[^\n]+") do
                local appName = appPath:match("([^/]+)%.app$")
                if appName then
                    local bundleInfo = hs.application.infoForBundlePath(appPath)
                    local bundleID = bundleInfo and bundleInfo.CFBundleIdentifier
                    table.insert(apps, {
                        name = appName,
                        path = appPath,
                        bundleID = bundleID,
                        icon = bundleID and hs.image.imageFromAppBundle(bundleID),
                    })
                end
            end
        end
    end

    cachedApps = apps
    cacheTime = now
    return apps
end

--- 候補を返す
--- @param query string 検索クエリ
--- @param settings table プラグイン設定
--- @return table 候補の配列
function AppLauncher:getChoices(query, settings)
    self.settings = settings
    local apps = self:getApps()
    local choices = {}

    for _, app in ipairs(apps) do
        local score = 100

        if query and query ~= "" then
            local match, matchScore = fuzzy.match(query, app.name)
            if not match then
                goto continue
            end
            score = matchScore
        end

        table.insert(choices, {
            text = app.name,
            subText = app.path,
            image = app.icon,
            score = score,
            appPath = app.path,
            appName = app.name,
        })

        ::continue::
    end

    return choices
end

--- 選択時のアクション
--- @param choice table 選択された候補
--- @param settings table プラグイン設定
function AppLauncher:execute(choice, settings)
    if choice.appName then
        hs.application.launchOrFocus(choice.appName)
    end
end

return AppLauncher
