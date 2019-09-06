local csbPath = "ui/csb/Gamble/UIGambleMain.csb"
local UIGambleMain = class("UIGambleMain", require("app.game.ui.UIBase"), function() return kod.LoadCSBNode(csbPath) end)

function UIGambleMain:ctor()
	
end

local UIGambleList = require("app.game.ui.gamble.UIGambleList")
local UIGambleStake = require("app.game.ui.gamble.UIGambleStake")
local UIGambleHistory = require("app.game.ui.gamble.UIGambleHistory")

function UIGambleMain:init()
	self._btnBack = seekNodeByName(self, "btnBack", "ccui.Button")
	self._btnMyGamble = seekNodeByName(self, "btnMyGamble", "ccui.Button")
	self._baseNode = seekNodeByName(self, "baseNode", "cc.Node")
	-- 帮助按钮
	self._btnHelp = seekNodeByName(self, "btnHelp", "ccui.Button")
	-- 我的竞彩
	self._titleMyGamble = seekNodeByName(self, "titleMyGamble", "ccui.TextBMFont")
	-- 奖励红点
	self._imgRewardRed = seekNodeByName(self._btnMyGamble, "Image_red", "ccui.ImageView")
	-- 竞彩列表
	self._titleMainGamble = seekNodeByName(self, "titleMainGamble", "ccui.TextBMFont")
	-- 默认显示比赛列表,生成直接加载
	self._gambleList = UIGambleList.new()
	self:_addComponent(self._gambleList)
	
	self._gambleStake = nil
	self._gambleHistory = nil
	
	
	bindEventCallBack(self._btnBack, handler(self, self._onBtnBack), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnMyGamble, function()
		self:_changeShowUI("myGamble")
	end, ccui.TouchEventType.ended)

	bindEventCallBack(self._btnHelp, function()
		UIManager.getInstance():show("UIGambleHelp")
	end, ccui.TouchEventType.ended)
end

function UIGambleMain:onShow()
	local gambleService = game.service.GambleService.getInstance()
	-- 监听显示押注界面的事件
	gambleService:addEventListener("EVENT_SHOW_GAMBLE_STAKE_UI", handler(self, self._onShowStakeUI), self)
	-- 监听可领取奖励次数改变事件
	gambleService:addEventListener("EVENT_GAMBLE_REWARD_COUNT_CHANGE", function()
		self._imgRewardRed:setVisible(gambleService:canDrawReward())		
	end, self)
	
	self:_changeShowUI("mainGamble")
	self._imgRewardRed:setVisible(gambleService:canDrawReward())		
end

function UIGambleMain:onHide()
	self._gambleList:hide()
	
	if(self._gambleStake) then
		self._gambleStake:hide(true)
	end
	
	if self._gambleHistory then
		self._gambleHistory:hide()
	end
	game.service.GambleService.getInstance():removeEventListenersByTag(self)
end

function UIGambleMain:_addComponent(node)
	self._baseNode:addChild(node)
	node:init()
end

--显示押注界面
function UIGambleMain:_onShowStakeUI(event)
	if not self._gambleStake then
		self._gambleStake = UIGambleStake.new()
		self:_addComponent(self._gambleStake)
	end
	
	self._gambleStake:show(event)
	
end


-- 改变显示的标题
function UIGambleMain:_changeTitle(flag)
	if flag == "myGamble" then
		self._titleMyGamble:setVisible(true)
		self._titleMainGamble:setVisible(false)
		self._btnMyGamble:setVisible(false)
	else
		self._titleMyGamble:setVisible(false)
		self._titleMainGamble:setVisible(true)
		self._btnMyGamble:setVisible(true)
	end
end

--改变显示界面 
function UIGambleMain:_changeShowUI(flag)
	self:_changeTitle(flag)
	--显示我的奖励界面
	if flag == "myGamble" then
		if not self._gambleHistory then
			self._gambleHistory = UIGambleHistory.new()
			self:_addComponent(self._gambleHistory)
		end
		
		self._gambleHistory:show()
		self._gambleList:hide()
		if(self._gambleStake) then
			self._gambleStake:hide(true)
		end
		self._btnHelp:setVisible(false)
	else
		self._gambleList:show()
		
		if self._gambleHistory then
			self._gambleHistory:hide()
		end
		self._btnHelp:setVisible(true)
	end
end

-- 返回按钮的回调
function UIGambleMain:_onBtnBack()
	if self._gambleHistory and self._gambleHistory:isVisible() then
		self:_changeShowUI("mainGamble")
	else
		UIManager.getInstance():hide("UIGambleMain")
	end
end



return UIGambleMain 