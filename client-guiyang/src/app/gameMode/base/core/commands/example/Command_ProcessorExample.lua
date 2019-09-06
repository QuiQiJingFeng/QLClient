--[[
	有些消息需要改变数据的，建议使用此方法
]]
local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_ProcessorExample = class("Command_ProcessorExample", Command_PlayerProcessor_Base)

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_ProcessorExample:ctor( args )
    self.super:ctor(args)
end

function Command_ProcessorExample:execute( args )
	self._processor.example(unpack(args))
end

return Command_ProcessorExample