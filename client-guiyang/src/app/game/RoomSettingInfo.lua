local RoomSetting = config.GlobalConfig.getRoomSetting()
local RoomSettingHelper = require("app.game.ui.RoomSettingHelper").RoomSettingHelper
local M = class("RoomSettingInfo")
M.SPECIAL_ITEM_ARRAY = {
    RoomSetting.GamePlay.COMMON_VOICE_OPEN,
    RoomSetting.GamePlay.COMMON_VOICE_CLOSE,
    RoomSetting.GamePlay.COMMON_TING_TIPS_OPEN,
    RoomSetting.GamePlay.COMMON_TING_TIPS_CLOSE,
}

function M:ctor(gameTypeNumberArray, roundCountEnumValue)
    self.gameTypeNumberArray = gameTypeNumberArray
    self.roundCountEnumValue = roundCountEnumValue
    self.roundCountValue = 0
    self:_initENAndZHArray()
end

function M:getNumberValueArray()
    return self.gameTypeNumberArray
end

function M:_initENAndZHArray()
    local zhArray = {}
    local enArray = {}
    local toFindArray = self.gameTypeNumberArray
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    local ruleTypeMap = MultiArea.getRuleType(areaId)[1]
    for _, numValue in ipairs(toFindArray) do
        for enStrKey, setting in pairs(ruleTypeMap) do
            if setting[1] == numValue then
                table.insert(enArray, enStrKey)
                if setting[2] ~= "" then
                    table.insert(zhArray, setting[2])
                end
                break
            end
        end
    end

    if self.roundCountEnumValue then
        --加入局数信息
        local setting = RoomSettingHelper.getRoomRoundSetting(false, self.roundCountEnumValue)
        if setting then
            table.insert(enArray, 2, setting._type)
            table.insert(zhArray, 2, setting._realValue .. '局')
            self.roundCountValue = setting._realValue
        end
    end

    self._zhArray = zhArray
    self._enArray = enArray
end

-- 获取模式相关:极速，不托管，60秒托管等
function M:getModeText()
    -- 判定是否为跑的快
    if table.indexof(self.gameTypeNumberArray, RoomSetting.GamePlay.POKER_GAME_TYPE_PAO_DE_KUAI) then 
        return 
    end 

    -- 获取指定的玩法类型
    local _tab = {
        RoomSetting.GamePlay.COMMON_TRUSTEESHIP_60, RoomSetting.GamePlay.COMMON_TRUSTEESHIP_180,
        RoomSetting.GamePlay.COMMON_TRUSTEESHIP_300, RoomSetting.GamePlay.COMMON_FAST_MODE_OPEN,
    }
    local playType = nil 
    for _, value in pairs(self.gameTypeNumberArray) do 
        if table.indexof(_tab, value) then 
            playType = value 
            break 
        end 
    end 

    if not playType then 
        return "不托管"
    end 

    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    local ruleTypeMap = MultiArea.getRuleType(areaId)[1]
    for enStrKey, setting in pairs(ruleTypeMap) do
        if setting[1] == playType then
            return setting[2]
        end 
    end 
    return 
end 

function M:isRealTimeVoiceOpen()
    local openValue = RoomSetting.GamePlay.COMMON_VOICE_OPEN
    local closeValue = RoomSetting.GamePlay.COMMON_VOICE_CLOSE
    if openValue ~= nil and closeValue ~= nil then
        for _, value in ipairs(self.gameTypeNumberArray) do
            if value == openValue then
                return true
            elseif value == closeValue then
                return false
            end
        end
    end
    return false
end

function M:isRealTimeVoiceSupported()
    -- 若没有即代表不开启
    local openValue = RoomSetting.GamePlay.COMMON_VOICE_OPEN
    local closeValue = RoomSetting.GamePlay.COMMON_VOICE_CLOSE
    return (openValue and closeValue) ~= nil
end

-- 判断玩法中是否有极速模式
function M:isFastModeOpen()
    for _, numValue in ipairs(self.gameTypeNumberArray) do
        if numValue == RoomSetting.GamePlay.COMMON_FAST_MODE_OPEN then
            return true
        end
    end

    return false
end

function M:getRoundCountNumber()
    return self.roundCountValue
end

function M:getENArray()
    return self._enArray
end

function M:getZHArray()
    return self._zhArray
end

function M:getClubRoomInfoShowStartIndex()
    if Macro.assertFalse(RoomSetting.CLUB_ROOM_INFO_SHOW_START_INDEX, 'RoomSetting.lua must contain CLUB_ROOM_INFO_SHOW_START_INDEX') then
        return RoomSetting.CLUB_ROOM_INFO_SHOW_START_INDEX
    end
end

return M