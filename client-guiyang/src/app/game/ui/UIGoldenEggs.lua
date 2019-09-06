local csbPath = "ui/csb/UIGoldenEggs.csb"
local UIRollPanel = require("app.game.util.UIRollPanel")
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")


local chance_config={
	'每日首次登陆可翻牌一次',
	'比赛场获胜%d次可翻牌%d次',
	'金币场获胜%d次',
	'分享给好友%d次',
	'好友桌%d局',
	'获得%d次大赢家可翻牌%d次',
	'比赛场%d次',
	'金币场%d局'
}

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UIGoldenEggs = class("UIGoldenEggs", require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)

local TaskItem = class("TaskItem")

function TaskItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, TaskItem)
    self:_initialize()
    return self
end

function TaskItem:_initialize()

end

function TaskItem:setData(info)
	local function getButtonString()
		if info.taskType == 2 or info.taskType == 3 or info.taskType == 7  then
			return "差"..info.missCount.."次"
		elseif info.taskType == 4 then
			return "分享"
		elseif info.taskType == 5 or info.taskType == 6 or info.taskType == 8 then
			return "差"..info.missCount.."局"
		end
	end

    local textInfo = seekNodeByName(self, "textInfo", "ccui.Text")
	local btnFinish = seekNodeByName(self, "btnFinish", "ccui.Button")
	btnFinish:setTouchEnabled(false)
	local btnSkip = seekNodeByName(self, "btnSkip", "ccui.Button")

	if info.taskType <= #chance_config then
		local str = chance_config[info.taskType]
		str = string.format(str, info.needCount)
		textInfo:setString(str)
		textInfo:setPositionX(10)

		if info.isFinish then
			btnFinish:setVisible(true)
			btnFinish:setEnabled(false)
			btnSkip:setVisible(false)
		else
			btnFinish:setVisible(false)
			btnSkip:setVisible(true)
			btnSkip:setTag(info.taskType)
			bindEventCallBack(btnSkip, handler(self,self._onClickDoTask), ccui.TouchEventType.ended)

			local textButton = btnSkip:getChildByName("BitmapFontLabel_1")
			textButton:setString(getButtonString())
		end
	end
end

function TaskItem:_onClickDoTask(sender)
	local tag = sender:getTag()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.TurnCard_Mission_CLICK..tag)
	UIManager:getInstance():insertMainUI("UIGoldenEggs")
	if tag == 2 or tag == 7 then --	goto比赛场
		game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST)
	elseif tag == 3 or tag == 8 then -- goto金币场
		GameFSM.getInstance():enterState("GameState_Gold")
	elseif tag == 4 then --do 分享
		local data =
		{
			enter = share.constants.ENTER.TURN_CARD_SHARE,
		}
		share.ShareWTF:getInstance():share(share.constants.ENTER.TURN_CARD_SHARE, {data, data, data}, function() game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryShareInfo() end)
	elseif tag == 5 or tag == 6 then -- 完成6局游戏
		uiSkip.UISkipTool.skipTo(uiSkip.SkipType.club)
	end
end

function UIGoldenEggs:ctor()
	self._cards = {}
	self._inClick = false
end


function UIGoldenEggs:init()
	-- 可抽奖次数
	self._textDrawCount = seekNodeByName(self, "textDrawCount", "ccui.Text")
	--确定
	self._btnEgg = seekNodeByName(self, "panelSmash", "ccui.Layout")
	--关闭
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	--中奖名单
	-- self._panelWin = UIRollPanel.extendItem(seekNodeByName(self, "panelWin", "ccui.Layout"))
	self._panelWin = UIRollPanel.extendItem(seekNodeByName(self, "panelWin", "ccui.Layout"))
	--任务容器
	self._panelTask = seekNodeByName(self, "panelTask", "ccui.Layout")
	--任务列表
	-- self._listTask = ListFactory.get(seekNodeByName(self, "listTask", "ccui.ListView"), initDetailList, setListData)
	self._listTask = UIItemReusedListView.extend(seekNodeByName(self, "listTask", "ccui.ListView"), TaskItem)
	self._listTask:setScrollBarEnabled(false)

	--次数
	self._textChance = seekNodeByName(self, "textDrawCount", "ccui.Text")
	
	self._action = cc.CSLoader:createTimeline(csbPath)
	self._action:play("animation1",true)
	self:runAction(self._action)

	self._textTime = seekNodeByName(self, "Text_hdsj", "ccui.Text")

	self._btnHelp = seekNodeByName(self, "Button_hdgz", "ccui.Button")
	self._btnRecord = seekNodeByName(self, "Button_zdjl", "ccui.Button")
	self._tabs = CheckBoxGroup.new({
		seekNodeByName(self, "cboxTask", "ccui.CheckBox"),
		seekNodeByName(self, "cbox", "ccui.CheckBox")
	}, handler(self, self._onTabClick))
	self:_onTabClick(nil, 1)

	seekNodeByName(self, "cbox", "ccui.CheckBox"):setVisible(false)

	self._inClick = false

	self:_registerCallBack()
	self:_updateTime()
end

function UIGoldenEggs:_registerCallBack()
	bindEventCallBack(self._btnEgg, handler(self, self._onClickEgg), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnHelp, handler(self, self._onClickHelp), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnRecord, handler(self, self._onClickRecord), ccui.TouchEventType.ended)
end

function UIGoldenEggs:needBlackMask()
	return true
end

function UIGoldenEggs:onShow()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_ACTIVITY_INFO", handler(self, self._onProcessActivityInfo), self); --处理活动消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_TASK_INFO", handler(self, self._onProcessChanceInfo), self) 			--处理机会消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_AWARD_INFO", handler(self, self._onProcessAwardInfo), self) 	--处理抽奖奖品消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_CHANCE_CHANGE", handler(self, self._onProcessChancesChange), self); --处理活动消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_WINNER_INFO", handler(self, self._onProcessWinnderInfo), self);

	game.service.LocalPlayerService:getInstance():addEventListener("EVENT_GAME_DATA_RETRIVED", handler(self, self._reconnected), self)

	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryAcitivityInfo()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryChanceInfo()


	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryWinnerInfo()

end

function UIGoldenEggs:_onProcessChancesChange()
	self:_updateChanceNum()
	--因为当前分享的回调问题，采用几秒延时后刷新任务列表
	local actDelay = cc.DelayTime:create(2.0)
	local actFunc = cc.CallFunc:create(handler(self, self._onProcessChanceInfo))
	self:runAction(cc.Sequence:create(actDelay, actFunc))
end

function UIGoldenEggs:_updateTime()
	local act = game.service.ActivityService:getInstance():activityTime(net.protocol.activityType.TURN_CARD)
	local beginTime = kod.util.Time.dateWithFormat("%Y.%m.%d", act.startTime/1000)
	local endTime = kod.util.Time.dateWithFormat("%Y.%m.%d", act.endTime/1000)
	self._textTime:setString("活动时间："..beginTime.."-"..endTime)
end
function UIGoldenEggs:_onProcessActivityInfo()
	self:_updateChanceNum()
end
function UIGoldenEggs:_updateChanceNum()
	local chanceNum = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceNum()
	self._textChance:setString("剩余次数："..chanceNum.."次")
	if chanceNum == 0 then
		self._action:gotoFrameAndPause(0)
	else
		self._action:play("animation1", true)
	end
end
--规则
function UIGoldenEggs:_onClickHelp()
	local str = string.gsub( game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getRules(), '\\n', '\n' )
	UIManager:getInstance():show("UITurnCardHelp", str)
end
--记录
function UIGoldenEggs:_onClickRecord()
	-- game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryAwardInfo()
	UIManager:getInstance():show("UITurnCardAward")
end

function UIGoldenEggs:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):removeEventListenersByTag(self)
	game.service.LocalPlayerService:getInstance():removeEventListenersByTag(self)
	self._panelWin:clear()
end

function UIGoldenEggs:_onProcessWinnderInfo()
	local data = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getWinnerInfo();


	self._panelWin:setTextList(data)
	self._panelWin:startRoll(50)
end
--关闭
function UIGoldenEggs:_onClickClose()
	UIManager:getInstance():removeMainUI("UIGoldenEggs")
	UIManager:getInstance():hide("UIGoldenEggs")
end

--砸蛋
function UIGoldenEggs:_onClickEgg()
	if self._inClick then
		return 
	end
	if game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceNum() <= 0 then
        game.ui.UIMessageTipsMgr.getInstance():showTips("砸蛋机会不足，请完成任务")
        return
    end
	self._inClick = true
    game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryCardInfo()
end
function UIGoldenEggs:_onProcessAwardInfo(event)
	-- self._action:gotoFrameAndPlay(0, true)
	-- local reward = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getPrizeItem()
	self:_updateChanceNum()

	-- local itemId = event.item.imageId
	--播放
	
	self._action:play("animation0", false)
	local actDelay1 = cc.DelayTime:create(0.5)
	local actFun1 = cc.CallFunc:create(function() manager.AudioManager:getInstance():playEffect(config.TurnCardConfig.sound, false) end)
	local actDelay2 = cc.DelayTime:create(1.5)
	local actFun2 = cc.CallFunc:create(function() UIManager.getInstance():show("UITurnCardItem", self) end)
	self:runAction(cc.Sequence:create(actDelay1, actFun1, actDelay2, actFun2))
end

function UIGoldenEggs:_resetSelectCard()
	self._inClick = false
	if game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceNum() > 0 then
		self._action:play("animation1", true)
	else
		self._action:gotoFrameAndPause(0)
	end
end

function UIGoldenEggs:_onProcessChanceInfo()
	-- body
	self._listTask:deleteAllItems()
	local data = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceInfo()
	for i = 1,#data do
		self._listTask:pushBackItem(data[i])
	end
end

function UIGoldenEggs:_onTabClick(group, index, _)
	self._nCurPage = index
	if index == 1 then
		self._panelTask:setVisible(true)
		self._panelWin:setVisible(false)
	else 
		
		self._panelTask:setVisible(false)
		self._panelWin:setVisible(true)
	end
end

function UIGoldenEggs:_reconnected()
	self._inClick = false
end
return UIGoldenEggs
