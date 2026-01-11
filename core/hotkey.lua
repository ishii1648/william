-- core/hotkey.lua
-- ホットキーの管理

local Hotkey = {}
Hotkey.__index = Hotkey

--- 新しいHotkeyインスタンスを作成
--- @param config table {mods: string[], key: string}
--- @param callback function ホットキー押下時のコールバック
--- @return table Hotkeyインスタンス
function Hotkey:new(config, callback)
    local self = setmetatable({}, Hotkey)

    self.mods = config.mods or {"cmd", "alt"}
    self.key = config.key or "space"
    self.callback = callback
    self.hsHotkey = nil

    return self
end

--- ホットキーを有効化
function Hotkey:enable()
    if self.hsHotkey then
        self.hsHotkey:enable()
    else
        self.hsHotkey = hs.hotkey.bind(
            self.mods,
            self.key,
            self.callback
        )
    end
end

--- ホットキーを無効化
function Hotkey:disable()
    if self.hsHotkey then
        self.hsHotkey:disable()
    end
end

--- ホットキーを削除
function Hotkey:delete()
    if self.hsHotkey then
        self.hsHotkey:delete()
        self.hsHotkey = nil
    end
end

return Hotkey
