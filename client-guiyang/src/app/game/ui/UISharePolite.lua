local csbPath = "ui/csb/UISharewindows.csb"
local super = require("app.game.ui.UIBase")

local UISharePolite = class("UISharePolite", super, function () return kod.LoadCSBNode(csbPath) end)

local WXInviteeRewardType = {
	MONEY = 1,
	CARD = 2,
	POINTS = 3,
}

function UISharePolite:ctor()
	self._textAccumuMoney 			= nil		-- 累计获利
	self._textAccumuInvitations		= nil		-- 累计邀请
	self._btnReceive				= nil		-- 领取
	self._btnShare					= nil		-- 分享
	self._imgQRCode					= nil		-- 二维码
	self._textDescription 			= nil		-- 说明
	self._textTitle					= nil  		-- 标题
	self._btnClose					= nil		-- 关闭
	self._listStencil 				= nil		-- 邀请标准与邀请奖励
	self._totalRewards  			= 0			-- 保存奖励
	self._shareUrl					= nil		-- 记录分享连接
	self._gongZhongHao				= ""		-- 记录公众号
	self._rewardType 				= WXInviteeRewardType.MONEY 	-- 默认为红包，这样阻断一些判断
end

function UISharePolite:init()
	self._textAccumuMoney 			= seekNodeByName(self,"Text_hl_SW",   		"ccui.Text")
	self._textAccumuInvitations		= seekNodeByName(self,"Text_rs_SW",   		"ccui.Text")
	self._btnReceive				= seekNodeByName(self,"Button_lq_SW",   	"ccui.Button")
	self._btnShare					= seekNodeByName(self,"Button_fx_SW",   	"ccui.Button")
	self._imgQRCode					= seekNodeByName(self,"Image_t_2wm_SW",   	"ccui.ImageView")
	self._textDescription 			= seekNodeByName(self,"Text_z_SW",   		"ccui.Text")
	self._textTitle					= seekNodeByName(self,"Text_zqbz_SW",   	"ccui.Text")
	self._btnClose					= seekNodeByName(self,"Button_x_SW",   		"ccui.Button")
	self._listStencil				= seekNodeByName(self,"ListView_list_SW",   "ccui.ListView")

	-- 不显示滚动条, 无法在编辑器设置
	self._listStencil:setScrollBarEnabled(false)
	self._listviewItemBig = ccui.Helper:seekNodeByName(self._listStencil, "Panel_1_list")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
	self._listviewItemBig:setVisible(false)

	self:_registerCallBack()
end

function UISharePolite:_registerCallBack()
	bindEventCallBack(self._btnReceive,   	handler(self, self._onReceive),		ccui.TouchEventType.ended)
	bindEventCallBack(self._btnShare,   	handler(self, self._onShare),		ccui.TouchEventType.ended);
	bindEventCallBack(self._btnClose,   	handler(self, self._onClose),		ccui.TouchEventType.ended);
end

function UISharePolite:onShow()
	game.service.ActivityService.getInstance():addEventListener("EVENT_QUERY_REWARDS", handler(self, self._updataInvitationsInfo), self)
	game.service.ActivityService.getInstance():addEventListener("EVENT_WECHAT_SHAREURL_CHANGED", handler(self, self._setQRCodeIcon), self)
	game.service.ActivityService.getInstance():addEventListener("EVENT_REWARDS_RECEIVED", handler(self, self._onRewardReceived), self)
	game.service.ActivityService.getInstance():sendCACQueryShareRewardsREQ()
	self:_loadConfigFile()
end

function UISharePolite:onHide()
    game.service.ActivityService.getInstance():removeEventListenersByTag(self)
end

function UISharePolite:needBlackMask()
	return true
end

function UISharePolite:closeWhenClickMask()
	return true
end

function UISharePolite:_onClose(sender)
	UIManager:getInstance():hide("UISharePolite")
end

-- 领取
function UISharePolite:_onReceive()
	if self._rewardType == WXInviteeRewardType.MONEY then
		if self._totalRewards > 0 then
			local trxt = "请进入公众号".. self._gongZhongHao .. "点击“我的红包”按钮进行提现，届时将以红包形式发放！"
			game.ui.UIMessageBoxMgr.getInstance():show(trxt, {"确定"})
		else
			game.ui.UIMessageBoxMgr.getInstance():show("您账户余额为零，请先完成任务！", {"确定"})
		end
	else
		if self._currentRewards > 0 then
			game.service.ActivityService.getInstance():sendCGReceiveRewardsREQ()
		else
			game.ui.UIMessageBoxMgr.getInstance():show("暂时没有奖励可以领取，请先完成任务！", {"确定"})
		end
	end
end

-- 分享
function UISharePolite:_onShare()
	-- bi统计分享
	game.globalConst.getBIStatistics(game.globalConst.shareType.Activity_Share)

    share.ShareWTF.getInstance():share(share.constants.ENTER.SHARE_RECALL, {{url=self._shareUrl}})
end

-- 活动介绍
function UISharePolite:_rewardInfo()
	self._textDescription:setString(self._configInfo.RULES)
	self._textTitle:setString(self._configInfo.SHARE_MSG)

	self._listStencil:removeAllChildren()
	self._rewardType = self._configInfo.REWARD_TYPE
	for _, data in ipairs(self._configInfo.REWAR) do
		local node = self._listviewItemBig:clone()
		self._listStencil:addChild(node)
		node:setVisible(true)
		local playerCount = ccui.Helper:seekNodeByName(node, "Text_yq_1_list")
		local playerReward = ccui.Helper:seekNodeByName(node, "Text_khd_1_list_0")
		playerCount:setString("邀请" .. data.playerCount .. "人")
		if self._rewardType == WXInviteeRewardType.MONEY then
			playerReward:setString(data.playerReward .. "元")
		elseif self._rewardType == WXInviteeRewardType.CARD then
			playerReward:setString(data.playerReward .. config.STRING.UISHAREPOLITE_STRING_100)
		elseif self._rewardType == WXInviteeRewardType.POINTS then
			playerReward:setString(data.playerReward .. "礼卷")
		end
	end
end

-- 更新邀请人数和奖励
function UISharePolite:_updataInvitationsInfo(event)
	self._totalRewards = event.totalRewards
	self._gongZhongHao = event.gongZhongHao
	-- 类型
	self._rewardType = event.itemId
	-- 当前可领取数目
	self._currentRewards = event.currentRewards
	if self._rewardType == WXInviteeRewardType.MONEY then
		self._textAccumuMoney:setString("累计获利:" ..	event.totalRewards .. "元")
	elseif self._rewardType == WXInviteeRewardType.CARD then
		self._textAccumuMoney:setString("待领取: " ..	event.currentRewards .. config.STRING.UISHAREPOLITE_STRING_100)
	elseif self._rewardType == WXInviteeRewardType.POINTS then
		self._textAccumuMoney:setString("待领取: " ..	event.currentRewards .. "礼卷")
	end
	self._textAccumuInvitations:setString("累计邀请:" ..	event.effectiveInviteeCount .. "人")
end

-- 读取配置表信息
function UISharePolite:_loadConfigFile()
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
	local url = self._configInfo.WE_CHAT_CONST .. "?appid=" .. self._configInfo.WECHAT_APPID .. "&redirect_uri=" .. self._configInfo.REDIRECT_URI .. "&response_type=" .. self._configInfo.RESPONSE_TYPE .. "&scope=" .. self._configInfo.SCOPE .. "&state=" .. state
	self._shareUrl = url

	self:_rewardInfo()
	activityService:changeLongUrl2Short(url)
end

-- 二维码
function UISharePolite:_setQRCodeIcon(event)
	-- 设置图片
	if not tolua.isnull(self._imgQRCode) then
		if self._imgQRCode.loadTexture then
			self._imgQRCode:loadTexture(event.imgPath)
		elseif self._imgQRCode.setTexture then
			self._imgQRCode:setTexture(event.imgPath)
		end
	end
end

-- 如果领取成功了，那么把显示清空一下
function UISharePolite:_onRewardReceived()
	self._currentRewards = 0
	if self._rewardType == WXInviteeRewardType.MONEY then
		-- 不处理
	elseif self._rewardType == WXInviteeRewardType.CARD then
		self._textAccumuMoney:setString("待领取: " ..	self._currentRewards .. config.STRING.UISHAREPOLITE_STRING_100)
	elseif self._rewardType == WXInviteeRewardType.POINTS then
		self._textAccumuMoney:setString("待领取: " ..	self._currentRewards .. "礼卷")
	end
end

return UISharePolite
