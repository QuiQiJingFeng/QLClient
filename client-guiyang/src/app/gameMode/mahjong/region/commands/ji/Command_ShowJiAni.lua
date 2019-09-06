local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_ShowJiAni = class("Command_ShowJiAni", Command_PlayerProcessor_Base)

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_ShowJiAni:ctor( args )
    self.super:ctor(args)
end

function Command_ShowJiAni:execute( args )
    local step = self._stepGroup[1]
	-- 听牌
	local time = 0
    if self._recover == false then
        time = self._processor:getRoomUI():playAnim(step:getPlayType())
    end
	self._processor._seatUI:setStatusImage(true, step:getPlayType())
	return time
end

return Command_ShowJiAni