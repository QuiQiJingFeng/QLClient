--[[
玩家自动打牌状态
--]]

local super = require("app.gameMode.mahjong.processor.playerFSM.PlayerStateBase")
local PlayerState_AutoDiscard = class("PlayerState_AutoDiscard",super)

function PlayerState_AutoDiscard:ctor( parent ,stateMachine)
    super.ctor(self, parent, stateMachine)
    self._name = "PlayerState_AutoDiscard"

    self._processor = stateMachine:getPlayer() or {}
end

function PlayerState_AutoDiscard:enter()
    super.enter(self)
     -- 取出所有手牌中没有蒙灰的牌 蒙灰
    self.unMaskCardList = {}
    if self._processor:getCardList().handCards == nil then
        return 
    end
    if self._processor:getRobot() ~= nil then
        self._processor:getRobot():onStartAutoStatus()
    end
    -- table.foreach(self._processor:getCardList().handCards,function (k,v)
    --     v:disableTouch()
    -- end)
    UIManager:getInstance():show("UIAutoDiscardTips")
    game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = true})	
end

function PlayerState_AutoDiscard:exit()
    super.exit(self)
    -- 取出之前所有手牌中没有蒙灰的牌 解除蒙灰
    -- table.foreach(self._processor:getCardList().handCards,function (k,v)
    --     v:enableTouch()
    -- end)
    game.service.RoomService.getInstance():dispatchEvent({name ="HIDE_AUTO_DISCARD_TIPS"})
    game.service.RoomService.getInstance():dispatchEvent({name = "ENTER_STOP_ROBOT"})		
    -- 取消机器人的打牌
    self._processor:getRobot():reset()
end

function PlayerState_AutoDiscard:doNotCloseTingTips()
	return true
end

return PlayerState_AutoDiscard