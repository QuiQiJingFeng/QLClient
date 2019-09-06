--[[
	 UIAward.lua (奖励弹窗界面)
--]]
local MoneyTreeConfig = require("app.config.MoneyTreeConfig")

local csbPath = "ui/csb/UIAward.csb"
-- local csbPath = "ui/csb/UIMerryAward.csb"
local super = require("app.game.ui.UIBase")

local UIMoneyTreeAward = class("UIMoneyTreeAward", super, function () return kod.LoadCSBNode(csbPath) end)

function UIMoneyTreeAward:ctor()
	--声明摇钱树按钮 
	self._btnShare_1 = nil;
	self._btnClose_1 = nil;
	self._btnShare_2 = nil;
	self._btnClose_2 = nil;

	--奖励图片
	self._imgAward = nil
	self._txtAWard = nil
	--奖励提示
	self._textAwardNotice = nil
	--谢谢参与图片
	-- self._imageEncourage = {};

	--中奖层
	self._panelRealAward = nil;
	--未中奖层
	self._panelEncourage = nil;
end

function UIMoneyTreeAward:init()
	--播放动画
	self._action = cc.CSLoader:createTimeline(csbPath)
	self:runAction(self._action)

	--定义摇钱树按钮
	self._btnShare_2	= seekNodeByName(self, "Button_Share_2", "ccui.Button");
	self._btnClose_2	= seekNodeByName(self, "Button_Close_2", "ccui.Button");
	self._btnShare_1	= seekNodeByName(self, "Button_Share_1", "ccui.Button");
	self._btnClose_1	= seekNodeByName(self, "Button_Close_1", "ccui.Button");

	self._textAwardNotice	= seekNodeByName(self, "Text_Award_Notice"		, "ccui.Text");

	--图片设置
	self._imgAward = seekNodeByName(self, "Image_Award", "ccui.ImageView");
	self._txtAWard = seekNodeByName(self._imgAward, "BitmapFontLabel_1", "ccui.TextBMFont");
	-- for i=1,MoneyTreeConfig.ENCOURAGE_IMAGE_NUM do
	-- 	self._imageEncourage[i] = seekNodeByName(self, "Image_Encourage_"..i, "ccui.ImageView");
	-- end

	--层级设置
	self._panelRealAward = seekNodeByName(self, "Panel_Real_Award", "ccui.Layout")
	self._panelEncourage = seekNodeByName(self, "Panel_Encourage", "ccui.Layout")

	self:_registerCallBack()
end

function UIMoneyTreeAward:onShow(...)
	local awardId = ...;

	local config = MoneyTreeConfig.getConfig(game.service.LocalPlayerService:getInstance():getArea())
	if self._txtAWard then
		-- 不是给这个界面用的
		-- TODO：建议两个界面整合到一起，免得到时改一个，忘另一个
		self._txtAWard:setVisible(false)
	end

	if awardId ~= config.ENCOURAGE then
		--有奖品
		local safeImg = config.AWARD_LIST[awardId].award_img;
		self._imgAward:loadTexture(safeImg)
		self._panelEncourage:setVisible(false);
		self._panelRealAward:setVisible(true);
		self._btnShare_2:setVisible(false);
		self._btnClose_2:setVisible(false);
		self._btnShare_1:setVisible(true);
		self._btnClose_1:setVisible(true);
		self._action:gotoFrameAndPlay(0, true);
		if config.AWARD_LIST[awardId].name then
			self._textAwardNotice:setString(config.AWARD_LIST[awardId].name);
		else
			self._textAwardNotice:setString(config.TEXT_REAL_AWARD_NOTICE);
		end
	else
		--没有奖品
		-- for i=1,config.ENCOURAGE_IMAGE_NUM do
		-- 	self._imageEncourage[i]:setVisible(false);
		-- end
		
		-- self._imageEncourage[math.random(3)]:setVisible(true);

		self._panelRealAward:setVisible(false);
		self._panelEncourage:setVisible(true);
		self._btnShare_1:setVisible(false);
		self._btnClose_1:setVisible(false);
		self._btnShare_2:setVisible(true);
		self._btnClose_2:setVisible(true);
	end
end

function UIMoneyTreeAward:_registerCallBack()
	bindEventCallBack(self._btnShare_2, handler(self, self.onBtnShareClick), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnClose_2, handler(self, self.onBtnCloseClick), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnShare_1, handler(self, self.onBtnShareClick), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnClose_1, handler(self, self.onBtnCloseClick), ccui.TouchEventType.ended);
end

function UIMoneyTreeAward:onBtnShareClick()
    share.ShareWTF.getInstance():share(share.constants.ENTER.MONEY_TREE)
end

function UIMoneyTreeAward:onBtnCloseClick()
	--返回
	UIManager.getInstance():hide("UIMoneyTreeAward")
end

function UIMoneyTreeAward:needBlackMask()
	return true;
end

return UIMoneyTreeAward;
