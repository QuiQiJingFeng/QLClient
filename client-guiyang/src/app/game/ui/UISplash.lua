--[[
闪屏界面, 进入游戏时显示, 渐隐之后进入下一个状态
--]]
local csbPath = "ui/csb/UISplash.csb"
local super = require("app.game.ui.UIBase")

local UISplash = class("UISplash", super, function () return kod.LoadCSBNode(csbPath) end)

function UISplash:ctor()
end

function UISplash:needBlackMask()
	return false;
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UISplash:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Bottom;
end

function UISplash:onShow(...)
	if nil ~= self.playAnimation and "function" == type(self.playAnimation) then
		self:playAnimation(csbPath, nil, false)
	end 
	local delay = cc.DelayTime:create(1.95)
    local func  = cc.CallFunc:create(handler(self,self._enterUpdateState))
    local queue = cc.Sequence:create(delay,func)
	self:runAction(queue);
end

function UISplash:_enterUpdateState()
	GameFSM:getInstance():enterState("GameState_Update")	
end

return UISplash