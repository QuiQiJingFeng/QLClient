--[[	拉新回流活动界面
        已废弃 使用UIComebackInvite
]]
local csbPath = "ui/csb/UIPullNew.csb"
local Version = require "app.kod.util.Version"
local UIRecallFriends = class("UIRecallFriends", require("app.game.ui.UIBase"), function() return kod.LoadCSBNode(csbPath) end)

-- 分享图片
local SHARE_ICNO = "art/activity/pullNew.png"

--身份类型(1为邀请者，2为被邀请者)
local inviteType = {
	inviter = 1,
	invitee = 2
}

local activityData =
{
	[inviteType.inviter] = {imgPath = "art/activity/sharePullNew_1.png"},
	
	
	[inviteType.invitee] = {imgPath = "art/activity/sharePullNew_2.png"}
}

function UIRecallFriends:needBlackMask()
	return true
end

function UIRecallFriends:closeWhenClickMask()
	return false
end

function UIRecallFriends:ctor()
	self._type = 1
	self._weChat = ""
end

function UIRecallFriends:init()
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭
	self._btnReward = seekNodeByName(self, "Button_Reward", "ccui.Button") -- 领取奖励
	self._btnShare = seekNodeByName(self, "Button_Share", "ccui.Button") -- 分享
	self._btnHelp = seekNodeByName(self, "Button_sm", "ccui.Button") -- 活动说明
	self._imgShare = seekNodeByName(self, "Image_Share", "ccui.ImageView") -- 图片显示
	
	self._slider = seekNodeByName(self, "LoadingBar", "ccui.LoadingBar") -- 进度条
	self._textPrecent = seekNodeByName(self, "BitmapFontLabel_Precent", "ccui.TextBMFont") -- 进度显示
	
	
	bindEventCallBack(self._btnClose,	handler(self, self._onBtnCloseClick),	ccui.TouchEventType.ended)
	bindEventCallBack(self._btnReward, handler(self, self._onBtnRewardClick), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnShare, handler(self, self._onBtnShareClick), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnHelp, handler(self, self._onClickHelp), ccui.TouchEventType.ended)
end

function UIRecallFriends:onShow(protocol)
	game.service.ActivityService.getInstance():addEventListener("EVENT_WECHAT_SHAREURL_CHANGED", handler(self, self._setQRCodeIcon), self)
	
	self._slider:setPercent(protocol.currentRewards / protocol.allReward * 100)
	self._weChat = protocol.weChat
	self._type = protocol.inviteType
	self._textPrecent:setString(protocol.currentRewards .. "/" .. protocol.allReward)
	
	self._imgShare:loadTexture(activityData[self._type].imgPath)
	self._btnShare:setVisible(protocol.inviteType == inviteType.inviter)
end

function UIRecallFriends:_onBtnRewardClick()
	-- game.ui.UIMessageBoxMgr.getInstance():show(string.format("请前往公众号%s领取红包奖励", self._weChat), {"复制"}, function(...)
	-- 	if self._weChat ~= "" and game.plugin.Runtime.setClipboard(self._weChat) == true then
	-- 		game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
	-- 	end
	-- end)
	UIManager.getInstance():show("UILuckyDrawGetHongbao")
end
--分享
function UIRecallFriends:_onBtnShareClick()
	local t = cc.FileUtils:getInstance():getStringFromFile("shareRewardsConfig.l")
	self._configInfo = loadstring(t)()
	
	if not self._configInfo then
		return
	end
	
	local activityService = game.service.ActivityService.getInstance()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
	local unionId = activityService:getUnionId()
	local channleId = game.plugin.Runtime.getChannelId() ~= 0 and game.plugin.Runtime.getChannelId() or 100000
	local startTime = activityService:activityTime(net.protocol.activityType.WEIXIN_SHARE)
	if Macro.assetTrue(startTime == nil) then return end
	local state = self._configInfo.STATE_REGION .. "*" .. roleId .. "*" .. unionId .. "*" .. channleId .. "*" .. startTime.startTime
	local shareUrl = self._configInfo.WE_CHAT_CONST .. "?appid=" .. self._configInfo.WECHAT_APPID .. "&redirect_uri=" .. self._configInfo.REDIRECT_URI .. "&response_type=" .. self._configInfo.RESPONSE_TYPE .. "&scope=" .. self._configInfo.SCOPE .. "&state=" .. state
	-- 生成二维码
	activityService:changeLongUrl2Short(shareUrl)
end

-- 生成二维码的回调
function UIRecallFriends:_setQRCodeIcon(event)
	local data =
	{
		enter = share.constants.ENTER.SHARE_PULLNEW,
		code = event.imgPath,
		img = SHARE_ICNO,
	}
	share.ShareWTF.getInstance():share(share.constants.ENTER.SHARE_PULLNEW, {data})
end

-- 活动介绍
function UIRecallFriends:_onClickHelp()
	-- str = string.format(str, self._rewardInfo[self._currentPageId].gongZhongHao)
	local str = [[
邀请人奖励：
1.邀请新玩家，通过分享的二维码下载游戏可建立绑定关系；
2.被邀请玩家注册当天亲友圈完成16局牌局，可获得2元红包奖励；
3.被邀请玩家在第二天亲友圈完成16局牌局，可获得3元红包奖励；
4.红包奖励可关注微信公众号“聚友互动”，点击“领红包”、“提现”领取红包；
5.活动期间，最多可邀请6位新玩家；

被邀请人奖励：
1.新玩家注册当天亲友圈完成16局牌局，可获得2元红包奖励；
2.第二天亲友圈完成16局牌局，可获得3元红包奖励；
3.活动期间，新玩家连续登录5天，可获得10元红包奖励；
4.红包奖励可关注微信公众号“聚友互动”，点击“领红包”、“提现”领取红包；
	]]
	UIManager:getInstance():show('UITurnCardHelp', str)
end

-- 关闭
function UIRecallFriends:_onBtnCloseClick()
	UIManager:getInstance():destroy("UIRecallFriends");
end

function UIRecallFriends:onHide()
	game.service.ActivityService.getInstance():removeEventListenersByTag(self)
end

return UIRecallFriends 