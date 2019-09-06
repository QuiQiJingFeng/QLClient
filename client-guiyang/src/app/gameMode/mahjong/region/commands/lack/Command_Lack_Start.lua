local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_Lack_Start = class("Command_Lack_Start", Command_PlayerProcessor_Base)

local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_Lack_Start:ctor( args )
    self.super:ctor(args)
end

function Command_Lack_Start:execute( args )
	if UIManager:getInstance():getIsShowing("UILack") == false then
		UIManager:getInstance():show("UILack", function(cardType)
			local gameService = gameMode.mahjong.Context.getInstance():getGameService();
			gameService:sendPlayStep(PlayType.OPERATE_LACK, {cardType})
			local lack = UIManager:getInstance():getUI("UILack")
			if lack ~= nil then
				lack:doLack(CardDefines.Chair.Down)
			end
		end, gameMode.mahjong.Context.getInstance():getGameService():getMaxPlayerCount())
	end
end

return Command_Lack_Start