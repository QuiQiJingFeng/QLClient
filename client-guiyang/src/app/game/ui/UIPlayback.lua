local csbPath = "ui/csb/UIPlayback.csb"
local super = require("app.game.ui.UIBase")

local UIPlayback = class("UIPlayback", super, function() return kod.LoadCSBNode(csbPath) end)
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local Constants = require("app.gameMode.mahjong.core.Constants")
local UIRuleboxComponent = require("app.game.ui.element.UIRuleBoxComponent")

function UIPlayback:ctor()
	self._btnRestart = nil;
	self._btnPause = nil;
	self._btnResume = nil;	
	self._btnSpeeds = {};
	self._btnStop = nil
	self._btnQuit = nil
	self._btnRoundReport = nil
	self._btnDelayTime = nil
	-- add component
	self._uiRuleBoxCmp = UIRuleboxComponent.new(seekNodeByName(self, "Node_rulebox", "cc.Node"))
end

function UIPlayback:init()
	self._btnRestart = seekNodeByName(self, "Button_5_playback", "ccui.Button");
	self._btnPause = seekNodeByName(self, "Button_2_playback", "ccui.Button");
	self._btnResume = seekNodeByName(self, "Button_6_playback", "ccui.Button");
	table.insert(self._btnSpeeds, seekNodeByName(self, "Button_times2_playback", "ccui.Button"))
	table.insert(self._btnSpeeds, seekNodeByName(self, "Button_times_playback", "ccui.Button"))
	table.insert(self._btnSpeeds, seekNodeByName(self, "Button_times_playback_0", "ccui.Button"))
	self._btnStop = seekNodeByName(self, "Button_3_playback", "ccui.Button");
	self._btnQuit = seekNodeByName(self, "Button_1_playback", "ccui.Button");
	self._btnRoundReport = seekNodeByName(self, "Button_Js_playback", "ccui.Button");
	self._btnDelayTime = seekNodeByName(self, "btnDelayTime", "ccui.Button");
	self._btnDelayOriginPos = cc.p(self._btnDelayTime:getPosition())
	
	bindEventCallBack(self._btnRestart, handler(self, self._onTapRestart), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnPause, handler(self, self._onTapPause), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnResume, handler(self, self._onTapResume), ccui.TouchEventType.ended);
	for i = 1, #self._btnSpeeds do
		bindEventCallBack(self._btnSpeeds[i], handler(self, self._onTapSpeed), ccui.TouchEventType.ended);
	end	
	bindEventCallBack(self._btnQuit, handler(self, self._onTapQuit), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnRoundReport, handler(self, self._onRoundReport), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnDelayTime, handler(self, self._onDelayTime), ccui.TouchEventType.ended);
	 
end

--FYD  隐藏结算按钮
function UIPlayback:hideForDistory()
	self._btnRoundReport:setVisible(false)
	self._btnDelayTime:setPosition(cc.p(self._btnRoundReport:getPosition()))
end

function UIPlayback:resetUI()
	self._btnRoundReport:setVisible(true)
	self._btnDelayTime:setPosition(self._btnDelayOriginPos)
end

function UIPlayback:onShow()
	-- 重播默认是不显示的，如果显示了，可能会影响后续的判断
	self._btnRestart:setVisible(false)
	self:resetUI()
	self:_showPauseBtn();
	self:_showSpeedBtn(1)
	self:_showQuitBtn()
	
	-- 更新现在语音选择状态，显示的时候添加关注
	local gameService = gameMode.mahjong.Context.getInstance():getGameService()
	gameService:addEventListener("PROC_END", handler(self, self._showRestartBtn), self)

	-- 处理回放中剩余牌
	local gameType = Constants.SpecialEvents.gameType
    self._isPaoDeKuai = gameType == 'GAME_TYPE_PAODEKUAI'
	if self._isPaoDeKuai then return end
	UIManager:getInstance():show("UILastCrads", {}, {}, "historyDetail", "UIPlayback")
end

function UIPlayback:onHide()
	-- 界面关闭后，取消关注，这里UI销毁会在Content销毁前，要保护一下
	if gameMode.mahjong.Context.getInstance() then
		local gameService = gameMode.mahjong.Context.getInstance():getGameService()
		gameService:removeEventListenersByTag(self)
	end
end

function UIPlayback:_showSpeedBtn(index)
	for i = 1, #self._btnSpeeds do
		self._btnSpeeds[i]:setVisible(i == index);
	end
end

function UIPlayback:_showResumeBtn()
	-- 当重播按钮出来之后，不再处理恢复点击事件
	if not self._btnRestart:isVisible() then
		-- 显示Resume按钮,隐藏其他
		self._btnRestart:setVisible(false)
		self._btnPause:setVisible(false)
		self._btnResume:setVisible(true)
	end
end

function UIPlayback:_showPauseBtn()
	-- 当重播按钮出来之后，不再处理暂停点击事件
	if not self._btnRestart:isVisible() then
		-- 显示Pause按钮,隐藏其他
		self._btnRestart:setVisible(false)
		self._btnPause:setVisible(true)
		self._btnResume:setVisible(false)
	end
end

function UIPlayback:_showRestartBtn()
	-- 显示Restart按钮,隐藏其他
	self._btnRestart:setVisible(true)
	self._btnPause:setVisible(false)
	self._btnResume:setVisible(false)
end

function UIPlayback:_showQuitBtn()
	self._btnStop:setVisible(false)
	self._btnQuit:setVisible(true)
end

function UIPlayback:_onTapRestart(sender)
	game.service.HistoryRecordService:getInstance():restartReplay()
end

function UIPlayback:_onTapPause(sender)
	gameMode.mahjong.Context.getInstance():getGameService():pauseReplay();
	self:_showResumeBtn();
end

function UIPlayback:_onTapResume(sender)
	gameMode.mahjong.Context.getInstance():getGameService():resumeReplay();
	self:_showPauseBtn();
end

function UIPlayback:_onTapSpeed(sender)
	local gameService = gameMode.mahjong.Context.getInstance():getGameService()
	gameService:increaseReplaySpeed();
	self:_showSpeedBtn(gameService:getReplaySpeedIdx())
	Logger.debug("getReplaySpeed %d", gameService:getReplaySpeed())
end

function UIPlayback:_onTapQuit(sender)
	-- gameMode.mahjong.Context.getInstance():getGameService():_processStep(false)
	game.service.HistoryRecordService:getInstance():enterNextGameState()
end

-- 从结算结果中取出首牌以及碰扛信息
function UIPlayback:getCardList(result)
	local roundReportInfo = {
		anGang = {},
		chi = {},
		gang = {},
		hand = {},
		hus = {},
		peng = {},
		hua = {},
		guiCards = {},
		playerData = {},
		player = nil
	}
	
	roundReportInfo.hand = result.handCards
	
	local operateCardsData = result.operateCards
	table.foreach(operateCardsData, function(key, val)
		if PlayType.Check(val.playType, PlayType.DISPLAY_MASTER_HONG_ZHONG) then
			-- 鬼牌
			table.foreach(val.cards, function(k, v)
				table.insert(roundReportInfo.guiCards, v)
			end)
		elseif PlayType.Check(val.playType, PlayType.DISPLAY_SHOW_MASTER_CARD) then
			-- 鬼牌
			table.foreach(val.cards, function(k, v)
				table.insert(roundReportInfo.guiCards, v)
			end)
		elseif PlayType.Check(val.playType, PlayType.DISPLAY_HUA_PAI) then
			-- 鬼牌
			table.foreach(val.cards, function(k, v)
			 	table.insert(roundReportInfo.guiCards, v)
			end)
		elseif PlayType.Check(val.playType, PlayType.OPERATE_GANG_A_CARD) then
			table.insert(roundReportInfo.gang, val.cards[1])
		elseif PlayType.Check(val.playType, PlayType.OPERATE_BU_GANG_A_CARD) then
			table.insert(roundReportInfo.gang, val.cards[1])
		elseif PlayType.Check(val.playType, PlayType.DISPLAY_EX_CARD) then
			table.insert(roundReportInfo.hua, val.cards[1])
		elseif PlayType.Check(val.playType, PlayType.OPERATE_AN_GANG) then
			table.insert(roundReportInfo.anGang, val.cards[1])
		elseif PlayType.Check(val.playType, PlayType.OPERATE_PENG_A_CARD) then
			table.insert(roundReportInfo.peng, val.cards[1])
		elseif PlayType.Check(val.playType, PlayType.OPERATE_CHI_A_CARD) then
			table.insert(roundReportInfo.chi, val.cards[1])
		elseif PlayType.Check(val.playType, PlayType.OPERATE_HU) then
			table.insert(roundReportInfo.hus, val.cards[1])
		end
	end)
	
	return roundReportInfo
end

function UIPlayback:_onRoundReport(sender)
	local gameService = gameMode.mahjong.Context.getInstance():getGameService()
	local roomRecord = gameService:getRoomRecord()
	local idx = gameService:getRoundReportIndex()
	local roundReportData = {}
	roundReportData.matchResults = {}
	roundReportData.lastCards = roomRecord.roundReportRecords[idx].lastCards
	roundReportData.spceialsCards = roomRecord.roundReportRecords[idx].spceialsCards
	table.foreach(roomRecord.roundReportRecords[idx].playerDetailRecords, function(key, val) table.insert(roundReportData.matchResults, val) end)
	
	local playerRecods = roomRecord.playerRecords
	local rounds = {}
	table.foreach(roomRecord.roundReportRecords[idx].playerDetailRecords, function(key, val)
		table.insert(rounds, self:getCardList(val))
	end)
	
	for i = 1, #rounds do
		local playerData = playerRecods[i]
		rounds[i].playerData.chairType = playerData.seat
		rounds[i].playerData.seat = playerData.seat
		rounds[i].playerData.roleId = playerData.roleId
		rounds[i].playerData.position = playerData.position
		rounds[i].playerData.isBanker = bit.band(roomRecord.roundReportRecords[idx].playerDetailRecords[i].status, Constants.PlayerStatus.ZHUANGJIA) ~= 0
		rounds[i].playerData.faceUrl = playerData.iconUrl
		rounds[i].playerData.name = playerData.roleName
	end
	
	UIManager:getInstance():show("UIRoundReportPage2", rounds, roundReportData, "historyDetail")
end

function UIPlayback:_onDelayTime(sender)
	local gameService = gameMode.mahjong.Context.getInstance():getGameService()
	
	UIManager:getInstance():show("UITimeDelay", "replay", gameService:getPlayerDatas())
end

return UIPlayback
