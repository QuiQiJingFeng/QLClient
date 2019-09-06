local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_Lack_Finish = class("Command_Lack_Finish", Command_PlayerProcessor_Base)

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_Lack_Finish:ctor( args )
    self.super:ctor(args)
end

function Command_Lack_Finish:execute( args )
    local step = self._stepGroup[1]

	UIManager:getInstance():destroy("UILack")
	self._processor:setLackCardType(step._cards[1])
end

return Command_Lack_Finish