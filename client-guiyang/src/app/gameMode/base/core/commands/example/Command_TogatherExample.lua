--[[
	理论上大部分是先修改数据在改ui，那么可以在cmmand里使用回调的方式
]]
local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_TogatherExample = class("Command_TogatherExample", Command_PlayerProcessor_Base)

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_TogatherExample:ctor( args )
    self.super:ctor(args)
end

function Command_TogatherExample:execute( args )
    -- find game scene ui
	local gameScene = UIManager:getInstance():getUI("UIGameScene")
	if gameScene ~= nil then
		gameScene:dispatchEvent({name = "UIPLAYER_EXAMPLE"})
	end
end

return Command_TogatherExample