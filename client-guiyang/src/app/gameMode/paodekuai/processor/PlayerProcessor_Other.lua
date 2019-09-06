local super = require("app.gameMode.base.processor.Processor")
local Constants = require("app.gameMode.paodekuai.core.Constants_Paodekuai")
local PlayType = Constants.PlayType
local CardDefines = require("app.gameMode.paodekuai.core.CardDefines_Paodekuai")
local SoundsInfo = require("app.gameMode.mahjong.core.SoundsInfo")
local PlayerProcessor_Other = class("PlayerProcessor_Other", super)

function PlayerProcessor_Other:ctor(cPos, playerInfo, uiPlayer)
    super.ctor(self)
    self._cPos = cPos
    self._uiPlayer = uiPlayer
    self._playerInfo = playerInfo
end

function PlayerProcessor_Other:updatePlayerInfo(playerInfo)
    self._playerInfo = playerInfo
end

function PlayerProcessor_Other:getPlayerInfo()
    return self._playerInfo
end

function PlayerProcessor_Other:processStep(...)
    super._processStep(self, ...)
end

-- @overwrite
function PlayerProcessor_Other:_checkSelf( step )
    return step:getRoleId() == self._playerInfo.roleId
end

function PlayerProcessor_Other:onGameStarted(battlePlayer, isRecover)
    self._uiPlayer:onGameStarted(battlePlayer, isRecover)
end

function PlayerProcessor_Other:prepareForNextRound()
    self._uiPlayer:prepareForNextRound()
end

function PlayerProcessor_Other:onDiscard(cards)
    Logger.debug("====PROCESSOR DISCARD ---- ID = " .. self._playerInfo.roleId .. " CARDS = " .. table.concat(cards or {}, ","))
    self._uiPlayer:onDiscard(cards)
end

-- 清空操作按钮
function PlayerProcessor_Other:cleanUpOperation()
end

function PlayerProcessor_Other:getUIPlayer()
    return self._uiPlayer
end

local commonSoundMap = {
    -- 三张
    [Constants.PlayType.POKER_DISPLAY_PAI_SAN_PAI] = "three.mp3",
    -- 三带一
    [Constants.PlayType.POKER_DISPLAY_PAI_SAN_DAI_1_ZHANG] = "threeAndOne.mp3",
    -- 三带一对
    [Constants.PlayType.POKER_DISPLAY_PAI_SAN_DAI_1_DUI] = "threeAndTwo.mp3",
    -- 顺子
    [Constants.PlayType.POKER_DISPLAY_PAI_SHUNZI] = "series.mp3",
    [Constants.PlayType.POKER_DISPLAY_PAI_SHUANG_SHUNZI] = "seriesTwo.mp3",
    -- 飞机
    [Constants.PlayType.POKER_DISPLAY_PAI_FEIJI_DAI_CHIBANG] = "plane.mp3",
    -- 炸弹
    [Constants.PlayType.POKER_DISPLAY_PAI_ZHADAN] = "bomb.mp3",
    -- 剩一张
    [Constants.PlayType.POKER_DISPLAY_HANDCARD_WARN] = "onlyOne.mp3",
    -- 不要
    [Constants.PlayType.POKER_OPERATE_PASS] = {"not_1.mp3", "not_2.mp3", "not_3.mp3"},
    -- 管上随机
    ['guangshang'] = {'bigger_1.mp3', 'bigger_2.mp3', 'bigger_3.mp3'}
}

function PlayerProcessor_Other:playCardTypeSound(type, cards, isFristDiscard)
    local cvtValues = CardDefines.convertToSortValue(cards)
    local prePath = ''
    local fileName = ''
    if self._playerInfo.sex == Constants.GenderType.Male then
        prePath = "sound/SFX_Paodekuai/Man/"
    else
        prePath = "sound/SFX_Paodekuai/Woman/"
    end
    if type == Constants.PlayType.POKER_DISPLAY_PAI_DAN_ZHANG then
        fileName = Constants.SFXCONFIG[cvtValues[1]]
    elseif type == Constants.PlayType.POKER_DISPLAY_PAI_DUI_PAI then
        fileName = Constants.SFXCONFIG[cvtValues[1] * 14]
    elseif type == Constants.PlayType.POKER_OPERATE_PASS then
        local temp = commonSoundMap[type]
        fileName = temp[math.random(#temp)]
    else
        if isFristDiscard then
            fileName = commonSoundMap[type]
        else
            local temp = commonSoundMap['guangshang']
            fileName = temp[math.random(#temp)]
        end
    end

    if Macro.assertFalse(fileName ~= nil, 'unknow sound Type' .. type or 'none') then
        local soundPath = prePath .. fileName
        Logger.debug("==== PLAY COMMON SOUND =====")
        Logger.debug("PATH = " .. soundPath)
        manager.AudioManager.getInstance():playEffect(soundPath)
    end
end

function PlayerProcessor_Other:getRoomSeat()
    return self
end

function PlayerProcessor_Other:getSeatUI()
    return self._uiPlayer
end

function PlayerProcessor_Other:getPlayer()
    return self:getPlayerInfo()
end


function PlayerProcessor_Other:dispose()
    -- Logger.debug("dispose name = " .. self._playerInfo:getShortName())
    -- self._uiPlayer:dispose()
    -- UIPlayer 由 UIGameScene dispose
    PlayerProcessor_Other.super.dispose(self)
end

return PlayerProcessor_Other
