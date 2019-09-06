local SoundsInfo = class("SoundsInfo")
local Constants = require("app.gameMode.mahjong.core.Constants")

local instance = nil
function SoundsInfo:ctor()
end

function SoundsInfo:getInstance()
    if instance == nil then
        instance = SoundsInfo.new()
    end
    return instance
end

function SoundsInfo:getSoundBasePath()
    local path = game.service.ChatService.getInstance():getSFXPath()
	return path == nil and  "sound/SFX/" or path
end

function SoundsInfo:getSound(soundKey, gender)
    if gender ~= Constants.GenderType.Male and gender ~= Constants.GenderType.Female then
        Logger.error("无效的性别信息："..gender)
        gender = Constants.GenderType.Male
    end
    local sound = nil
    repeat
        local path = Constants.SFXCONFIG[soundKey]
        if Macro.assertTrue(path == nil 
                or path[gender] == nil 
                or path[gender][1] == nil,
            "SoundError") then
            break
        end
        local basePath = self:getSoundBasePath()
        if Macro.assertTrue(basePath == nil, "SoundError") then
            break
        end
        local _g = Constants.GENDER_PATH[gender] -- 常量里取的应该没问题吧
        sound = string.format("%s%s%s", basePath, _g, path[gender][1])
    until true
    return sound
end

function SoundsInfo:playSound(soundKey, gender)
    local _type = type(soundKey)
    if not Macro.assertFalse(_type == 'number', 'error type of sound key, expected number, got ' .. _type) then
        return
    end

    -- 过滤掉显式没有音效的
    if soundKey == Constants.NONE then
        return
    end

    local sound = self:getSound(soundKey, gender)
    if sound then
        manager.AudioManager.getInstance():playEffect(sound)
    else
        Logger.debug("sound not find !".. soundKey .. " " .. gender)
    end
end

function SoundsInfo:getChatSound()
end

return SoundsInfo