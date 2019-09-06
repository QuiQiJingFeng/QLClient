

local super = require("app.game.ui.UIBase")
local csbPath = "ui/csb/Gamble/UIGambleStake.csb"

local UIGambleStake = class("UIGambleStake", super, function() return cc.CSLoader:createNode(csbPath) end)

local stakeTeamType = net.protocol.stakeTeamType

function UIGambleStake:ctor()
	self._isShowing = false
	--压住的队伍
	self._selectedTeam = ""
	--押注的本金
	self._stakeCapital = 0
	--本次押注的赔率
	self._stakeOdds = 0
	--本次押注的比赛id
	self._gameId = 0
	--每个按钮的押注金额
	self._stakeList = {100, 1000, 10000, - 1}
	--当前的押注总量
	self._stakeAmount = 0
end

function UIGambleStake:init()
	--竞彩信息
	self._textGambleInfo = seekNodeByName(self, "textGambleInfo", "ccui.Text")
	
	--竞彩本金
	self._textCapital = seekNodeByName(self, "textCapital", "ccui.Text")
	--竞彩胜利的获利
	self._textWinAward = seekNodeByName(self, "textWinAward", "ccui.Text")
	--玩家的余额
	self._textGoldBalance = seekNodeByName(self, "textGoldBalance", "ccui.Text")
	
	--本体整天编辑界面
	self._panelMain = seekNodeByName(self, "Panel_stake", "ccui.Layout")
	--关闭按钮
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	--清空押注按钮
	self._btnClear = seekNodeByName(self, "btnClear", "ccui.Button")
	--确认押注按钮
	self._btnConfirm = seekNodeByName(self, "btnConfirm", "ccui.Button")
	--警示提示
	self._textWarn = seekNodeByName(self, "textWarn", "ccui.Text")
	
	--押注按钮
	self._stakeButton = {
		seekNodeByName(self, "btnStake1", "ccui.Button"),
		seekNodeByName(self, "btnStake2", "ccui.Button"),
		seekNodeByName(self, "btnStake3", "ccui.Button"),
		seekNodeByName(self, "btnStake4", "ccui.Button"),
	}
	--押注按钮文字
	self._bmTextStake = {
		seekNodeByName(self, "bmTextStake1", "ccui.TextBMFont"),
		seekNodeByName(self, "bmTextStake2", "ccui.TextBMFont"),
		seekNodeByName(self, "bmTextStake3", "ccui.TextBMFont"),
		seekNodeByName(self, "bmTextStake4", "ccui.TextBMFont"),
	}
	
	bindEventCallBack(self._btnClose, function() self:hide() end, ccui.TouchEventType.ended);
	
	--为不同的押注按钮设置事件
	for i = 1, #self._stakeButton do
		bindEventCallBack(self._stakeButton[i], function() self:_addStakeMoney(self._stakeList[i]) end, ccui.TouchEventType.ended);
	end
	
	bindEventCallBack(self._btnConfirm, function()
		if self._stakeCapital > 0 then
			game.service.GambleService.getInstance():sendCGQueryStakeREQ(self._gameId, self._selectedTeam, self._stakeCapital)
		end
	end, ccui.TouchEventType.ended)
	
	--清空本次押注
	bindEventCallBack(self._btnClear, function()
		self._stakeCapital = 0
		self:_changeShowMoney(0)
	end, ccui.TouchEventType.ended)
	
end

function UIGambleStake:show(event)
	-- 初始化数据
	self._gameId = event.gameId
	self._stakeCapital = 0
	self._selectedTeam = event.selectedTeam
	self._textWarn:setVisible(false)
	
	if self._isShowing then
		
	else
		self._isShowing = true
		--显示界面并且缓动进入
		self._panelMain:stopAllActions()
		self:setVisible(true)
		self._panelMain:setPositionY(- 150)
		local move = cc.MoveTo:create(0.1, cc.p(0, 0))
		self._panelMain:runAction(move)
		
		local GambleService = game.service.GambleService.getInstance()
		--监听押注成功后事件
		GambleService:addEventListener("EVENT_GAMBLE_GAME_STAKE", function()
			self:hide()
		end, self)
		--监听赔率变化的事件
		GambleService:addEventListener("EVENT_GAMBLE_GAME_ODD_CHANGE", handler(self, self._onGameOddChange), self)
	end
	
	
	--设置界面显示
	self:_setData()
	
end

function UIGambleStake:hide(isImmediately)
	self._isShowing = false
	self._panelMain:stopAllActions()
	self._textWarn:stopAllActions()
	if isImmediately == true then
		self:setVisible(false)
	else
		--界面缓动移出并且隐藏界面
		self._panelMain:setPositionY(0)
		local move = cc.MoveTo:create(0.1, cc.p(0, - 150))
		local callback = cc.CallFunc:create(function() self:setVisible(false) end)
		local seq = cc.Sequence:create(move, callback)
		self._panelMain:runAction(seq)
	end
	local GambleService = game.service.GambleService.getInstance()
	GambleService:removeEventListenersByTag(self)
	game.service.GambleService.getInstance():dispatchEvent({name = "EVENT_STAKE_UI_HIDE"})
end


--初始化界面数据 以及 对应变量
function UIGambleStake:_setData()
	local data = game.service.GambleService:getInstance().commonConfig.games[self._gameId]
	
	local info = ''
	if self._selectedTeam == stakeTeamType.home then
		info = data.homeTeam .. "  胜   " .. data.homeOdds
		self._stakeOdds = tonumber(data.homeOdds)
		self._stakeAmount = data.homeMoney
	elseif self._selectedTeam == stakeTeamType.away then
		info = data.visitingTeam .. "  胜   " .. data.visitingOdds
		self._stakeOdds = tonumber(data.visitingOdds)
		self._stakeAmount = data.visitingMoney
	else
		info = "平局   " .. data.dogFall
		self._stakeOdds = tonumber(data.dogFall)
		self._stakeAmount = data.dogFallMoney
	end
	self._textGambleInfo:setString(info)
	self:_initButton()
	self._stakeCapital = 0
	self:_changeShowMoney(0)
end

--如何本次押注的赔率变化,则初始化数据
function UIGambleStake:_onGameOddChange(event)
	
	if table.indexof(event.changedIds, self._gameId) then
		self:_setData()
		self:_showChangeWarn()
	end
end

-- 显示赔率变化的警告提示
function UIGambleStake:_showChangeWarn()
	self._textWarn:setVisible(true)
	local delay = cc.DelayTime:create(5)
	local callback = cc.CallFunc:create(function() self._textWarn:setVisible(false) end)
	local seq = cc.Sequence:create(delay, callback)
	self._textWarn:runAction(seq)
end

--改变显示的金币相关数据
function UIGambleStake:_changeShowMoney(money)
	local balance = kod.util.String.formatMoney(game.service.LocalPlayerService:getInstance():getGoldAmount(), 2)
	self._textGoldBalance:setString("余额:" .. balance)
	self._textCapital:setString("本金" .. self._stakeCapital)
	
	local serviceCharge = game.service.GambleService:getInstance().commonConfig.serviceCharge
	
	local winReward = self._stakeCapital * self._stakeOdds - self._stakeCapital *(self._stakeOdds - 1) * serviceCharge
	self._textWinAward:setString("返还" .. math.floor(winReward))
	
end

--初始化按钮的不同下注
function UIGambleStake:_initButton()
	local gold = game.service.LocalPlayerService:getInstance():getGoldAmount()
	if gold < 799999 then
		self._stakeList = {100, 1000, 10000, - 1}
	elseif gold < 2999999 then
		self._stakeList = {1000, 10000, 100000, - 1}
	else
		self._stakeList = {10000, 100000, 500000, - 1}
	end
	
	for i = 1, #self._stakeList - 1 do
		self._bmTextStake[i]:setString(kod.util.String.formatMoney(self._stakeList[i], 0))		
	end
	
	self._bmTextStake[#self._bmTextStake]:setString("最大")
end

--增加押注金额
function UIGambleStake:_addStakeMoney(money)
	local GambleService = game.service.GambleService.getInstance()
	local gold = game.service.LocalPlayerService:getInstance():getGoldAmount()
	local limitGold = GambleService.commonConfig.limitOfMoney - self._stakeAmount
	
	local newMoney = 0
	if money == - 1 then
		newMoney = math.min(math.floor(gold / 2),limitGold)
	else
		newMoney =	self._stakeCapital + money
	end
	if newMoney > gold / 2 or newMoney > limitGold then
		if gold / 2 < limitGold then
			game.ui.UIMessageTipsMgr.getInstance():showTips("每次下注最多只能下注自身携带金币的50%")
			newMoney = math.floor(gold / 2)
			
		else
			game.ui.UIMessageTipsMgr.getInstance():showTips("已达到押注上限无法继续进行押注")
			newMoney = limitGold
		end
		
	end
	self._stakeCapital = newMoney
	self:_changeShowMoney(self._stakeCapital)
	
end


return UIGambleStake 