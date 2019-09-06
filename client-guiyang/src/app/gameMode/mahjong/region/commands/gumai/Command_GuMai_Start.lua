local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_GuMai_Start = class("Command_GuMai_Start", Command_PlayerProcessor_Base)

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_GuMai_Start:ctor( args )
    self.super:ctor(args)
end

function Command_GuMai_Start:execute( args )
   
	self:_showUISelectGuMai()
end

-- 估卖
function Command_GuMai_Start:_showUISelectGuMai()
	-- 选择估卖中
	if UIManager:getInstance():getIsShowing("UISelectGuMai") == false then
		UIManager:getInstance():show("UISelectGuMai", gameMode.mahjong.Context.getInstance():getGameService():getMaxPlayerCount())
	end
	-- 选择估卖选项
	if UIManager:getInstance():getIsShowing("UIGuMai") == false then
		UIManager.getInstance():show("UIGuMai")
	end
	local gameService = gameMode.mahjong.Context.getInstance():getGameService();
	gameService:setRoomPlayerReadyState()
end

return Command_GuMai_Start