local super = require("app.gameMode.base.processor.Processor")
local RoomProcessor = class("RoomProcessor", super)

function RoomProcessor:ctor()
    self.super.ctor(self)
    -- 暂时空着，后面研究明白再往里放东西
end

function RoomProcessor:processStep(isRecover, stepGroup)
    super._processStep(self, isRecover, stepGroup)
end

function RoomProcessor:onGameWaitingStart()
end

function RoomProcessor:onGameStarted()
end

function RoomProcessor:_checkSelf ( step )
    return step:getRoleId() == -1
end

return RoomProcessor