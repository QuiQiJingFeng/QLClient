local csbPath = "ui/csb/Newshare/UINewShare.csb"
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UIPlayerInfo = class("UIPlayerInfo")

local function updateNode(info, node)
	local function hasGet(idx)
		if info.rewardProgress == nil then
			return false
		end
		for _,v in pairs(info.rewardProgress) do
			if v == config.NewShareConfig.rawardProgress[idx] then
				return true
			end
		end
		return false
	end
	local function canGet(idx)
		if info.roundCount >= config.NewShareConfig.rawardProgress[idx] and not hasGet(idx) then
			return config.NewShareConfig.getState.CAN_GET
		elseif hasGet(idx) then
			return config.NewShareConfig.getState.ALREADY_GET
		else
			return config.NewShareConfig.getState.CAN_NOT_GET
		end
	end	
	--玩家头像
	if info.headImgUrl then
		local imageHead = seekNodeByName(node, "Image_Head", "ccui.ImageView")
		game.util.PlayerHeadIconUtil.setIcon(imageHead, info.headImgUrl)

		--进度条
		local bar = seekNodeByName(node, "LoadingBar_launch", "ccui.LoadingBar")
		bar:setPercent(config.NewShareConfig.getPercent(info.roundCount) )
		node:setTag(info.roleId)
	end
	
	--物品领取状态
	local text_items = {}
	local layout_items = {}
	for i = 1,4 do	
		text_items[i] = seekNodeByName(node, "Text_gift"..i, "ccui.Text")		
		layout_items[i] = seekNodeByName(node, "Panel_gift"..i, "ccui.Layout")
		local itemInfo = config.NewShareConfig.itemConfig[i]
		text_items[i]:setString(itemInfo[1])


		layout_items[i]:removeAllChildren()
		local pNode = cc.CSLoader:createNode(itemInfo[2])
		layout_items[i]:addChild(pNode)

		local particle = seekNodeByName(pNode, "Particle_1", "cc.Node")
		local imageGet = seekNodeByName(pNode, "Image_3", "ccui.ImageView")
		local pPanel = seekNodeByName(pNode, "Panel_1", "ccui.Layout")
		local imageItem = seekNodeByName(pNode, "Image_2", "ccui.ImageView")
		local imageBottom = seekNodeByName(pNode, "Image_1", "ccui.ImageView")

		-- print("canGet~~~~~~~~~~~~~~~~~~", canGet(i))
		if info.headImgUrl then
			if canGet(i) == config.NewShareConfig.getState.CAN_GET then
				pPanel:setTouchEnabled(true)
				pPanel:addClickEventListener(function()
					game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.NewShare_Award..config.NewShareConfig.rawardProgress[i])
					game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.NEW_SHARE):queryRewardInfo(info.roleId, i)				
				end)
				imageGet:setVisible(false)
				kod.ShaderHelper.removeNodeShader(imageGet)
				kod.ShaderHelper.removeNodeShader(imageItem)
				kod.ShaderHelper.removeNodeShader(imageBottom)
			elseif canGet(i) == config.NewShareConfig.getState.ALREADY_GET then
				pPanel:setTouchEnabled(false)
				particle:setVisible(false)
				kod.ShaderHelper.shaderImage(imageGet)
				kod.ShaderHelper.shaderImage(imageItem)
				kod.ShaderHelper.shaderImage(imageBottom)
			else
				pPanel:setTouchEnabled(false)
				imageGet:setVisible(false)
				particle:setVisible(false)
			end
		else
			local bar = seekNodeByName(node, "LoadingBar_launch", "ccui.LoadingBar")
			bar:setPercent(0)
			particle:setVisible(false)
			imageGet:setVisible(false)

		end
	end

	

end


function UIPlayerInfo.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIPlayerInfo)
    self:_initialize()
    return self
end

function UIPlayerInfo:_initialize()

end

function UIPlayerInfo:setData(info)
	updateNode(info, self)	
end




local UINewShare= class("UINewShare",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UINewShare:ctor()

end


function UINewShare:init()
	self._btnClose = seekNodeByName(self, "Button_x_CouponZD", "ccui.Button")	--关闭
	self._btnFriend = seekNodeByName(self, "Button_Friends", "ccui.Button")		--好友分享
	self._btnCircle = seekNodeByName(self, "Button_Circle", "ccui.Button")	--朋友圈分享
	self._btnHelp = seekNodeByName(self, "Button_Help", "ccui.Button")		--帮助按钮
	self._textFindWx = seekNodeByName(self, "Text_bzxx_0_1", "ccui.Text")
	self._textFindWx:setTouchEnabled(true)
	if device.platform == "android" then
		self._textFindWx:setVisible(false)
	end

	self._listPlayers = UIItemReusedListView.extend(seekNodeByName(self, "ListView_2", "ccui.ListView"), UIPlayerInfo)
	self:_registerCallBack()
end

function UINewShare:_registerCallBack()
	bindEventCallBack(self._textFindWx, handler(self, self._onClickFindWx), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnFriend, handler(self, self._onClickFriend), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnCircle, handler(self, self._onClickFriendCircle), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnHelp, handler(self, self._onClickHelp), ccui.TouchEventType.ended)
end

function UINewShare:needBlackMask()
    return true
end

function UINewShare:closeWhenClickMask()
	return false
end


function UINewShare:onShow()
	
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.NEW_SHARE):queryAcitivityInfo()

	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.NEW_SHARE):addEventListener("EVENT_ACTIVITY_INFO", handler(self, self._onProcessActivityInfo), self); --处理活动消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.NEW_SHARE):addEventListener("EVENT_AWARD_INFO", handler(self, self._onProcessAwardInfo), self) 	--处理抽奖奖品消息
	
end
--处理活动消息
function UINewShare:_onProcessActivityInfo()
	print("_onProcessActivityInfo~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	local players = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.NEW_SHARE):getAllPlayers()
	self._listPlayers:deleteAllItems()
	if #players > 0 then
		for _,player in pairs(players) do
			self._listPlayers:pushBackItem(player)
		end
	else
		for i = 1,10 do
			self._listPlayers:pushBackItem({})
		end
	end
end
--处理奖品信息
function UINewShare:_onProcessAwardInfo(event)
	local roleId = event.roleId
	local info = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.NEW_SHARE):getPlayerById(roleId)
	local node = self._listPlayers:getChildByTag(roleId)
	if info and node then
		self:updateOneNode(info, node)
	end

	UIManager:getInstance():show("UINewShareItem")
end
function UINewShare:updateOneNode(info, parentNode)
	updateNode(info,parentNode)
end
--帮助
function UINewShare:_onClickHelp()
	if self._inDraw then
		return 
	end
	UIManager:getInstance():show("UINewShareHelp")
end
--关闭
function UINewShare:_onClickClose()
	UIManager:getInstance():hide("UINewShare")
end

function UINewShare:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.NEW_SHARE):removeEventListenersByTag(self)
end


function UINewShare:_onClickFriend()
	--todo:点击好友分享
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.NewShare_Friend)
	local source = math.ceil(3 * math.random())
	-- local source = 10
	self._curSource = source
	kod.getTwoDemensionCode.doGet(source,handler(self,self._shareFriend))
end
function UINewShare:_shareFriend()
	local data =
	{
		enter = share.constants.ENTER.NEW_SHARE_FRIEND,
		img = self._curSource,
	}
	share.ShareWTF.getInstance():share(share.constants.ENTER.NEW_SHARE_FRIEND, {data})
end


function UINewShare:_onClickFriendCircle()
	--todo:点击好友圈分享\
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.NewShare_Circle)
	local source = math.ceil(3 * math.random())
	-- local source = 10
	self._curSource = source
	kod.getTwoDemensionCode.doGet(source,handler(self,self._shareCircle))
end
function UINewShare:_shareCircle()
	local data =
	{
		enter = share.constants.ENTER.NEW_SHARE_CIRCLE,
		img = self._curSource,
	}
	share.ShareWTF.getInstance():share(share.constants.ENTER.NEW_SHARE_CIRCLE, {data})
end
--找微信指引
function UINewShare:_onClickFindWx()
	UIManager:getInstance():show("UINewShareFindWx")
end
return UINewShare
