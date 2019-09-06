local csbPath = "ui/csb/GamePlays/guizhoudiy/UISelectGuMai.csb"
local super   = require("app.game.ui.UIBase")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType

local UISelectGuMai = class("UISelectGuMai", super, function ()return kod.LoadCSBNode(csbPath) end)

function UISelectGuMai:cotr()
    self._bgTipsLeft    = nil
	self._bgTipsTop     = nil
	self._bgTipsRight   = nil
end

function UISelectGuMai:init()
    self._bgTipsLeft    = seekNodeByName(self, "z_dqz1_3gumai", "ccui.ImageView");
	self._bgTipsTop     = seekNodeByName(self, "z_dqz2_3gumai", "ccui.ImageView");
	self._bgTipsRight   = seekNodeByName(self, "z_dqz3_3gumai", "ccui.ImageView");
end

function UISelectGuMai:onShow(...)
	self._bgTipsLeft:setVisible(true)
	self._bgTipsTop:setVisible(true)
	self._bgTipsRight:setVisible(true)

    local args = {...}
	if args[1] ~= nil then
		if args[1] == 3 then
			self._bgTipsTop:setVisible(false)
		elseif args[1] == 2 then
			self._bgTipsLeft:setVisible(false)
			self._bgTipsRight:setVisible(false)
		end
	end

	self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView");
	if self._mask then
		self._mask:setOpacity(220)
	end
end

function UISelectGuMai:doGuMai(chair)
	if chair == CardDefines.Chair.Down then
		-- 自己不需要
	elseif chair == CardDefines.Chair.Left then
		self:hideLeft()
	elseif chair == CardDefines.Chair.Right then
		self:hideRight()
	elseif chair == CardDefines.Chair.Top then
		self:hideTop()
	end
end

function UISelectGuMai:hideLeft()
	self._bgTipsLeft:setVisible(false)
end

function UISelectGuMai:hideTop()
	self._bgTipsTop:setVisible(false)
end

function UISelectGuMai:hideRight()
	self._bgTipsRight:setVisible(false)
end

function UISelectGuMai:_onHide()
    UIManager:getInstance():hide("UISelectGuMai");
end

function UISelectGuMai:needBlackMask()
	return false;
end

function UISelectGuMai:closeWhenClickMask()
	return false
end

return UISelectGuMai