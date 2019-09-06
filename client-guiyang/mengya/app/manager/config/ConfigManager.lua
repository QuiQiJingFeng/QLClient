local Util = app.Util

local ConfigManager = class("ConfigManager")

local _instance = nil
function ConfigManager:getInstance()
    if _instance then
        return _instance
    end
    _instance = ConfigManager.new()
    return _instance
end

function ConfigManager:ctor()
    self._gamePlayRuleConfig = {}
    self._headFrameShopData = table.values(Util:parseCsvWithPath('res/mengya/configs/frames.csv'))
    self._roomSettingConfig = Util:parseCsvWithPath('res/mengya/configs/roomsetting.csv')
end

function ConfigManager:getHeadFrameShopData()
    return self._headFrameShopData
end

function ConfigManager:getRoomSettingConfig(key)
    local data = self._roomSettingConfig[key]
    if not data then
        assert(data)
    end
    
    return data
end

function ConfigManager:getGamePlayRuleById(id)
    if self._gamePlayRuleConfig[id] then
        return self._gamePlayRuleConfig[id]
    end

    local data = Util:parseCsvWithPath('res/mengya/configs/gameplays/'..tostring(id)..".csv")
    self._gamePlayRuleConfig[id] = data
    return data
end


return ConfigManager