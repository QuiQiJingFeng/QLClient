local PlayType = require("app.gameMode.paodekuai.core.Constants_Paodekuai").PlayType
local super = require("app.gameMode.base.processor.Processor")
local RoomProcessor = class("RoomProcessor", super)

function RoomProcessor:ctor()
    self.super.ctor(self)
    -- 暂时空着，后面研究明白再往里放东西
    gameMode.mahjong.Context.getInstance():getGameService():addEventListener("PROC_STEP", function(event)
		self:processStep(event.recover, event.stepGroup)
	end, self);
end

function RoomProcessor:processStep(isRecover, stepGroup)
    super._processStep(self, isRecover, stepGroup)
    local firstStep = stepGroup[1];
    if firstStep:getPlayType() == PlayType.DISTORY_FINISH_ROOM then
        --FYD 处理解散房间当局
        local UI_ANIM = require("app.manager.UIAnimManager")
        
        local ui = UIManager:getInstance():getUI("UIPlayback")
        local config = UI_ANIM.UIAnimConfig.new("ui/csb/Effect_jiesan.csb", nil,nil, nil, nil, nil, nil, ui)
        local anim = UI_ANIM.UIAnimManager:getInstance():onShow(config)
	end
end

function RoomProcessor:onGameWaitingStart()
end

function RoomProcessor:onGameStarted()
end

function RoomProcessor:_checkSelf ( step )
    return step:getRoleId() == -1
end

return RoomProcessor