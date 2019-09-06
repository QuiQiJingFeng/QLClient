--local csbPath = "ui/csb/Activity/Christmas/UIChristmasPackage.csb"
local csbPath = "ui/csb/Activity/LongZhou/UILongZhou.csb"
local super = require("app.game.ui.UIBase")
local UIChristmasPackage = class("UIChristmasPackage", super, function() return kod.LoadCSBNode(csbPath) end)
local CSBAnimationHelper = require("app.game.util.CSBAnimationHelper")

--local packagePath = "ui/csb/Activity/Christmas/package.csb"
local packagePath = "ui/csb/Activity/LongZhou/package.csb"

local PACKAGE_STATUS = {
	NEED_SHARE = 0,
	DISAPPEAR = 1,
}

function UIChristmasPackage:ctor()
	-- 礼包节点 及其 动画
	self._uiPackage = {}
	self._packageAni = {}
	-- 是否处于动画期间
	self._isInAniAction = false
    self._wechat = MultiArea.getConfigByKey("activityRedpackWechat")
end

function UIChristmasPackage:init()
	-- 初始化三个礼包,及其礼包的动画
    self._NodePosArr = {}
    ---@type CSBAnimationHelper[]
    self._animHelperArr = {}
	for i = 1, 3 do
		--local action = cc.CSLoader:createTimeline(packagePath)
		local package = cc.CSLoader:createNode(packagePath)
        local raw = package.setVisible
        package.setVisible = function(self, value)
            raw(self, value or false)
            print("package.setVisible name = " .. self:getName() .. tostring(value))
        end
		table.insert(self._uiPackage, package)
		table.insert(self._packageAni, action)

        local node = seekNodeByName(self, "Node" .. i, "cc.Node")
		node:addChild(package)
        table.insert(self._NodePosArr, cc.p(node:getPosition()))
        table.insert(self._animHelperArr, CSBAnimationHelper.new(package, packagePath))

		--package:runAction(action)
		package:setPosition(cc.p(0, 0))
		-- 礼包点击事件
		package.btn = seekNodeByName(package, "panelGift", "ccui.Layout")
		bindTouchEventWithEffect(package.btn, function()
			self:_openPackage(i)
		end, 1.05)

	end

    --self._mainAnim = self:playAnimation(csbPath, nil, true)
    self._mainAniPanel = seekNodeByName(self, "panel_mainAni", "ccui.Layout")
    super.playAnimation(self._mainAniPanel, csbPath, nil, true)
	--圣诞老人动画
	--self._mainAniPanel = seekNodeByName(self, "panel_mainAni", "ccui.Layout")
    --self:_startPlayAnimation(self._mainAniPanel, self._NodePosArr, self._animHelperArr)
	--self._mainAniPanel:setVisible(false)
	-- self._action = cc.CSLoader:createTimeline(csbPath)
	-- self:runAction(self._action)
end

function UIChristmasPackage:onShow()
	-- 获取礼包信息后根据对应信息显示礼包
	event.EventCenter:addEventListener("EVENT_CHRISTMAS_PACKAGE_INFO", handler(self, self._checkShowStartAni), self)
	-- 领取礼包后刷新礼包,并提示奖励
	event.EventCenter:addEventListener("EVENT_CHRISTMAS_PACKAGE_GET", function(event)
		self:_refreshPackage()
		self:_getReward(event.number)
	end, self)
	-- 打开礼包后(需要分享领取),给予提示并刷新礼包
	event.EventCenter:addEventListener("EVENT_CHRISTMAS_PACKAGE_OPEN", function(event)
		self:_refreshPackage()
		self:_needShare(event.number)
	end, self)
	event.EventCenter:addEventListener("EVENT_CHRISTMAS_PACKAGE_SHARE_GET", function(event)
		self:_refreshPackage()
		self:_shareGet(event.num)
	end, self)
	
	self:_checkShowStartAni()

	if not self._schTime then
		self._schTime = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._updateTime), 1.0, false)
	end
end

function UIChristmasPackage:onHide()
	event.EventCenter:removeEventListenersByTag(self)
	game.service.WeChatService.getInstance():removeEventListenersByTag(self)
	if self._schTime then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._schTime)
		self._schTime = nil
	end
end

function UIChristmasPackage:needBlackMask()
	return true
end

function UIChristmasPackage:_close(sender)
	--UIManager.getInstance():hide("UIChristmasPackage")
    self:hideSelf()
end
-- 检查是否需要播放礼包动画并显示礼包
function UIChristmasPackage:_checkShowStartAni()
	--动画期间不做相关操作
	if self._isInAniAction then
		return
	end
	-- 根据特定时间key判断是否播放过动画
    local isNeedAnim = storageTools.AutoShowStorage.isNeedShow(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):getTimeMark())
    self._mainAniPanel:setVisible(isNeedAnim)
    self:_refreshPackage()
    print("UIChristmasPackage:_checkShowStartAni", isNeedAnim)
	if isNeedAnim then
		self:_packageShowAni()
	else
        for _, v in ipairs(self._animHelperArr) do
            v:play("light", true)
        end
	end
end

--礼包出现动画
function UIChristmasPackage:_packageShowAni(...)
	-- 设置动画标志
	-- self._isInAniAction = true
	
	-- table.walk(self._uiPackage, function(value)
	-- 	value:setVisible(false)
	-- 	value.btn:setTouchEnabled(false)
	-- end)
	-- local maskUI = self:getChildByName("dlg_mask")
	
	-- maskUI:setVisible(true)
	-- -- self._mainAniPanel:setVisible(true)
	
	-- -- self._action:gotoFrameAndPlay(0, false)
	-- local delay1 = cc.DelayTime:create(40 / 40)
	-- local delay2 = cc.DelayTime:create((98 - 40) / 40)
	-- local delay3 = cc.DelayTime:create((160 - 98) / 40)
	-- local delay4 = cc.DelayTime:create((200 - 160) / 40)
	-- local callback = function(number)
	-- 	return function(...)
	-- 		self._uiPackage[number]:setVisible(true)
	-- 		-- self._packageAni[number]:play("animation1", false)
	-- 	end
	-- end
	-- -- 根据圣诞老人对应的路过时间,播放礼包出现动画
	-- local seq = cc.Sequence:create(delay1, cc.CallFunc:create(callback(1)),
	-- delay2, cc.CallFunc:create(callback(2)),
	-- delay3, cc.CallFunc:create(callback(3)),
	-- delay4,
	-- cc.CallFunc:create(function()
	-- 	self:_refreshPackage()
	-- end))
	-- self:runAction(seq)
    --self:_refreshPackage()

    self:_startPlayAnimation(self._mainAniPanel, self._NodePosArr, self._animHelperArr)
end


-- 刷新礼包状态
function UIChristmasPackage:_refreshPackage(...)
	-- 刷新动画标志
	--self._isInAniAction = false
	
	local packages = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):getPackageInfo().packageMap
	for k, v in ipairs(packages) do
		local visible = v.status == nil or v.status == PACKAGE_STATUS.NEED_SHARE
		self._uiPackage[k]:getParent():setVisible(visible)
		--self._packageAni[k]:play("animation0", true)
		self._uiPackage[k].btn:setTouchEnabled(true)
	end
	local maskUI = self:getChildByName("dlg_mask")
	
	maskUI:setVisible(false)
	-- self._mainAniPanel:setVisible(false)
end

-- 获得奖励的礼包给予提示
function UIChristmasPackage:_getReward(number)
	local package = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):getPackageInfo().packageMap[number]
	if PropReader.getTypeById(package.itemId) == "RedPackage" then
		local string = string.format(config.STRING.ACTIVITY_DUANWU_REDPACKET, package.count, self._wechat)
		game.ui.UIMessageBoxMgr.getInstance():reverseBtnShow(string, {"复制", "确定"},
		function()
			game.plugin.Runtime.setClipboard(self._wechat)
		end, function() end)
		
	else
		UIManager.getInstance():show("UITurnCardItem", self, package.itemId, package.count, package.time)
	end
end

-- 需要提示的分享领取的礼包给予提示
function UIChristmasPackage:_needShare(number)
	local package = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):getPackageInfo().packageMap[number]
	local string = string.format(config.STRING.ACTIVITY_DUANWU_REDPACKET_SHARE, package.count)
	game.ui.UIMessageBoxMgr.getInstance():reverseBtnShow(string, {"分享", "放弃"},
	function()
		local shareEnter = share.constants.ENTER.ACTIVITY_FOR_SCREEN_SHOT
		local shareData  =
		{
			enter = share.constants.ENTER.ACTIVITY_FOR_SCREEN_SHOT,
		}
		local shareDatas = {shareData}
		share.ShareWTF.getInstance():share(shareEnter, shareDatas, function()
			game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):CACThrowRewardShareREQ()
		end)
	end, function() end)
	
end

function UIChristmasPackage:_openPackage(number)
	local packageInfo = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):getPackageInfo()
	local package = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):getPackageInfo().packageMap[number]
	if package.status == PACKAGE_STATUS.NEED_SHARE then
		self:_needShare(number)
	else
		if packageInfo.data.freeOpen > 0 then
			game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):CACThrowRewardOpenREQ(number, true)
		else
			game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.ACTIVITY_DUANWU_NO_FREE_TIMES, {"再开一次", "取消"},
			function()
				game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):CACThrowRewardOpenREQ(number, false)
			end)
		end
	end
end

function UIChristmasPackage:_shareGet(num)
	local string = string.format(config.STRING.ACTIVITY_DUANWU_REDPACKET, num, self._wechat)
	game.ui.UIMessageBoxMgr.getInstance():reverseBtnShow(string, {"复制", "确定"},
	function()
		game.plugin.Runtime.setClipboard(self._wechat)
	end, function() end)
end



function UIChristmasPackage:_onShareCallback()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):CACThrowRewardShareREQ()
end

function UIChristmasPackage:_updateTime()
	if not game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):checkTime() then
		self:_close()
	end
end

---@param board Node
---@param posArr {x:number, y:number}[]
---@param animHelpArr CSBAnimationHelper[]
function UIChristmasPackage:_startPlayAnimation(board, posArr, animHelpArr)
    self._isInAniAction = true
    local screenSize = cc.Director:getInstance():getWinSize()
    local y = board:getPositionY()
    local ap = board:getAnchorPoint()
    local size = board:getContentSize()
    local startP = cc.p(- (1 - ap.x) * size.width, y)
    local endP = cc.p(screenSize.width + ap.x * size.width , y)
    local function getTime(from, to)
        if not from then
            from = startP
        end
        return (math.abs(to.x - from.x) / screenSize.width) * 5
    end

    local actions = {}
    for idx, v in ipairs(posArr) do
        --animHelpArr[idx]:gotoFrameAndPause(1)
        animHelpArr[idx]:setVisible(false)
        table.insert(actions, cc.MoveTo:create(getTime(posArr[idx - 1], v), cc.p(v.x, y)))
        table.insert(actions, cc.CallFunc:create(function()
            --Logger.debug("UIChristmasPackage " .. idx .. ", play")
            local helper = animHelpArr[idx]
            --Logger.debug("time 0 " .. helper:getAnimationTime("drop"))
            --Logger.debug("time 1 " .. helper:getAnimationTime("light"))
            helper:setVisible(true):delay(0.5):play("drop"):play("light", true)
        end))
    end
    board:setPosition(startP)
    table.insert(actions, cc.MoveTo:create(getTime(posArr[#posArr], endP), endP))
    table.insert(actions, 1, cc.Show:create())
    table.insert(actions, cc.Hide:create())
    table.insert(actions, cc.CallFunc:create(function()
        if self._mainAnim and board and not tolua.isnull(self) then
            board:stopAction(self._mainAnim)
        end
        self._isInAniAction = false
    end))
    board:runAction(cc.Sequence:create(unpack(actions, 1, #actions)))
end

return UIChristmasPackage 