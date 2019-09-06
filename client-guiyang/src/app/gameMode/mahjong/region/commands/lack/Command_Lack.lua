local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_Lack = class("Command_Lack", Command_PlayerProcessor_Base)

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_Lack:ctor( args )
    self.super:ctor(args)
end

function Command_Lack:execute( args )
    local step = self._stepGroup[1]

    local chair = self._processor:getSeatUI():getChairType()
	local lack = UIManager:getInstance():getUI("UILack")
	if lack ~= nil then
		lack:doLack(chair)
	end
	self._processor:setLackCardType(step._cards[1])
end

return Command_Lack