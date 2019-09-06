local Command_PlayerProcessor_Base = require("app.gameMode.mahjong.core.commands.Command_PlayerProcessor_Base")

local Command_AnLongTing = class("Command_AnLongTing", Command_PlayerProcessor_Base)
local Constants=require("app.gameMode.mahjong.core.Constants")
--==============================--
--desc: 构造方法
--time:2017-08-12 05:45:19
--@args: 1.recover 2.stepGroup 3.scope
--@return 
--==============================--
function Command_AnLongTing:ctor(args)
	self.super:ctor(args)
end

function Command_AnLongTing:execute(args)
	local step = self._stepGroup[1]
	-- 听牌
	local playType = step:getPlayType()
    if playType == Constants.PlayType.DISPLAY_TING then
        --天听 播动画 更新角标
		if self._recover == false then
            self._processor:getRoomUI():playAnim(playType)
		end
		self._processor._seatUI:setStatusImage(true, playType)
	elseif playType == Constants.PlayType.DISPLAY_TING_NO_ACTION then
		--普通听 不播动画只更新听角标
		self._processor._seatUI:setStatusImage(true, Constants.PlayType.DISPLAY_TING)
	end
end

return Command_AnLongTing 