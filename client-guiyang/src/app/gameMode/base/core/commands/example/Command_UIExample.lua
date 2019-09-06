--[[
	有些消息需要ui做出改变的，建议使用此方法
]]
local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_UIExample = class("Command_UIExample", Command_PlayerProcessor_Base)

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_UIExample:ctor( args )
    self.super:ctor(args)
end

function Command_UIExample:execute( args )
    -- find game scene ui
	local gameScene = UIManager:getInstance():getUI("UIGameScene")
	if gameScene ~= nil then
		gameScene:dispatchEvent({name = "UIPLAYER_EXAMPLE", callback = handler(self, self.aaa)})
	end
end


function  aaa( ... )
	-- jiafen
end
return Command_UIExample