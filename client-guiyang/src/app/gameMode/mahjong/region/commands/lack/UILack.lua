--[[
??????
--]]
local csbPath = "ui/csb/GamePlays/common/UILack.csb"
local super = require("app.game.ui.UIBase")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local UILack = class("UILack", super, function () return kod.LoadCSBNode(csbPath) end)

function UILack:ctor()
	self._btnWan = nil
	self._btnTiao = nil
	self._btnTong = nil
	self._bgLackTips = nil
	self._txtLackTips = nil

	self._bgTipsLeft = nil
	self._bgTipsTop = nil
	self._bgTipsRight = nil

	-- 万条筒 点击回调
	self._buttonCallback = nil

	-- mask
	self._mask = nil
end

function UILack:init()
	self._btnWan = seekNodeByName(self, "Btn_wan_Fixed", "ccui.Button");
	self._btnTiao = seekNodeByName(self, "Btn_tiao_Fixed", "ccui.Button");
	self._btnTong = seekNodeByName(self, "Btn_tong_Fixed", "ccui.Button");
	self._bgLackTips = seekNodeByName(self, "Image_17_dw_Fixed", "ccui.ImageView");
	self._txtLackTips = seekNodeByName(self, "z_qymcnh_Fixed", "ccui.Text");

	self._bgTipsLeft = seekNodeByName(self, "z_dqz1_Fixed", "ccui.ImageView");
	self._bgTipsTop = seekNodeByName(self, "z_dqz2_Fixed", "ccui.ImageView");
	self._bgTipsRight = seekNodeByName(self, "z_dqz3_Fixed", "ccui.ImageView");

	self:_registerCallBack()
end

function UILack:_registerCallBack()
	-- bindEventCallBack(self._btnLoginGuest, handler(self, self._onTapGuestLogin), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnWan, function()
		self:onClickButton("wan")
	end, ccui.TouchEventType.ended)
	bindEventCallBack(self._btnTiao, function()
		self:onClickButton("tiao")
	end, ccui.TouchEventType.ended)
	bindEventCallBack(self._btnTong, function()
		self:onClickButton("tong")
	end, ccui.TouchEventType.ended)
end

function UILack:needBlackMask()
	return false;
end

function UILack:getUIZOrder()
	return config.UIConstants.UIZorder - 1
end

function UILack:closeWhenClickMask()
	return false
end

function UILack:onShow(...)
	self._btnWan:setVisible(true)
	self._btnTiao:setVisible(true)
	self._btnTong:setVisible(true)
	self._bgLackTips:setVisible(true)
	self._txtLackTips:setVisible(true)

	self._bgTipsLeft:setVisible(true)
	self._bgTipsTop:setVisible(true)
	self._bgTipsRight:setVisible(true)

	self._mask = seekNodeByName(self, "dlg_mask", "ccui.ImageView");
	if self._mask then
		self._mask:setOpacity(100)
	end

	local args = {...}
	if args[1] ~= nil and type(args[1]) == "function" then
		self._buttonCallback = args[1]
	end

	-- 如果是回放只判断房间内实际人数，不关心房间最大人数
	if args[3] ~= nil then
		if args[3] == 3 then
			self._bgTipsTop:setVisible(false)
		elseif args[3] == 2 then
			self._bgTipsLeft:setVisible(false)
			self._bgTipsRight:setVisible(false)
		end
		return
	end

	-- 不是回放的情况
	local playerMap = game.service.RoomService:getInstance():getPlayerMap()
	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	local player = playerMap[roleId]
	local playerCount = table.nums(playerMap)
	if args[2] ~= nil then
		-- 判断房间里玩家与房间内最大人数是否相等
		if player~= nil and playerCount ~= args[2] then
			self:_doLack(player.position, playerCount)
		else
			-- 玩家人数与房间最大人数一致就按以前逻辑走
			if args[2] == 3 then
				self._bgTipsTop:setVisible(false)
			elseif args[2] == 2 then
				self._bgTipsLeft:setVisible(false)
				self._bgTipsRight:setVisible(false)
			end
		end
	end
end

-- 提前开局时玩家没有玩家的也会显示定缺选择中，目前先这样处理以后优化
function UILack:_doLack(chair, count)
	if chair == 1 then
		self._bgTipsRight:setVisible(count - 2 >= 0 and true or false)
		self._bgTipsTop:setVisible(count - 3 >= 0 and true or false)
		self._bgTipsLeft:setVisible(count - 4 >= 0 and true or false)
	elseif chair == 2 then
		self._bgTipsRight:setVisible(count - 3 >= 0 and true or false)
		self._bgTipsTop:setVisible(count - 4 >= 0 and true or false)
		self._bgTipsLeft:setVisible(true)
	elseif chair == 3 then
		self._bgTipsRight:setVisible(count - 4 >= 0 and true or false)
		self._bgTipsTop:setVisible(true)
		self._bgTipsLeft:setVisible(true)
	elseif chair == 4 then
		self._bgTipsRight:setVisible(true)
		self._bgTipsTop:setVisible(true)
		self._bgTipsLeft:setVisible(true)
	end
end

function UILack:doLack(chair)
	if chair == CardDefines.Chair.Down then
		self:hideDown()
	elseif chair == CardDefines.Chair.Left then
		self:hideLeft()
	elseif chair == CardDefines.Chair.Right then
		self:hideRight()
	elseif chair == CardDefines.Chair.Top then
		self:hideTop()
	end
end

function UILack:hideDown()
	self._btnWan:setVisible(false)
	self._btnTiao:setVisible(false)
	self._btnTong:setVisible(false)
	self._bgLackTips:setVisible(false)
	self._txtLackTips:setVisible(false)
end

function UILack:hideLeft()
	self._bgTipsLeft:setVisible(false)
end

function UILack:hideTop()
	self._bgTipsTop:setVisible(false)
end

function UILack:hideRight()
	self._bgTipsRight:setVisible(false)
end

function UILack:onClickButton(ty)
	local operateCode = {
		wan = CardDefines.CardType.Wan,
		tiao = CardDefines.CardType.Tiao,
		tong = CardDefines.CardType.Tong,
	}

	if self._buttonCallback then
		self._buttonCallback(operateCode[ty])
	end
end

return UILack;