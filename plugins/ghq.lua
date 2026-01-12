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

--- Ghosttyをアクティベート
--- @return boolean 成功したかどうか
function Ghq.focusGhostty()
    -- 少し遅延してからアクティベート（ランチャーが閉じた後）
    hs.timer.doAfter(0.1, function()
        hs.application.open("Ghostty")
    end)
    return true
end

--- AppleScript経由でGhosttyの新規タブを作成しcdコマンドを実行
--- @param targetPath string 移動先のパス
function Ghq.openNewGhosttyTab(targetPath)
    -- パス内のシングルクォートをエスケープ
    local escapedPath = targetPath:gsub("'", "'\\''")
    local cdCommand = "cd '" .. escapedPath .. "'"

    -- クリップボード経由でコマンドを送信（日本語入力モード対策）
    local script = string.format([[
        set the clipboard to "%s"
        tell application "Ghostty"
            activate
        end tell
        delay 0.1
        tell application "System Events"
            tell process "Ghostty"
                keystroke "t" using command down
                delay 0.3
                keystroke "v" using command down
                delay 0.1
                keystroke return
            end tell
        end tell
    ]], cdCommand)

    hs.osascript.applescript(script)
end

--- Ghosttyで対象パスを開く（非同期）
--- 既存タブがあればフォーカス、なければ新規タブ作成
--- @param targetPath string 対象のパス
function Ghq.openInGhostty(targetPath)
    -- Ghosttyが起動していない場合は新規タブを作成
    local ghostty = hs.application.find("Ghostty")
    if not ghostty then
        Ghq.openNewGhosttyTab(targetPath)
        return
    end

    -- 非同期でシェルプロセスのcwdを取得（fish, zsh, bash対応）
    local script = [[
        for pid in $(pgrep -x fish 2>/dev/null) $(pgrep -x zsh 2>/dev/null) $(pgrep -x bash 2>/dev/null); do
            lsof -p "$pid" 2>/dev/null | grep cwd | awk '{print $NF}'
        done
    ]]

    local task = hs.task.new("/bin/sh", function(exitCode, stdout, _stderr)
        if exitCode ~= 0 or not stdout or stdout == "" then
            Ghq.openNewGhosttyTab(targetPath)
            return
        end

        -- cwdリストをパース
        local found = false
        for cwd in stdout:gmatch("[^\n]+") do
            if cwd == targetPath then
                found = true
                break
            end
        end

        if found then
            Ghq.focusGhostty()
        else
            Ghq.openNewGhosttyTab(targetPath)
        end
    end, {"-c", script})

    if task then
        task:start()
    end
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
    else
        -- Enter: Ghosttyで開く（非同期）
        if choice.fullPath then
            Ghq.openInGhostty(choice.fullPath)
        end
    end
end

return Ghq
