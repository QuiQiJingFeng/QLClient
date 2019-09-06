local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_OnWaitingOtherOperation = class("Command_OnWaitingOtherOperation", Command_PlayerProcessor_Base)

--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_OnWaitingOtherOperation:ctor( args )
    self.super:ctor(args)
end

function Command_OnWaitingOtherOperation:execute( args )
	-- 等待玩家选择的操作
	Macro.assertFalse(self._revocer == nil)
    self._processor:_onWaitingOtherOperation(self._stepGroup)
end

return Command_OnWaitingOtherOperation