-- core/chooser.lua
-- hs.chooserのラッパークラス

local Chooser = {}
Chooser.__index = Chooser

--- 新しいChooserインスタンスを作成
--- @param opts table {config: table, onSelect: function, onQueryChange: function}
--- @return table Chooserインスタンス
function Chooser:new(opts)
    local self = setmetatable({}, Chooser)
    self.config = opts.config or {}
    self.onSelect = opts.onSelect
    self.onQueryChange = opts.onQueryChange

    -- hs.chooserインスタンスを作成
    self.hsChooser = hs.chooser.new(function(choice)
        if self.onSelect then
            self.onSelect(choice)
        end
    end)

    -- UI設定を適用
    self:applyConfig()

    return self
end

--- 設定を適用
function Chooser:applyConfig()
    local c = self.hsChooser
    local cfg = self.config

    c:placeholderText(cfg.placeholder or "Search...")
    c:rows(cfg.rows or 10)
    c:searchSubText(cfg.searchSubText ~= false)

    if cfg.darkMode then
        c:bgDark(true)
        c:fgColor({hex = "#FFFFFF"})
        c:subTextColor({hex = "#AAAAAA"})
    end

    if cfg.width then
        c:width(cfg.width)
    end

    -- クエリ変更時のコールバック
    c:queryChangedCallback(function(query)
        if self.onQueryChange then
            self.onQueryChange(query)
        end
    end)
end

--- 候補を設定
--- @param choices table 候補の配列
function Chooser:setChoices(choices)
    self.hsChooser:choices(choices)
end

--- 表示
function Chooser:show()
    self.hsChooser:query("")
    self.hsChooser:show()
end

--- 非表示
function Chooser:hide()
    self.hsChooser:hide()
end

--- 表示中かどうか
--- @return boolean
function Chooser:isVisible()
    return self.hsChooser:isVisible()
end

--- 選択中の行インデックスを取得（1始まり）
--- @return number
function Chooser:selectedRow()
    return self.hsChooser:selectedRow()
end

--- 選択行を設定
--- @param row number 行インデックス（1始まり）
function Chooser:setSelectedRow(row)
    self.hsChooser:selectedRow(row)
end

return Chooser
