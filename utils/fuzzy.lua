-- utils/fuzzy.lua
-- シンプルなファジーマッチングユーティリティ

local M = {}

--- クエリがターゲット文字列にファジーマッチするか判定
--- @param query string ユーザー入力
--- @param target string マッチ対象
--- @return boolean マッチしたか
--- @return number スコア（高いほど良いマッチ）
function M.match(query, target)
    if not query or query == "" then
        return true, 100
    end

    query = query:lower()
    target = target:lower()

    -- 完全一致
    if target == query then
        return true, 1000
    end

    -- 前方一致
    if target:sub(1, #query) == query then
        return true, 500 + (100 - #target)
    end

    -- 部分一致
    local pos = target:find(query, 1, true)
    if pos then
        return true, 300 - pos
    end

    -- 文字順序マッチ（ファジー）
    local queryIdx = 1
    local matchCount = 0
    local consecutiveBonus = 0
    local lastMatchIdx = 0

    for i = 1, #target do
        if queryIdx <= #query and target:sub(i, i) == query:sub(queryIdx, queryIdx) then
            matchCount = matchCount + 1
            if i == lastMatchIdx + 1 then
                consecutiveBonus = consecutiveBonus + 10
            end
            lastMatchIdx = i
            queryIdx = queryIdx + 1
        end
    end

    if queryIdx > #query then
        local score = 100 + matchCount * 10 + consecutiveBonus - (#target - matchCount)
        return true, score
    end

    return false, 0
end

return M
