local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_GuMai_Select = class("Command_GuMai_Select", Command_PlayerProcessor_Base)

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_GuMai_Select:ctor( args )
    self.super:ctor(args)
end

function Command_GuMai_Select:execute( args )
   
	self:_doGuMai(self._processor:getSeatUI():getChairType())
end

-- 当玩家选择估卖时，隐藏对应的文字提示
function Command_GuMai_Select:_doGuMai(chair)
	local guMai = UIManager:getInstance():getUI("UISelectGuMai")
	if guMai ~= nil then
		guMai:doGuMai(chair)
	else
		UIManager:getInstance():show("UISelectGuMai", gameMode.mahjong.Context.getInstance():getGameService():getMaxPlayerCount())
		local gameService = gameMode.mahjong.Context.getInstance():getGameService();
		gameService:setRoomPlayerReadyState()
	end
end

return Command_GuMai_Select