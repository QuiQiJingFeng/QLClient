--[[	单个玩家的总分
]]
local super = require("app.gameMode.base.core.commands.Command_PlayerProcessor_Base")
local Constants = require "app.gameMode.paodekuai.core.Constants_Paodekuai"
local TipsHelper = require("app.gameMode.paodekuai.utils.TipsHelper")

local Command_CanOptions = class("Command_CanOptions", super)
function Command_CanOptions:ctor(args)
    self.super.ctor(self, args)
    -- self._localRoleId = game.service.LocalPlayerService:getInstance():getRoleId()
end

function Command_CanOptions:execute(args)
    self._processor:getUIPlayer():setPassVisible(false)
    self:filterOperation(self._stepGroup)
    self:filterCountDown()
end

function Command_CanOptions:filterCountDown()
    -- 其他的processor停止
    local playerMap = game.service.RoomService:getInstance():getPlayerMap()
    for idx, playerInfo in pairs(playerMap) do
        local roleId = playerInfo.roleId
        local processor = gameMode.mahjong.Context:getInstance():getGameService():getPlayerProcessorByPlayerId(roleId)
        local isEnable = processor == self._processor
        processor:getUIPlayer():setCounDownEnable(isEnable)
    end
end

function Command_CanOptions:filterOperation(stepGroup)
    local isReplay = gameMode.mahjong.Context.getInstance():getGameService():isInReplay()
    local isWatcher = game.service.LocalPlayerService:getInstance():isWatcher()
    if isReplay or isWatcher then
        return
    end

    if self._processor:getPlayerInfo().cPosition ~= 1 then
        Logger.debug("====filterOperation====")
        Logger.debug("====PROCESSOR CPOS ~= 1, RETURN")
        return
    end

    local uiTableOptions = self._processor:getUITableOptions()
    for idx, step in ipairs(stepGroup) do
        local playType = step:getPlayType()
        local roleId = step:getRoleId()
        -- 1、出牌 2、过
        if playType == Constants.PlayType.POKER_OPERATE_CAN_PASS then
            Logger.debug("====CAN_OPTIONS --- ADD PASS")
            uiTableOptions:addValue('pass')
        elseif playType == Constants.PlayType.POKER_OPERATE_CAN_PLAY_A_CARD then
            Logger.debug("====CAN_OPTIONS --- ADD DISCARD")
            uiTableOptions:addValue('discard')
            -- 清空自己已经出的牌
            self._processor:onDiscard({})
        end
    end
    local lastDiscardRoleId = gameMode.mahjong.Context:getInstance():getGameService():getLastDiscardInfo().roleId
    if lastDiscardRoleId ~= nil and lastDiscardRoleId ~= self._processor:getPlayerInfo().roleId then
        uiTableOptions:addValue('tips')
        Logger.debug("====CAN_OPTIONS --- ADD TIPS")
    end
end

return Command_CanOptions