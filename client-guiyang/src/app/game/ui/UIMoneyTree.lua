--[[	 UIMoneyTree.lua (摇钱树主界面)
--]]
local MoneyTreeConfig = require("app.config.MoneyTreeConfig")

local csbPath = "ui/csb/UIMoneyTree.csb"
-- local csbPath = "ui/csb/UIMerryTree.csb"
local super = require("app.game.ui.UIBase")

local UIMoneyTree = class("UIMoneyTree", super, function() return kod.LoadCSBNode(csbPath) end)

function UIMoneyTree:ctor()
	--摇一下按钮
	self._btnShake = nil;
	--我的奖励按钮
	self._btnMyAward = nil
	--关闭按钮
	self._btnClose = nil
	
	--抽奖次数
	self._textItemCount = nil
	--活动日期
	self._textAcitvityDate = nil
	--内容 (活动时间规则等)
	self._textContent = nil
	--走马灯
	self._textNotice = nil
	
	--摇钱树动画
	self._action = nil;
	
	--走马灯
	self._panelMarquee = nil;
	-- 当前tip是否正在显示
	self._isTweenning = false;	
	-- 滚动速度
	self._rollSpeed = 120
	--实物奖励红点
	self._imgRewardRed = nil
end

function UIMoneyTree:init()
	--播放动画
	self._action = cc.CSLoader:createTimeline(csbPath)
	self:runAction(self._action)
	self._action:gotoFrameAndPlay(0, true)
	
	--定义三个按钮
	self._btnShake	= seekNodeByName(self, "Button_Shake", "ccui.Button");
	self._btnMyAward	= seekNodeByName(self, "Button_MyAward", "ccui.Button");
	self._btnClose	= seekNodeByName(self, "Button_Close", "ccui.Button");
	
	--文本设置
	self._textContent	= seekNodeByName(self, "Text_Content"		, "ccui.Text");
	self._textNotice	= seekNodeByName(self, "Text_Notice"		, "ccui.Text");
	self._textItemCount = seekNodeByName(self, "Text_Item_Count"		, "ccui.TextBMFont");
	self._textAcitvityDate = seekNodeByName(self, "Text_Acitvity_Date"		, "ccui.Text");
	
	--走马灯
	self._panelMarquee = seekNodeByName(self, "Panel_Marquee", "ccui.Layout")
	--我的奖励红点
	self._imgRewardRed = seekNodeByName(self, "imgRewardRed", "ccui.ImageView")
	self:_registerCallBack()
end

function UIMoneyTree:onShow(...)
	
	local config = MoneyTreeConfig.getConfig(game.service.LocalPlayerService:getInstance():getArea())
	--设置公告
	local size = self._textContent:getContentSize();
	self._textContent:setTextAreaSize(size)
	self._textContent:ignoreContentAdaptWithSize(true);
	self._textContent:setAnchorPoint(cc.p(0.5, 0.5));
	self._textContent:setString(config.ACTIVITY_INFO);
	
	self._textItemCount:setFntFile("font/font_0.fnt")
	self:freshAwardCount();
	
	self._textAcitvityDate:setString(config.TEXT_ACITVITY_DATE)
	
	-- --设置奖品图片 -- 不用设置，让美术去改
	for i = 1, #config.AWARD_LIST do
		local awardImg = seekNodeByName(self, "Image_Award_" .. i, "ccui.ImageView");
		printf("load img %s", config.AWARD_LIST[i].tree_img)
		awardImg:loadTexture(config.AWARD_LIST[i].tree_img)
		local size = awardImg:getVirtualRendererSize()
		awardImg:setContentSize(size)
		-- awardImg:loadTexture("")
	end
	
	game.service.MoneyTreeService:getInstance():addEventListener("EVENT_MONEY_TREE_DATA_RECEIVED", handler(self, self.freshAwardCount), self);
	game.service.MoneyTreeService:getInstance():addEventListener("EVENT_TurntableDrawRES", function()
		self:freshAwardCount()
		self:showTips()
	end, self);
	
	game.service.MoneyTreeService:getInstance():addEventListener("EVENT_ShareTurntableRewardRES", handler(self, self.freshAwardCount), self);
	game.service.WeChatService.getInstance():addEventListener("EVENT_SEND_RESP", handler(self, self.requestShareTurntableReward), self);
	game.service.MoneyTreeService:getInstance():addEventListener("EVENT_MONEY_TREE_GIFT_RED_CHANGE", function(event)
		self._imgRewardRed:setVisible(event.red)
	end, self);
	self:showTips();
	
	self._imgRewardRed:setVisible(game.service.MoneyTreeService:getInstance():getGoodsRed())
end	

function UIMoneyTree:onHide()
	game.service.MoneyTreeService:getInstance():removeEventListenersByTag(self)
	game.service.WeChatService.getInstance():removeEventListenersByTag(self)
	
end

function UIMoneyTree:_registerCallBack()
	--注册三个按钮的点击事件
	bindEventCallBack(self._btnShake, handler(self, self.onBtnShakeClick), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnMyAward, handler(self, self.onBtnMyAwardClick), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnClose, handler(self, self.onBtnCloseClick), ccui.TouchEventType.ended);
end

function UIMoneyTree:onBtnShakeClick()
	if game.service.MoneyTreeService:getInstance():getItemCount() <= 0 then
		game.ui.UIMessageBoxMgr.getInstance():show("抽奖次数不足！", {"确定"})
	else
		--发送抽奖请求
		game.service.MoneyTreeService.getInstance():requestTurntableDraw()
	end
end

function UIMoneyTree:requestShareTurntableReward()
	if game.service.MoneyTreeService:getInstance() ~= nil then
		game.service.MoneyTreeService:getInstance():requestShareTurntableReward()
	end
end

function UIMoneyTree:freshAwardCount()
	self._textItemCount:setString(game.service.MoneyTreeService:getInstance():getItemCount());
	
end

function UIMoneyTree:onBtnMyAwardClick()
	--添加我的奖励记录layer到场景
	UIManager:getInstance():show("UIMoneyTreeMyAwardRecord");
end

function UIMoneyTree:onBtnCloseClick()
	--返回 
	UIManager.getInstance():hide("UIMoneyTree")
end

function UIMoneyTree:needBlackMask()
	return true;
end

-- 显示跑马灯信息
function UIMoneyTree:showTips()
	-- 当前没有显示则开始新的显示
	if false == self._isTweenning then
		local moneyTreeService = game.service.MoneyTreeService:getInstance()
		if #moneyTreeService.waitToShow > 0 then
			-- when tip showing finished, call showTips again 
			local checkTips = function()
				self._isTweenning = false
				self:showTips()
			end
			
			local marqueeSize = self._panelMarquee:getContentSize();
			local tipLength = self._textNotice:getContentSize().width
			self._isTweenning = true
			
			self._textNotice:setString(moneyTreeService.waitToShow[1])
			self._textNotice:setPositionX(marqueeSize.width + tipLength / 2);
			
			local delay =(tipLength + marqueeSize.width + 2) / self._rollSpeed
			local moveToAction = cc.MoveTo:create(delay, cc.p(- tipLength, self._textNotice:getPositionY()))
			local callFuncAction = cc.CallFunc:create(checkTips)
			
			self._textNotice:runAction(cc.Sequence:create(moveToAction, callFuncAction))
			
			-- this tip has been proceed, so remove it
			table.remove(moneyTreeService.waitToShow, 1)
		else
			self._textNotice:setString("");
		end
	end
end

return UIMoneyTree;


