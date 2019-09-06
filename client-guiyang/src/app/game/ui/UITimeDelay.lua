local csbPath = "ui/csb/UICsxq.csb" --ui文件
local super = require("app.game.ui.UIBase")

local UITimeDelay = class("UITimeDelay",super,function () return kod.LoadCSBNode(csbPath) end )

--构造函数
function UITimeDelay:ctor()
	--这里可以写成员的声明等
	--For example:
	self._list = nil
	self._share = nil
	self._dismiss = nil
	self._listItem = nil
end

--析构函数
function UITimeDelay:destroy()
	--释放内存
	--For example:
	self._root = nil;
end

--初始化函数
function UITimeDelay:init()
	--这里可以写成员的定义等
	self._list = seekNodeByName(self, "ListView_1_Csxq", "ccui.ListView")
	self._share = seekNodeByName(self, "Button_fx_Csxq", "ccui.Button")
	self._dismiss = seekNodeByName(self, "Button_sq_Csxq", "ccui.Button")
	self._listItem = seekNodeByName(self, "Panel_link_Csxq", "ccui.Layout")
	self._close = seekNodeByName(self, "Button_x_Csxq", "ccui.Layout")
	self._btnOK = seekNodeByName(self, "btnOK", "ccui.Button")

	bindEventCallBack(self._share, handler(self, self._onClickedShare),ccui.TouchEventType.ended)
	bindEventCallBack(self._dismiss, handler(self, self._onClickedDismiss),ccui.TouchEventType.ended)
	bindEventCallBack(self._close, handler(self, self._onClickedClose),ccui.TouchEventType.ended)
	bindEventCallBack(self._btnOK, handler(self, self._onClickedClose),ccui.TouchEventType.ended)

	self._listItem:removeFromParent()
	self._listItem:setVisible(false)
	self:addChild(self._listItem)
end

--显示函数
function UITimeDelay:onShow(...)
	--界面显示逻辑
	local args = {...}
	local inBattleScene = args[1] == "battle"
	local datas = args[2]
	-- 默认显示，但是不可点击，满足条件再设置为可以点击
	self._dismiss:setVisible(true)
	self._dismiss:setEnabled(false)

	-- 牌局未开始不能点击设置中的解散房间
	if inBattleScene then
		local isBattleStart = gameMode.mahjong.Context.getInstance():getGameService()._isGameStarted
		local roomService = game.service.RoomService.getInstance()
		if roomService then
			self._dismiss:setEnabled(isBattleStart or roomService:isHaveBeginFirstGame())
		end
		self._btnOK:setVisible(false)

		self._share:setVisible(true)
		self._dismiss:setVisible(true)
	else
		self._share:setVisible(false)
		self._dismiss:setVisible(false)

		self._btnOK:setVisible(true)
	end

	self._list:removeAllChildren(true)
	local item = nil
	for i=1,#datas do
		item = self._listItem:clone()
		item:setVisible(true)
		self._list:addChild(item)
		local name = seekNodeByName(item, "Text_player_Csxq", "ccui.Text")
		local max = seekNodeByName(item, "Text_sc_Csxq", "ccui.Text")
		local average = seekNodeByName(item, "Text_time_Csxq", "ccui.Text")

		local player = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(datas[i].roleId)
		name:setString(kod.util.String.getMaxLenString(player:getRoomSeat():getPlayer().name, 8))
		--[[
		-- 注释掉，将分秒替换为秒显示
		local s = nil
		local t = datas[i].delayTime
		if t >= 60 then
			s = os.date("%M", t).."分"..os.date("%S", t).."秒"
		else
			s = os.date("%S", t).."秒"
		end
		max:setString(string.format("最长超时%s", s))
		local t = datas[i].averageTime
		if t >= 60 then
			s = os.date("%M", t).."分"..os.date("%S", t).."秒"
		else
			s = os.date("%S", t).."秒"
		end
		average:setString(string.format("平均出牌时间%s", s))
		]]
		max:setString(string.format("最长超时%s秒", tostring(datas[i].delayTime)))
		average:setString(string.format("平均出牌时间%s秒", tostring(datas[i].averageTime)))
	end
	game.service.TDGameAnalyticsService.getInstance():onBegin("UI_TIMEDELAY_TIME_USE")
end

--隐藏函数
function UITimeDelay:onHide()
	--界面隐藏逻辑
	self._list:removeAllChildren(true)
	game.service.TDGameAnalyticsService.getInstance():onCompleted("UI_TIMEDELAY_TIME_USE")
end

--返回界面层级
function UITimeDelay:getUILayer()
	return config.UIConstants.UIZorder
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UITimeDelay:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Normal;
end

--是否需要遮罩
function UITimeDelay:needBlackMask()
	return true;
end

--关闭时操作
function UITimeDelay:closeWhenClickMask()
	return true
end

-- 标记为Persistent的UI不会destroy
function UITimeDelay:isPersistent()
	return false;
end

-- 是否全屏显示，如果全屏显示的话，其下面的ui隐藏，该ui关闭时，那些被隐藏的ui恢复原状态
function UITimeDelay:isFullScreen()
	return false;
end

--自己的逻辑
--TODO:
function UITimeDelay:_onClickedShare()
    share.ShareWTF.getInstance():share(share.constants.ENTER.TIMEOUT)
	game.service.TDGameAnalyticsService.getInstance():onEvent("UI_TIMEDELAY_SHARE", {game.service.LocalPlayerService:getInstance():getRoleId()})
end

function UITimeDelay:_onClickedDismiss()
	if game.service.RoomService.getInstance() then
		game.service.RoomService.getInstance():startVoteDestroy()
	end
	self:_onClickedClose()
	game.service.TDGameAnalyticsService.getInstance():onEvent("UI_TIMEDELAY_DISMISS_ROOM")
end

function UITimeDelay:_onClickedClose()
	UIManager:getInstance():hide("UITimeDelay")
end

return UITimeDelay;