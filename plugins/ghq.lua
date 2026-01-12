-- plugins/ghq.lua
-- ghqリポジトリの検索とGitHubページの表示

local fuzzy = require("utils.fuzzy")

local Ghq = {}
Ghq.__index = Ghq

-- このプラグインを排他的に使用するプレフィックス
Ghq.prefix = "gh"

-- キャッシュ（5分TTL）
local cachedRepos = nil
local cacheTime = nil
local CACHE_TTL = 300

-- ghqコマンドのパス
local GHQ_PATH = "/usr/local/bin/ghq"

--- 初期化
--- @param settings table プラグイン設定
function Ghq:init(settings)
    self.settings = settings
    cachedRepos = nil
end

--- ghq rootのパスを取得
--- @return string|nil ghq rootパス
function Ghq.getGhqRoot()
    local output, status = hs.execute("cd ~ && " .. GHQ_PATH .. " root", true)
    if status then
        return output:gsub("\n$", "")
    end
    return nil
end

--- リポジトリ一覧を取得
--- @return table リポジトリ情報の配列
function Ghq.getRepos()
    local now = os.time()

    -- キャッシュが有効ならそれを返す
    if cachedRepos and cacheTime and (now - cacheTime) < CACHE_TTL then
        return cachedRepos
    end

    local repos = {}
    local output, status = hs.execute("cd ~ && " .. GHQ_PATH .. " list", true)

    if status then
        local ghqRoot = Ghq.getGhqRoot()

        for repoPath in output:gmatch("[^\n]+") do
            -- repoPath例: "github.com/owner/repo"
            local host, owner, name = repoPath:match("([^/]+)/([^/]+)/([^/]+)$")

            if host and owner and name then
                table.insert(repos, {
                    path = repoPath,
                    host = host,
                    owner = owner,
                    name = name,
                    displayName = owner .. "/" .. name,
                    fullPath = ghqRoot and (ghqRoot .. "/" .. repoPath) or nil,
                })
            end
        end
    end

    cachedRepos = repos
    cacheTime = now
    return repos
end

--- 候補を返す
--- @param query string 検索クエリ
--- @param settings table プラグイン設定
--- @return table 候補の配列
function Ghq:getChoices(query, settings)
    self.settings = settings

    -- 先頭の空白を除去
    local trimmedQuery = (query or ""):gsub("^%s+", "")

    -- "gh"で始まらない場合は候補を返さない
    if trimmedQuery == "" or not trimmedQuery:lower():match("^gh") then
        return {}
    end

    -- "gh"以降の部分を検索クエリとして使用（先頭空白除去）
    local searchQuery = trimmedQuery:sub(3):gsub("^%s+", "")
    local repos = Ghq.getRepos()
    local choices = {}

    for _, repo in ipairs(repos) do
        local score = 100
        local shouldAdd = true

        if searchQuery and searchQuery ~= "" then
            local match, matchScore = fuzzy.match(searchQuery, repo.displayName)
            if match then
                score = matchScore
            else
                shouldAdd = false
            end
        end

        if shouldAdd then
            -- GitHub URLを構築（github.com以外のホストは対象外）
            local githubUrl = nil
            if repo.host == "github.com" then
                githubUrl = "https://github.com/" .. repo.owner .. "/" .. repo.name
            end

            table.insert(choices, {
                text = repo.displayName,
                subText = repo.path,
                score = score,
                repoPath = repo.path,
                githubUrl = githubUrl,
                fullPath = repo.fullPath,
            })
        end
    end

    return choices
end

--- 選択時のアクション
--- @param choice table 選択された候補
--- @param _settings table プラグイン設定
function Ghq.execute(_self, choice, _settings)
    if not choice then return end

    -- 修飾キーを確認
    local mods = hs.eventtap.checkKeyboardModifiers()

    if mods.shift and choice.githubUrl then
        -- Shift+Enter: GitHubページを開く
        hs.urlevent.openURL(choice.githubUrl)
    end
    -- 通常のEnter: 何もしない
end

return Ghq
